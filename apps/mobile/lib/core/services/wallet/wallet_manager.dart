import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import 'wallet_service_interface.dart';
import 'metamask_service.dart';
import 'wallet_connect_service.dart';
import 'wallet_state.dart';

/// A wallet manager, amely központilag kezeli a különböző wallet integrációkat
class WalletManager {
  // Szolgáltatások
  final MetamaskService _metamaskService;
  final WalletConnectService _walletConnectService;
  
  // Állapot notifier
  final StateNotifier<WalletState> _stateNotifier;
  
  // Stream előfizetések
  List<StreamSubscription> _subscriptions = [];
  
  // Getterek
  WalletState get currentState => _stateNotifier.state;
  
  // Konstruktor
  WalletManager(this._metamaskService, this._walletConnectService, this._stateNotifier) {
    _setupListeners();
  }
  
  // Inicializálás
  void _setupListeners() {
    // MetaMask eseményfigyelők
    _subscriptions.add(
      _metamaskService.onAccountsChanged.listen((accounts) {
        if (currentState.walletType == WalletType.metamask) {
          _updateState(
            address: accounts.isNotEmpty ? accounts[0] : null,
            isConnected: accounts.isNotEmpty,
          );
          
          // Frissítjük az egyenleget, ha van aktív számla
          if (accounts.isNotEmpty) {
            _refreshBalance();
          }
        }
      })
    );
    
    _subscriptions.add(
      _metamaskService.onChainChanged.listen((chainId) {
        if (currentState.walletType == WalletType.metamask) {
          _updateState(chainId: chainId);
          
          // Frissítjük az egyenleget a lánc váltás után
          _refreshBalance();
        }
      })
    );
    
    _subscriptions.add(
      _metamaskService.onConnectionStatusChanged.listen((isConnected) {
        if (currentState.walletType == WalletType.metamask) {
          _updateState(
            isConnected: isConnected,
            address: isConnected ? currentState.address : null,
          );
        }
      })
    );
    
    // WalletConnect eseményfigyelők
    _subscriptions.add(
      _walletConnectService.onAccountsChanged.listen((accounts) {
        if (currentState.walletType == WalletType.walletConnect) {
          _updateState(
            address: accounts.isNotEmpty ? accounts[0] : null,
            isConnected: accounts.isNotEmpty,
          );
          
          // Frissítjük az egyenleget, ha van aktív számla
          if (accounts.isNotEmpty) {
            _refreshBalance();
          }
        }
      })
    );
    
    _subscriptions.add(
      _walletConnectService.onChainChanged.listen((chainId) {
        if (currentState.walletType == WalletType.walletConnect) {
          _updateState(chainId: chainId);
          
          // Frissítjük az egyenleget a lánc váltás után
          _refreshBalance();
        }
      })
    );
    
    _subscriptions.add(
      _walletConnectService.onConnectionStatusChanged.listen((isConnected) {
        if (currentState.walletType == WalletType.walletConnect) {
          _updateState(
            isConnected: isConnected,
            address: isConnected ? currentState.address : null,
          );
        }
      })
    );
  }
  
  // Állapot frissítése
  void _updateState({
    bool? isConnected,
    String? address,
    int? chainId,
    double? balance,
    WalletType? walletType,
    String? error,
    bool? isLoading,
    bool clearError = false,
  }) {
    if (_stateNotifier is WalletStateNotifier) {
      final notifier = _stateNotifier as WalletStateNotifier;
      notifier.state = currentState.copyWith(
        isConnected: isConnected,
        address: address,
        chainId: chainId,
        balance: balance,
        walletType: walletType,
        error: error,
        isLoading: isLoading,
        clearError: clearError,
      );
    }
  }
  
  // Egyenleg frissítése
  Future<void> _refreshBalance() async {
    if (!currentState.isConnected || currentState.address == null) {
      return;
    }
    
    _updateState(isLoading: true, clearError: true);
    
    try {
      final service = _getActiveService();
      if (service != null) {
        final balance = await service.getBalance();
        _updateState(balance: balance, isLoading: false);
      } else {
        _updateState(isLoading: false);
      }
    } catch (e) {
      _updateState(
        error: 'Failed to fetch balance: ${e.toString()}',
        isLoading: false,
      );
    }
  }
  
  // Az aktív wallet szolgáltatás lekérdezése
  WalletServiceInterface? _getActiveService() {
    switch (currentState.walletType) {
      case WalletType.metamask:
        return _metamaskService;
      case WalletType.walletConnect:
        return _walletConnectService;
      default:
        return null;
    }
  }
  
  /// Csatlakozás demo módban
  Future<bool> connectDemo() async {
    _updateState(isLoading: true, clearError: true);
    
    try {
      // Kis késleltetés a demo kapcsolódás szimulálásához
      await Future.delayed(const Duration(seconds: 1));
      
      // Demo cím generálása
      final address = '0x' + List.generate(40, (index) => 
        '0123456789abcdef'[math.Random().nextInt(16)]).join('');
      
      // Demo lánc ID
      final chainId = AppConstants.supportedChains.first['chainId'] as int;
      
      // Frissítjük az állapotot
      _updateState(
        isConnected: true,
        address: address,
        chainId: chainId,
        balance: 10.0, // Demo egyenleg
        walletType: WalletType.demo, // Demo wallet típus
        isLoading: false,
      );
      
      return true;
    } catch (e) {
      _updateState(
        isConnected: false,
        walletType: null,
        error: 'Error connecting in demo mode: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }
  
  /// Csatlakozás a MetaMask wallet-hez
  Future<bool> connectMetamask() async {
    // Csak web környezetben támogatott
    if (!kIsWeb) {
      _updateState(
        error: 'MetaMask is only available in web browsers',
        walletType: null,
      );
      return false;
    }
    
    _updateState(isLoading: true, clearError: true);
    
    try {
      final connected = await _metamaskService.connect();
      
      if (connected) {
        final address = await _metamaskService.getAddress();
        final chainId = _metamaskService.currentChainId;
        
        _updateState(
          isConnected: true,
          address: address,
          chainId: chainId,
          walletType: WalletType.metamask,
          isLoading: false,
        );
        
        // Egyenleg lekérdezése
        _refreshBalance();
        
        return true;
      } else {
        _updateState(
          isConnected: false,
          walletType: null,
          error: 'Failed to connect to MetaMask',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      _updateState(
        isConnected: false,
        walletType: null,
        error: 'Error connecting to MetaMask: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }
  
  /// WalletConnect QR kód generálása
  Future<String> generateWalletConnectQrCode() async {
    _updateState(isLoading: true, clearError: true);
    
    try {
      final uri = await _walletConnectService.generateQrCodeUri();
      
      _updateState(
        walletType: WalletType.walletConnect,
        isLoading: false,
      );
      
      return uri;
    } catch (e) {
      _updateState(
        walletType: null,
        error: 'Error generating WalletConnect QR code: ${e.toString()}',
        isLoading: false,
      );
      rethrow;
    }
  }
  
  /// Tranzakció küldése
  Future<String> sendTransaction({
    required String to,
    required double amount,
    required int chainId,
  }) async {
    if (!currentState.isConnected) {
      throw Exception('Not connected to any wallet');
    }
    
    final service = _getActiveService();
    if (service == null) {
      throw Exception('No active wallet service');
    }
    
    _updateState(isLoading: true, clearError: true);
    
    try {
      final txHash = await service.sendTransaction(
        to: to,
        amount: amount,
        chainId: chainId,
      );
      
      _updateState(isLoading: false);
      
      // Frissítjük az egyenleget a tranzakció után
      _refreshBalance();
      
      return txHash;
    } catch (e) {
      _updateState(
        error: 'Transaction failed: ${e.toString()}',
        isLoading: false,
      );
      rethrow;
    }
  }
  
  /// Váltás a megadott láncra
  Future<void> switchChain(int chainId) async {
    if (!currentState.isConnected) {
      throw Exception('Not connected to any wallet');
    }
    
    final service = _getActiveService();
    if (service == null) {
      throw Exception('No active wallet service');
    }
    
    _updateState(isLoading: true, clearError: true);
    
    try {
      await service.switchChain(chainId);
      
      _updateState(
        chainId: chainId,
        isLoading: false,
      );
      
      // Frissítjük az egyenleget a lánc váltás után
      _refreshBalance();
    } catch (e) {
      _updateState(
        error: 'Failed to switch chain: ${e.toString()}',
        isLoading: false,
      );
      rethrow;
    }
  }
  
  /// Lecsatlakozás a wallet-ről
  Future<void> disconnect() async {
    if (!currentState.isConnected) {
      return;
    }
    
    final service = _getActiveService();
    if (service == null) {
      return;
    }
    
    _updateState(isLoading: true, clearError: true);
    
    try {
      await service.disconnect();
      
      _updateState(
        isConnected: false,
        address: null,
        chainId: null,
        balance: null,
        walletType: null,
        isLoading: false,
      );
    } catch (e) {
      _updateState(
        error: 'Failed to disconnect: ${e.toString()}',
        isLoading: false,
      );
    }
  }
  
  /// Egyenleg frissítése
  Future<void> refreshBalance() async {
    await _refreshBalance();
  }
  
  /// Erőforrások felszabadítása
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}

/// Wallet manager provider
final walletManagerProvider = Provider<WalletManager>((ref) {
  final metamaskService = ref.watch(metamaskServiceProvider);
  final walletConnectService = ref.watch(walletConnectServiceProvider);
  final stateNotifier = ref.watch(walletStateProvider.notifier);
  
  final manager = WalletManager(metamaskService, walletConnectService, stateNotifier);
  
  ref.onDispose(() {
    manager.dispose();
  });
  
  return manager;
});
