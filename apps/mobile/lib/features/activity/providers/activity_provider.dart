import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/transaction_job.dart';

class ActivityState {
  final bool isLoading;
  final List<TransactionJob> transactions;
  final int currentPage;
  final int totalPages;
  final String? error;
  final bool hasMore;
  final String? statusFilter;
  final int? fromChainIdFilter;
  final int? toChainIdFilter;

  const ActivityState({
    this.isLoading = false,
    this.transactions = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.error,
    this.hasMore = true,
    this.statusFilter,
    this.fromChainIdFilter,
    this.toChainIdFilter,
  });

  ActivityState copyWith({
    bool? isLoading,
    List<TransactionJob>? transactions,
    int? currentPage,
    int? totalPages,
    String? error,
    bool? hasMore,
    String? statusFilter,
    int? fromChainIdFilter,
    int? toChainIdFilter,
    bool clearError = false,
  }) {
    return ActivityState(
      isLoading: isLoading ?? this.isLoading,
      transactions: transactions ?? this.transactions,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      error: clearError ? null : error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      statusFilter: statusFilter ?? this.statusFilter,
      fromChainIdFilter: fromChainIdFilter ?? this.fromChainIdFilter,
      toChainIdFilter: toChainIdFilter ?? this.toChainIdFilter,
    );
  }
}

class ActivityNotifier extends StateNotifier<ActivityState> {
  final ApiService _apiService;

  ActivityNotifier(this._apiService) : super(const ActivityState()) {
    loadTransactions();
  }

  Future<void> loadTransactions({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(
      isLoading: true,
      currentPage: refresh ? 1 : state.currentPage,
      transactions: refresh ? [] : state.transactions,
      clearError: true,
    );

    try {
      final result = await _apiService.getTransactionJobs(
        page: state.currentPage,
        limit: 10,
        fromChainId: state.fromChainIdFilter,
        toChainId: state.toChainIdFilter,
        status: state.statusFilter,
      );

      final transactions = result['data'] as List<TransactionJob>;
      final meta = result['meta'] as Map<String, dynamic>;
      final totalPages = meta['lastPage'] as int;

      state = state.copyWith(
        isLoading: false,
        transactions: refresh
            ? transactions
            : [...state.transactions, ...transactions],
        totalPages: totalPages,
        hasMore: state.currentPage < totalPages,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(
      currentPage: state.currentPage + 1,
    );

    await loadTransactions();
  }

  void applyFilters({
    String? statusFilter,
    int? fromChainIdFilter,
    int? toChainIdFilter,
  }) {
    state = state.copyWith(
      statusFilter: statusFilter,
      fromChainIdFilter: fromChainIdFilter,
      toChainIdFilter: toChainIdFilter,
    );

    loadTransactions(refresh: true);
  }

  void clearFilters() {
    state = state.copyWith(
      statusFilter: null,
      fromChainIdFilter: null,
      toChainIdFilter: null,
    );

    loadTransactions(refresh: true);
  }
}

final activityProvider = StateNotifierProvider<ActivityNotifier, ActivityState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ActivityNotifier(apiService);
});
