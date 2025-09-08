import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/chain_info.dart';
import '../../../core/constants/app_constants.dart';

class BridgeState {
  final ChainInfo? fromChain;
  final ChainInfo? toChain;
  final String amount;
  final String toAddress;
  final bool isLoading;
  final String? error;
  final String? successMessage;
  
  const BridgeState({
    this.fromChain,
    this.toChain,
    this.amount = '',
    this.toAddress = '',
    this.isLoading = false,
    this.error,
    this.successMessage,
  });
  
  BridgeState copyWith({
    ChainInfo? fromChain,
    ChainInfo? toChain,
    String? amount,
    String? toAddress,
    bool? isLoading,
    String? error,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return BridgeState(
      fromChain: fromChain ?? this.fromChain,
      toChain: toChain ?? this.toChain,
      amount: amount ?? this.amount,
      toAddress: toAddress ?? this.toAddress,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: clearSuccess ? null : successMessage ?? this.successMessage,
    );
  }
}

class BridgeNotifier extends StateNotifier<BridgeState> {
  final ApiService _apiService;
  
  BridgeNotifier(this._apiService) : super(const BridgeState());
  
  void setFromChain(ChainInfo chain) {
    state = state.copyWith(fromChain: chain, error: null, clearSuccess: true);
  }
  
  void setToChain(ChainInfo chain) {
    state = state.copyWith(toChain: chain, error: null, clearSuccess: true);
  }
  
  void setAmount(String amount) {
    state = state.copyWith(amount: amount, error: null, clearSuccess: true);
  }
  
  void setToAddress(String address) {
    state = state.copyWith(toAddress: address, error: null, clearSuccess: true);
  }
  
  void swapChains() {
    final fromChain = state.fromChain;
    final toChain = state.toChain;
    state = state.copyWith(fromChain: toChain, toChain: fromChain, error: null, clearSuccess: true);
  }
  
  Future<void> submitBridge() async {
    if (!_validateForm()) return;
    
    state = state.copyWith(isLoading: true, error: null, clearSuccess: true);
    
    try {
      final payload = {
        "fromChainId": state.fromChain!.chainId,
        "toChainId": state.toChain!.chainId,
        "payload": {
          "type": "NATIVE_TOKEN_TRANSFER",
          "to": state.toAddress,
          "amount": state.amount,
        }
      };
      
      final result = await _apiService.createTransactionJob(payload);
      
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Bridge job successfully created with ID: ${result.id}',
        amount: '',
        toAddress: '',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
  
  bool _validateForm() {
    if (state.fromChain == null) {
      state = state.copyWith(error: 'Please select source chain');
      return false;
    }
    if (state.toChain == null) {
      state = state.copyWith(error: 'Please select destination chain');
      return false;
    }
    if (state.fromChain?.chainId == state.toChain?.chainId) {
      state = state.copyWith(error: 'Source and destination chains must be different');
      return false;
    }
    if (state.amount.isEmpty || (double.tryParse(state.amount) ?? 0) <= 0) {
      state = state.copyWith(error: 'Please enter a valid amount');
      return false;
    }
    if (state.toAddress.isEmpty) {
      state = state.copyWith(error: 'Please enter destination address');
      return false;
    }
    return true;
  }
}

final bridgeProvider = StateNotifierProvider<BridgeNotifier, BridgeState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return BridgeNotifier(apiService);
});

// Available chains provider
final availableChainsProvider = Provider<List<ChainInfo>>((ref) {
  return AppConstants.supportedChains
    .map((chainData) => ChainInfo.fromJson(chainData))
    .toList();
});
