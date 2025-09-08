import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/transaction_job.dart';

class TransactionDetailsState {
  final bool isLoading;
  final TransactionJob? transaction;
  final String? error;
  final bool isRefreshing;

  const TransactionDetailsState({
    this.isLoading = false,
    this.transaction,
    this.error,
    this.isRefreshing = false,
  });

  TransactionDetailsState copyWith({
    bool? isLoading,
    TransactionJob? transaction,
    String? error,
    bool? isRefreshing,
  }) {
    return TransactionDetailsState(
      isLoading: isLoading ?? this.isLoading,
      transaction: transaction ?? this.transaction,
      error: error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class TransactionDetailsNotifier extends StateNotifier<TransactionDetailsState> {
  final ApiService _apiService;
  final String transactionId;

  TransactionDetailsNotifier(this._apiService, this.transactionId)
      : super(const TransactionDetailsState(isLoading: true)) {
    loadTransaction();
  }

  Future<void> loadTransaction() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final transaction = await _apiService.getTransactionJob(transactionId);
      state = state.copyWith(
        isLoading: false,
        transaction: transaction,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> refreshTransaction() async {
    state = state.copyWith(isRefreshing: true, error: null);
    try {
      final transaction = await _apiService.getTransactionJob(transactionId);
      state = state.copyWith(
        isRefreshing: false,
        transaction: transaction,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

final transactionDetailsProvider = StateNotifierProvider.family
    TransactionDetailsNotifier, TransactionDetailsState, String>(
  (ref, transactionId) {
    final apiService = ref.watch(apiServiceProvider);
    return TransactionDetailsNotifier(apiService, transactionId);
  },
);
