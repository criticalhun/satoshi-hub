import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../shared/models/transaction_job.dart';
import 'providers/activity_provider.dart';
import 'widgets/transaction_list_item.dart';
import 'widgets/filter_chip_list.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  List<TransactionJob> _transactions = [];
  int _page = 1;
  int _totalPages = 1;
  String? _statusFilter;
  int? _fromChainIdFilter;
  int? _toChainIdFilter;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading &&
        _page < _totalPages) {
      _loadNextPage();
    }
  }

  Future<void> _loadTransactions({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _page = 1;
        _transactions = [];
        _error = null;
      }
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final result = await apiService.getTransactionJobs(
        page: _page,
        limit: 10,
        fromChainId: _fromChainIdFilter,
        toChainId: _toChainIdFilter,
        status: _statusFilter,
      );

      final List<TransactionJob> newTransactions = result['data'] as List<TransactionJob>;
      final meta = result['meta'] as Map<String, dynamic>;

      setState(() {
        if (refresh || _page == 1) {
          _transactions = newTransactions;
        } else {
          _transactions = [..._transactions, ...newTransactions];
        }
        _totalPages = meta['lastPage'] as int;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNextPage() async {
    setState(() {
      _page++;
    });
    await _loadTransactions();
  }

  void _applyFilters({String? status, int? fromChainId, int? toChainId}) {
    setState(() {
      _statusFilter = status;
      _fromChainIdFilter = fromChainId;
      _toChainIdFilter = toChainId;
    });
    _loadTransactions(refresh: true);
  }

  void _clearFilters() {
    setState(() {
      _statusFilter = null;
      _fromChainIdFilter = null;
      _toChainIdFilter = null;
    });
    _loadTransactions(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Activity'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadTransactions(refresh: true),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
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
              'Error loading transactions',
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
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _loadTransactions(refresh: true),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_transactions.isEmpty) {
      if (_isLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              color: AppTheme.textSecondary,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions found',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your transaction history will appear here',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadTransactions(refresh: true),
      child: Column(
        children: [
          if (_statusFilter != null || _fromChainIdFilter != null || _toChainIdFilter != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const Text(
                    'Filters:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilterChipList(
                      statusFilter: _statusFilter,
                      fromChainIdFilter: _fromChainIdFilter,
                      toChainIdFilter: _toChainIdFilter,
                      onClearFilters: _clearFilters,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _transactions.length + (_isLoading && _page > 1 ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _transactions.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                final transaction = _transactions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () {
                      context.go('/transaction/${transaction.id}');
                    },
                    child: TransactionListItem(transaction: transaction),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            String? tempStatusFilter = _statusFilter;
            int? tempFromChainId = _fromChainIdFilter;
            int? tempToChainId = _toChainIdFilter;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Transactions',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip('Pending', 'pending', tempStatusFilter, (value) {
                        setState(() {
                          tempStatusFilter = value ? 'pending' : null;
                        });
                      }),
                      _buildFilterChip('Processing', 'processing', tempStatusFilter, (value) {
                        setState(() {
                          tempStatusFilter = value ? 'processing' : null;
                        });
                      }),
                      _buildFilterChip('Completed', 'completed', tempStatusFilter, (value) {
                        setState(() {
                          tempStatusFilter = value ? 'completed' : null;
                        });
                      }),
                      _buildFilterChip('Failed', 'failed', tempStatusFilter, (value) {
                        setState(() {
                          tempStatusFilter = value ? 'failed' : null;
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chain',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip('Sepolia', '11155111', tempFromChainId?.toString(), (value) {
                        setState(() {
                          tempFromChainId = value ? 11155111 : null;
                        });
                      }),
                      _buildFilterChip('Mumbai', '80001', tempFromChainId?.toString(), (value) {
                        setState(() {
                          tempFromChainId = value ? 80001 : null;
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            tempStatusFilter = null;
                            tempFromChainId = null;
                            tempToChainId = null;
                          });
                        },
                        child: Text(
                          'Clear All',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _applyFilters(
                            status: tempStatusFilter,
                            fromChainId: tempFromChainId,
                            toChainId: tempToChainId,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                        ),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value, String? currentValue, Function(bool) onSelected) {
    return FilterChip(
      label: Text(label),
      selected: currentValue == value,
      onSelected: onSelected,
      backgroundColor: AppTheme.cardColor,
      selectedColor: AppTheme.primaryColor.withOpacity(0.3),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: currentValue == value ? AppTheme.primaryColor : Colors.white,
      ),
    );
  }
}
