import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import '../../constants/app_constants.dart';
import 'wallet_service_interface.dart';

// Ezt az implementációt egyszerűsítettük, mivel a walletconnect API változott
class WalletConnectService implements WalletServiceInterface {
  // Állapot
  bool _isConnected = false;
  String? _sessionTopic;
  String? _currentAddress;
  int? _currentChainId;
  List<String> _accounts = [];
  
  // Stream controller az események küldéséhez
  final _accountsChangedController = StreamController<List<String>>.broadcast();
  final _chainChangedController = StreamController<int>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();
  
  // Getterek
  bool get isConnected => _isConnected;
  String? get currentAddress => _currentAddress;
  int? get currentChainId => _currentChainId;
  Stream<List<String>> get onAccountsChanged => _accountsChangedController.stream;
  Stream<int> get onChainChanged => _chainChangedController.stream;
  Stream<bool> get onConnectionStatusChanged => _connectionStatusController.stream;
  
  // Konstruktor
  WalletConnectService() {
    _initializeClient();
  }
  
  // WalletConnect kliens inicializálása
  Future<void> _initializeClient() async {
    // Ez egy vázlatos implementáció, a valós implementáció más lenne
    debugPrint('Initializing WalletConnect client');
  }
  
  // QR kód URI generálása
  Future<String> generateQrCodeUri() async {
    // Ez egy példa URI a demonstrációhoz
    return 'wc:00e46b69-d0cc-4b3e-b6a2-cee442f97188@1?bridge=https%3A%2F%2Fbridge.walletconnect.org&key=91303352ac292fc6a7034a27ef6546dbbf74c06187ee09bfeaa3118a53be4e7';
  }
  
  // WalletServiceInterface implementációk
  
  @override
  Future<bool> connect() async {
    try {
      debugPrint('Connecting to WalletConnect');
      
      // Szimulált kapcsolódás
      await Future.delayed(const Duration(seconds: 1));
      
      // Csak visszatérünk false-al, majd a QR kód szkennelésével csatlakozna valójában
      return false;
    } catch (e) {
      debugPrint('WalletConnect connection failed: $e');
      return false;
    }
  }
  
  @override
  Future<void> disconnect() async {
    try {
      debugPrint('Disconnecting from WalletConnect');
      
      // Állapot visszaállítása
      _isConnected = false;
      _sessionTopic = null;
      _currentAddress = null;
      _currentChainId = null;
      _accounts = [];
      
      _connectionStatusController.add(false);
    } catch (e) {
      debugPrint('WalletConnect disconnect failed: $e');
    }
  }
  
  @override
  Future<String> getAddress() async {
    if (!_isConnected || _currentAddress == null) {
      throw Exception('Not connected to WalletConnect');
    }
    return _currentAddress!;
  }
  
  @override
  Future<double> getBalance() async {
    if (!_isConnected || _currentAddress == null || _currentChainId == null) {
      throw Exception('Not connected to WalletConnect');
    }
    
    // Lekérjük a lánc információkat
    final chainInfo = AppConstants.supportedChains.firstWhere(
      (chain) => chain['chainId'] == _currentChainId,
      orElse: () => {'rpcUrl': ''},
    );
    
    if (chainInfo['rpcUrl'] == null || chainInfo['rpcUrl'] == '') {
      throw Exception('Chain not supported');
    }
    
    // Használjuk a web3dart könyvtárat az egyenleg lekérdezéséhez
    final client = Web3Client(chainInfo['rpcUrl'] as String, Client());
    try {
      final balance = await client.getBalance(EthereumAddress.fromHex(_currentAddress!));
      // Konvertáljuk wei-ből ether-be
      return balance.getValueInUnit(EtherUnit.ether);
    } finally {
      client.dispose();
    }
  }
  
  @override
  Future<String> sendTransaction({
    required String to,
    required double amount,
    required int chainId,
  }) async {
    if (!_isConnected || _currentAddress == null) {
      throw Exception('Not connected to WalletConnect');
    }
    
    // Ellenőrizzük, hogy a megfelelő láncon vagyunk-e
    if (_currentChainId != chainId) {
      await switchChain(chainId);
    }
    
    // Szimulált tranzakció küldése
    await Future.delayed(const Duration(seconds: 2));
    
    // Példa tranzakció hash
    return '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
  }
  
  @override
  Future<void> switchChain(int chainId) async {
    if (!_isConnected) {
      throw Exception('Not connected to WalletConnect');
    }
    
    try {
      // Szimulált lánc váltás
      await Future.delayed(const Duration(seconds: 1));
      
      _currentChainId = chainId;
      _chainChangedController.add(chainId);
    } catch (e) {
      throw Exception('Failed to switch chain: $e');
    }
  }
  
  // Szimulált kapcsolódás
  Future<void> simulateConnection(String address, int chainId) async {
    _isConnected = true;
    _currentAddress = address;
    _currentChainId = chainId;
    _accounts = [address];
    _sessionTopic = 'simulated-session';
    
    _accountsChangedController.add(_accounts);
    _chainChangedController.add(chainId);
    _connectionStatusController.add(true);
  }
  
  @override
  void dispose() {
    _accountsChangedController.close();
    _chainChangedController.close();
    _connectionStatusController.close();
  }
}

// Provider a WalletConnect szolgáltatáshoz
final walletConnectServiceProvider = Provider<WalletConnectService>((ref) {
  final service = WalletConnectService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});
