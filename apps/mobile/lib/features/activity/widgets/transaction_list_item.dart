import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/transaction_job.dart';
import '../../../core/services/explorer_service.dart';

class TransactionListItem extends ConsumerWidget {
  final TransactionJob transaction;

  const TransactionListItem({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Parse payload
    String payloadString = '';
    try {
      if (transaction.payload is String) {
        payloadString = transaction.payload as String;
      } else if (transaction.payload is Map<String, dynamic>) {
        payloadString = transaction.payload.toString();
      }
    } catch (e) {
      payloadString = '';
    }

    // Try to extract important information
    String to = 'Unknown';
    String amount = 'Unknown';
    String type = 'Unknown';

    try {
      final Map<String, dynamic> payload = transaction.payload;
      type = payload['type'] as String? ?? 'Unknown';
      to = payload['to'] as String? ?? 'Unknown';
      amount = payload['amount'] as String? ?? 'Unknown';
    } catch (e) {
      // Just use defaults if extraction fails
    }

    // Try to extract transaction hash
    String? txHash;
    if (transaction.isCompleted && transaction.result != null) {
      try {
        txHash = transaction.txHash;
      } catch (e) {
        // Silent catch
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatusIcon(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bridge Transaction',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'From ${_getChainName(transaction.fromChainId)} to ${_getChainName(transaction.toChainId)}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amount,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy HH:mm').format(transaction.createdAt),
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Show explorer button for completed transactions with txHash
                if (transaction.isCompleted && txHash != null && txHash.isNotEmpty)
                  InkWell(
                    onTap: () {
                      ref.read(explorerServiceProvider).openTransactionInExplorer(
                        transaction.fromChainId,
                        txHash,
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View in Explorer',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.open_in_new,
                          color: AppTheme.primaryColor,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getStatusIcon(),
        color: _getStatusColor(),
        size: 20,
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (transaction.status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'processing':
        return Icons.sync;
      case 'completed':
        return Icons.check_circle;
      case 'failed':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor() {
    switch (transaction.status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return AppTheme.success;
      case 'failed':
        return AppTheme.error;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (transaction.status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  String _getChainName(int chainId) {
    switch (chainId) {
      case 11155111:
        return 'Sepolia';
      case 80001:
        return 'Mumbai';
      default:
        return 'Chain $chainId';
    }
  }
}
