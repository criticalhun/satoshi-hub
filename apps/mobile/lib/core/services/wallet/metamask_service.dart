import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import '../../constants/app_constants.dart';
import 'wallet_service_interface.dart';

// Ethereum RPC kérés típusok
enum EthMethod {
  requestAccounts,
  sendTransaction,
  signMessage,
  signTypedData,
  switchChain,
  addChain,
}

// MetaMask szolgáltatás, amely kezeli a böngészőben elérhető ethereum objektumot
class MetamaskService implements WalletServiceInterface {
  // Állapot
  bool _isConnected = false;
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
  MetamaskService() {
    _initListeners();
  }
  
  // Inicializáljuk az eseményfigyelőket
  void _initListeners() {
    if (kIsWeb) {
      // Ethereum objektum meglétének ellenőrzése
      _executeRawJs('''
        if (typeof window.ethereum !== 'undefined') {
          window.ethereum.on('accountsChanged', (accounts) => {
            window.dispatchEvent(new CustomEvent('accountsChanged', {detail: JSON.stringify(accounts)}));
          });
          
          window.ethereum.on('chainChanged', (chainId) => {
            window.dispatchEvent(new CustomEvent('chainChanged', {detail: chainId}));
          });
          
          window.ethereum.on('connect', (connectInfo) => {
            window.dispatchEvent(new CustomEvent('walletConnect', {detail: JSON.stringify(connectInfo)}));
          });
          
          window.ethereum.on('disconnect', (error) => {
            window.dispatchEvent(new CustomEvent('walletDisconnect', {detail: JSON.stringify(error)}));
          });
        }
      ''');
      
      // JavaScript eseményfigyelők dart oldali kezelése
      _addJsEventListener('accountsChanged', (event) {
        final accounts = jsonDecode(event.detail) as List<dynamic>;
        _accounts = accounts.map((acc) => acc.toString()).toList();
        _currentAddress = _accounts.isNotEmpty ? _accounts[0] : null;
        _accountsChangedController.add(_accounts);
      });
      
      _addJsEventListener('chainChanged', (event) {
        // A chainId hexadecimális formában érkezik
        final chainIdHex = event.detail as String;
        _currentChainId = int.parse(chainIdHex.replaceFirst('0x', ''), radix: 16);
        _chainChangedController.add(_currentChainId!);
      });
      
      _addJsEventListener('walletConnect', (event) {
        _isConnected = true;
        _connectionStatusController.add(true);
      });
      
      _addJsEventListener('walletDisconnect', (event) {
        _isConnected = false;
        _currentAddress = null;
        _accounts = [];
        _connectionStatusController.add(false);
      });
    }
  }
  
  // JavaScript eseményfigyelő hozzáadása
  void _addJsEventListener(String eventName, Function(dynamic) callback) {
    if (kIsWeb) {
      _executeRawJs('''
        window.addEventListener('$eventName', function(e) {
          window.flutterCallback_$eventName(e);
        });
      ''');
      
      // Beállítjuk a Dart callback-et
      // Ezt a valós implementációban a js könyvtárral kellene megoldani
      // Itt csak az ötletet mutatjuk be
    }
  }
  
  // JavaScript kód végrehajtása
  dynamic _executeRawJs(String code) {
    if (kIsWeb) {
      // Ezt a valós implementációban a js könyvtárral kellene megoldani
      // Itt csak az ötletet mutatjuk be
      return null;
    }
    return null;
  }
  
  // Az ethereum metódus meghívása
  Future<dynamic> _callEthMethod(EthMethod method, [List<dynamic> params = const []]) async {
    if (!kIsWeb) {
      throw Exception('MetaMask only available in web environment');
    }
    
    String methodName;
    switch (method) {
      case EthMethod.requestAccounts:
        methodName = 'eth_requestAccounts';
        break;
      case EthMethod.sendTransaction:
        methodName = 'eth_sendTransaction';
        break;
      case EthMethod.signMessage:
        methodName = 'personal_sign';
        break;
      case EthMethod.signTypedData:
        methodName = 'eth_signTypedData_v4';
        break;
      case EthMethod.switchChain:
        methodName = 'wallet_switchEthereumChain';
        break;
      case EthMethod.addChain:
        methodName = 'wallet_addEthereumChain';
        break;
    }
    
    final script = '''
      (async () => {
        try {
          if (typeof window.ethereum === 'undefined') {
            return JSON.stringify({ error: 'MetaMask not installed' });
          }
          
          const result = await window.ethereum.request({
            method: '$methodName',
            params: ${jsonEncode(params)}
          });
          
          return JSON.stringify({ result: result });
        } catch (error) {
          return JSON.stringify({ error: error.message });
        }
      })();
    ''';
    
    final response = await _executeRawJsWithResult(script);
    final jsonResponse = jsonDecode(response);
    
    if (jsonResponse['error'] != null) {
      throw Exception(jsonResponse['error']);
    }
    
    return jsonResponse['result'];
  }
  
  // JavaScript kód végrehajtása eredménnyel
  Future<String> _executeRawJsWithResult(String code) async {
    if (kIsWeb) {
      // Ezt a valós implementációban a js könyvtárral kellene megoldani
      // Itt csak az ötletet mutatjuk be
      return '{"result": null}';
    }
    return '{"error": "Not web environment"}';
  }
  
  // WalletServiceInterface implementációk
  
  @override
  Future<bool> connect() async {
    try {
      final accounts = await _callEthMethod(EthMethod.requestAccounts);
      _accounts = (accounts as List<dynamic>).map((acc) => acc.toString()).toList();
      _currentAddress = _accounts.isNotEmpty ? _accounts[0] : null;
      
      // Lekérjük az aktuális lánc azonosítót
      final chainIdHex = await _executeRawJsWithResult('''
        (async () => {
          try {
            return JSON.stringify({ result: await window.ethereum.request({ method: 'eth_chainId' }) });
          } catch (error) {
            return JSON.stringify({ error: error.message });
          }
        })();
      ''');
      
      final chainIdJson = jsonDecode(chainIdHex);
      if (chainIdJson['result'] != null) {
        final hexChainId = chainIdJson['result'] as String;
        _currentChainId = int.parse(hexChainId.replaceFirst('0x', ''), radix: 16);
      }
      
      _isConnected = _currentAddress != null;
      _connectionStatusController.add(_isConnected);
      
      return _isConnected;
    } catch (e) {
      _isConnected = false;
      _connectionStatusController.add(false);
      return false;
    }
  }
  
  @override
  Future<void> disconnect() async {
    // MetaMask nem támogatja a programozott lecsatlakozást
    // Csak törölhetjük a helyi állapotot
    _isConnected = false;
    _currentAddress = null;
    _accounts = [];
    _currentChainId = null;
    _connectionStatusController.add(false);
  }
  
  @override
  Future<String> getAddress() async {
    if (!_isConnected || _currentAddress == null) {
      throw Exception('Not connected to MetaMask');
    }
    return _currentAddress!;
  }
  
  @override
  Future<double> getBalance() async {
    if (!_isConnected || _currentAddress == null || _currentChainId == null) {
      throw Exception('Not connected to MetaMask');
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
      throw Exception('Not connected to MetaMask');
    }
    
    // Ellenőrizzük, hogy a megfelelő láncon vagyunk-e
    if (_currentChainId != chainId) {
      await switchChain(chainId);
    }
    
    // Létrehozzuk a tranzakciós paramétert
    final params = [{
      'from': _currentAddress,
      'to': to,
      'value': '0x${BigInt.from(amount * 1e18).toRadixString(16)}', // wei-ben
    }];
    
    // Küldjük a tranzakciót
    final txHash = await _callEthMethod(EthMethod.sendTransaction, params);
    return txHash as String;
  }
  
  @override
  Future<void> switchChain(int chainId) async {
    // Hexadecimális chainId
    final hexChainId = '0x${chainId.toRadixString(16)}';
    
    try {
      await _callEthMethod(EthMethod.switchChain, [{'chainId': hexChainId}]);
      _currentChainId = chainId;
      _chainChangedController.add(chainId);
    } catch (e) {
      // Ha a lánc nem létezik, megpróbáljuk hozzáadni
      final chainInfo = AppConstants.supportedChains.firstWhere(
        (chain) => chain['chainId'] == chainId,
        orElse: () => {},
      );
      
      if (chainInfo.isNotEmpty) {
        await _addChain(chainInfo);
      } else {
        rethrow;
      }
    }
  }
  
  // Új lánc hozzáadása a MetaMask-hoz
  Future<void> _addChain(Map<String, dynamic> chainInfo) async {
    final params = [{
      'chainId': '0x${chainInfo['chainId'].toRadixString(16)}',
      'chainName': chainInfo['name'],
      'rpcUrls': [chainInfo['rpcUrl']],
      'nativeCurrency': {
        'name': chainInfo['symbol'],
        'symbol': chainInfo['symbol'],
        'decimals': 18,
      },
      'blockExplorerUrls': [chainInfo['blockExplorer']],
    }];
    
    await _callEthMethod(EthMethod.addChain, params);
    _currentChainId = chainInfo['chainId'] as int;
    _chainChangedController.add(_currentChainId!);
  }
  
  // Üzenet aláírása
  Future<String> signMessage(String message) async {
    if (!_isConnected || _currentAddress == null) {
      throw Exception('Not connected to MetaMask');
    }
    
    // Átalakítjuk az üzenetet hexadecimális formátumra
    final encodedMessage = utf8.encode(message);
    final hexMessage = '0x${encodedMessage.map((e) => e.toRadixString(16).padLeft(2, '0')).join('')}';
    
    final signature = await _callEthMethod(EthMethod.signMessage, [hexMessage, _currentAddress]);
    return signature as String;
  }
  
  // Felszabadítjuk az erőforrásokat
  @override
  void dispose() {
    _accountsChangedController.close();
    _chainChangedController.close();
    _connectionStatusController.close();
  }
}

// Provider a MetaMask szolgáltatáshoz
final metamaskServiceProvider = Provider<MetamaskService>((ref) {
  final service = MetamaskService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});
