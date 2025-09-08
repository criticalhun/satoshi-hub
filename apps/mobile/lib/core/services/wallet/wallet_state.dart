import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A támogatott wallet típusok
enum WalletType {
  metamask,
  walletConnect,
  demo,
}

/// A wallet állapota
class WalletState {
  final bool isConnected;
  final String? address;
  final int? chainId;
  final double? balance;
  final WalletType? walletType;
  final String? error;
  final bool isLoading;

  const WalletState({
    this.isConnected = false,
    this.address,
    this.chainId,
    this.balance,
    this.walletType,
    this.error,
    this.isLoading = false,
  });

  WalletState copyWith({
    bool? isConnected,
    String? address,
    int? chainId,
    double? balance,
    WalletType? walletType,
    String? error,
    bool? isLoading,
    bool clearError = false,
  }) {
    return WalletState(
      isConnected: isConnected ?? this.isConnected,
      address: address ?? this.address,
      chainId: chainId ?? this.chainId,
      balance: balance ?? this.balance,
      walletType: walletType ?? this.walletType,
      error: clearError ? null : error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WalletStateNotifier extends StateNotifier<WalletState> {
  WalletStateNotifier() : super(const WalletState());
}

// Provider a wallet állapothoz
final walletStateProvider = StateNotifierProvider<WalletStateNotifier, WalletState>((ref) {
  return WalletStateNotifier();
});
