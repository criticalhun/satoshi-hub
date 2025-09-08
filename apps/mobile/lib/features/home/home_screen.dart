import '../../core/services/wallet/wallet_state.dart';
import '../../core/services/wallet/wallet_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../core/services/wallet/wallet_manager.dart';
import '../../shared/models/transaction_job.dart';
import '../../shared/widgets/wallet_status_card.dart';
import '../../shared/widgets/quick_actions.dart';
import 'widgets/recent_transactions_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<TransactionJob> _recentTransactions = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecentTransactions();
  }

  Future<void> _loadRecentTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final result = await apiService.getTransactionJobs(
        page: 1,
        limit: 5,
      );

      setState(() {
        _recentTransactions = result['data'] as List<TransactionJob>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletStateProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Satoshi Hub'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecentTransactions,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRecentTransactions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const WalletStatusCard(),
                const SizedBox(height: 24),
                const QuickActions(),
                const SizedBox(height: 24),
                RecentTransactionsSection(
                  isLoading: _isLoading,
                  error: _error,
                  transactions: _recentTransactions,
                  onViewAll: () => context.go('/activity'),
                  onRefresh: _loadRecentTransactions,
                  onTapTransaction: (txId) => context.go('/transaction/$txId'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: walletState.isConnected
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/bridge'),
              backgroundColor: AppTheme.primaryColor,
              label: const Text('Bridge Now'),
              icon: const Icon(Icons.swap_horiz),
            )
          : FloatingActionButton.extended(
              onPressed: () => context.go('/connect-wallet'),
              backgroundColor: AppTheme.primaryColor,
              label: const Text('Connect Wallet'),
              icon: const Icon(Icons.account_balance_wallet),
            ),
    );
  }
}
