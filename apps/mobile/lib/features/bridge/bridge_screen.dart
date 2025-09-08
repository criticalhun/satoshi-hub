import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../core/services/wallet/wallet_state.dart';
import '../../core/services/wallet/wallet_manager.dart';
import '../../shared/models/transaction_job.dart';
import 'widgets/bridge_form.dart';

class BridgeScreen extends ConsumerStatefulWidget {
  const BridgeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BridgeScreen> createState() => _BridgeScreenState();
}

class _BridgeScreenState extends ConsumerState<BridgeScreen> {
  bool _isLoading = false;
  String? _transactionId;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkWalletConnection();
    });
  }

  void _checkWalletConnection() {
    final walletState = ref.read(walletStateProvider);
    if (!walletState.isConnected) {
      // Ha nincs csatlakoztatva wallet, átirányítunk a connect wallet képernyőre
      context.go('/connect-wallet');
    }
  }

  Future<void> _createTransaction(
    int fromChainId,
    int toChainId,
    String to,
    String amount,
  ) async {
    // Ellenőrizzük, hogy van-e csatlakoztatott wallet
    final walletState = ref.read(walletStateProvider);
    if (!walletState.isConnected) {
      setState(() {
        _error = 'Please connect your wallet first';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _transactionId = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      
      // Tranzakció létrehozása
      final data = {
        'fromChainId': fromChainId,
        'toChainId': toChainId,
        'payload': {
          'type': 'transfer',
          'to': to,
          'amount': amount,
          'from': walletState.address,
        },
      };
      
      final TransactionJob transaction = await apiService.createTransactionJob(data);
      
      setState(() {
        _isLoading = false;
        _transactionId = transaction.id;
      });
      
      // Átirányítunk a tranzakció részletek képernyőre
      if (_transactionId != null) {
        context.go('/transaction/$_transactionId');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to create transaction: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletStateProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Bridge Assets'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet Information
            if (walletState.isConnected && walletState.address != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connected Wallet',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatAddress(walletState.address!),
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (walletState.balance != null)
                      Text(
                        '${walletState.balance!.toStringAsFixed(4)} ETH',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Error Message
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.error.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppTheme.error,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: AppTheme.error,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Bridge Form
            BridgeForm(
              isLoading: _isLoading,
              onSubmit: _createTransaction,
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}
