import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/chain_info.dart';
import '../../../core/constants/app_constants.dart';

class BridgeState {
  final ChainInfo? fromChain;
  final ChainInfo? toChain;
  final String amount;
  final String toAddress;
  final bool isLoading;
  final String? error;

  const BridgeState({
    this.fromChain,
    this.toChain,
    this.amount = '',
    this.toAddress = '',
    this.isLoading = false,
    this.error,
  });

  BridgeState copyWith({
    ChainInfo? fromChain,
    ChainInfo? toChain,
    String? amount,
    String? toAddress,
    bool? isLoading,
    String? error,
  }) {
    return BridgeState(
      fromChain: fromChain ?? this.fromChain,
      toChain: toChain ?? this.toChain,
      amount: amount ?? this.amount,
      toAddress: toAddress ?? this.toAddress,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BridgeNotifier extends StateNotifier<BridgeState> {
  BridgeNotifier() : super(const BridgeState());

  void setFromChain(ChainInfo chain) {
    state = state.copyWith(fromChain: chain, error: null);
  }

  void setToChain(ChainInfo chain) {
    state = state.copyWith(toChain: chain, error: null);
  }

  void setAmount(String amount) {
    state = state.copyWith(amount: amount, error: null);
  }

  void setToAddress(String address) {
    state = state.copyWith(toAddress: address, error: null);
  }

  void swapChains() {
    final fromChain = state.fromChain;
    final toChain = state.toChain;
    
    state = state.copyWith(
      fromChain: toChain,
      toChain: fromChain,
      error: null,
    );
  }

  Future<void> submitBridge() async {
    if (!_validateForm()) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implement actual bridge API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate success
      state = state.copyWith(
        isLoading: false,
        amount: '',
        toAddress: '',
      );
      
      // TODO: Show success message and navigate
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Bridge failed: ${e.toString()}',
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
    
    if (state.amount.isEmpty || double.tryParse(state.amount) == null) {
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
  return BridgeNotifier();
});

// Available chains provider
final availableChainsProvider = Provider<List<ChainInfo>>((ref) {
  return AppConstants.supportedChains
      .map((chainData) => ChainInfo.fromJson(chainData))
      .toList();
});
