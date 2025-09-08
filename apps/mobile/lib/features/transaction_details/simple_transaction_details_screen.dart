import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/explorer_service.dart';

class SimpleTransactionDetailsScreen extends ConsumerStatefulWidget {
  final String transactionId;

  const SimpleTransactionDetailsScreen({
    Key? key,
    required this.transactionId,
  }) : super(key: key);

  @override
  ConsumerState<SimpleTransactionDetailsScreen> createState() => _SimpleTransactionDetailsScreenState();
}

class _SimpleTransactionDetailsScreenState extends ConsumerState<SimpleTransactionDetailsScreen> {
  bool isLoading = true;
  Map<String, dynamic>? transactionData;
  String? error;
  Timer? _refreshTimer;
  
  @override
  void initState() {
    super.initState();
    _loadTransactionDetails();
    // Start auto-refresh for pending or processing transactions
    _startAutoRefresh();
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  void _startAutoRefresh() {
    // Cancel any existing timer
    _refreshTimer?.cancel();
    
    // Create a new timer that refreshes every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Only refresh if the transaction is pending or processing
      if (transactionData != null) {
        final status = transactionData!['status'] as String? ?? '';
        if (status.toLowerCase() == 'pending' || status.toLowerCase() == 'processing') {
          _loadTransactionDetails(silent: true);
        } else {
          // Cancel the timer if the transaction is completed or failed
          timer.cancel();
        }
      }
    });
  }

  Future<void> _loadTransactionDetails({bool silent = false}) async {
    if (!silent) {
      setState(() {
        isLoading = true;
        error = null;
      });
    }

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/tx/${widget.transactionId}'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          transactionData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        final errorData = jsonDecode(response.body);
        setState(() {
          error = errorData['message'] ?? 'Failed to load transaction details';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadTransactionDetails(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppTheme.error,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading transaction',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _loadTransactionDetails(),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _buildTransactionDetails(context),
    );
  }

  Widget _buildTransactionDetails(BuildContext context) {
    if (transactionData == null) {
      return const Center(
        child: Text('Transaction not found'),
      );
    }

    final status = transactionData!['status'] as String? ?? 'Unknown';
    final fromChainId = transactionData!['fromChainId'] as int? ?? 0;
    final toChainId = transactionData!['toChainId'] as int? ?? 0;
    
    // Parse payload
    String payloadString = transactionData!['payload'] as String? ?? '{}';
    Map<String, dynamic> payload = {};
    try {
      payload = jsonDecode(payloadString);
    } catch (e) {
      // In case payload is already a map
      if (transactionData!['payload'] is Map<String, dynamic>) {
        payload = transactionData!['payload'] as Map<String, dynamic>;
      }
    }

    // Get basic information
    final type = payload['type'] as String? ?? 'Unknown';
    final toAddress = payload['to'] as String? ?? 'Unknown';
    final amount = payload['amount'] as String? ?? '0';

    // Parse result if present
    String? txHash;
    String? errorMessage;
    if (transactionData!['result'] != null) {
      try {
        final resultString = transactionData!['result'] as String;
        final result = jsonDecode(resultString);
        txHash = result['txHash'] as String?;
        errorMessage = result['message'] as String?;
      } catch (e) {
        // Silent catch
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transaction Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildStatusIcon(status),
                const SizedBox(height: 16),
                Text(
                  'Transaction ID',
                  style: TextStyle(
                    color: AppTheme.textPrimary.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.transactionId,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Transaction Details
          Text(
            'Transfer Details',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Transaction Type', type),
                const Divider(color: Colors.white24),
                _buildInfoRow('From Chain ID', fromChainId.toString(), 
                  suffix: txHash != null && txHash.isNotEmpty ? IconButton(
                    icon: const Icon(Icons.open_in_new, size: 16),
                    color: AppTheme.primaryColor,
                    onPressed: () {
                      // Open in explorer
                      ref.read(explorerServiceProvider).openTransactionInExplorer(
                        fromChainId,
                        txHash,
                      );
                    },
                  ) : null,
                ),
                const SizedBox(height: 8),
                _buildInfoRow('To Chain ID', toChainId.toString()),
                const Divider(color: Colors.white24),
                _buildInfoRow('Recipient Address', toAddress,
                  suffix: IconButton(
                    icon: const Icon(Icons.open_in_new, size: 16),
                    color: AppTheme.primaryColor,
                    onPressed: () {
                      // Open in explorer
                      ref.read(explorerServiceProvider).openAddressInExplorer(
                        toChainId,
                        toAddress,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Amount', amount),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Transaction Hash Section
          if (status == 'completed' && txHash != null && txHash.isNotEmpty) ...[
            Text(
              'Transaction Hash',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hash',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          txHash,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.open_in_new, size: 20),
                        color: AppTheme.primaryColor,
                        onPressed: () {
                          // Open in explorer
                          ref.read(explorerServiceProvider).openTransactionInExplorer(
                            fromChainId,
                            txHash,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Error Message Section
          if (status == 'failed' && errorMessage != null && errorMessage.isNotEmpty) ...[
            Text(
              'Error Details',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Error Message',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: AppTheme.error,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Processing Info
          if (status == 'pending' || status == 'processing') ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: status == 'pending' ? Colors.orange : Colors.blue,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  status == 'pending'
                    ? const Icon(Icons.info_outline, color: Colors.orange)
                    : const Icon(Icons.sync, color: Colors.blue),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status == 'pending' ? 'Transaction Pending' : 'Transaction Processing',
                          style: TextStyle(
                            color: status == 'pending' ? Colors.orange : Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status == 'pending'
                            ? 'Your transaction is waiting to be processed. This may take a few moments.'
                            : 'Your transaction is being processed. This should complete shortly.',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Auto-refresh notice
            Center(
              child: Text(
                'Refreshing automatically every 5 seconds...',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Refresh Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _loadTransactionDetails(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Refresh Status',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'processing':
        icon = Icons.sync;
        color = Colors.blue;
        label = 'Processing';
        break;
      case 'completed':
        icon = Icons.check_circle;
        color = AppTheme.success;
        label = 'Completed';
        break;
      case 'failed':
        icon = Icons.error;
        color = AppTheme.error;
        label = 'Failed';
        break;
      default:
        icon = Icons.help;
        color = Colors.grey;
        label = 'Unknown';
    }

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Widget? suffix}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (suffix != null) suffix,
            ],
          ),
        ],
      ),
    );
  }
}
