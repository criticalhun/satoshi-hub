import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:satoshi_hub/core/services/chain_service.dart';

class WalletService extends ChangeNotifier {
  bool _isConnected = false;
  String? _address;
  Map<int, BigInt> _balances = {}; // chainId -> balance
  int _chainId = 11155111; // Sepolia default
  final ChainService _chainService;
  
  // Getters
  bool get isConnected => _isConnected;
  String? get address => _address;
  BigInt? get balance => _balances[_chainId];
  int get chainId => _chainId;
  
  // Web3 client
  Map<int, Web3Client> _web3Clients = {};
  
  // Constructor
  WalletService({ChainService? chainService}) 
      : _chainService = chainService ?? ChainService() {
    _initWeb3Clients();
    _mockConnectedWallet();
  }
  
  // Initialize web3 clients
  void _initWeb3Clients() {
    for (final chain in _chainService.chains) {
      _web3Clients[chain.chainId] = Web3Client(chain.rpcUrl, http.Client());
    }
  }
  
  // Mock connected wallet for demo
  void _mockConnectedWallet() {
    _isConnected = true;
    _address = '0xa34205AC23d991Ee8fa44B63F76498aF7F4b1068';
    
    // Set mock balances for each chain
    _balances = {
      11155111: BigInt.parse('5000000000000000000'), // 5 ETH
      80001: BigInt.parse('10000000000000000000'), // 10 MATIC
      421613: BigInt.parse('3000000000000000000'), // 3 ETH (Arbitrum)
      420: BigInt.parse('4000000000000000000'), // 4 ETH (Optimism)
      97: BigInt.parse('20000000000000000000'), // 20 BNB
      43113: BigInt.parse('100000000000000000000'), // 100 AVAX
    };
    
    notifyListeners();
  }
  
  // Initialize
  Future<void> initialize() async {
    // In a real implementation, check if wallet is already connected
    // We're using mock data for now
    notifyListeners();
  }
  
  // Connect wallet
  Future<bool> connectWallet() async {
    try {
      // In a real implementation, connect to wallet
      // We're using mock data for now
      _isConnected = true;
      _address = '0xa34205AC23d991Ee8fa44B63F76498aF7F4b1068';
      
      // Mock balances
      _balances = {
        11155111: BigInt.parse('5000000000000000000'), // 5 ETH
        80001: BigInt.parse('10000000000000000000'), // 10 MATIC
        421613: BigInt.parse('3000000000000000000'), // 3 ETH (Arbitrum)
        420: BigInt.parse('4000000000000000000'), // 4 ETH (Optimism)
        97: BigInt.parse('20000000000000000000'), // 20 BNB
        43113: BigInt.parse('100000000000000000000'), // 100 AVAX
      };
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error connecting wallet: $e');
      return false;
    }
  }
  
  // Disconnect wallet
  Future<void> disconnectWallet() async {
    _isConnected = false;
    _address = null;
    _balances = {};
    notifyListeners();
  }
  
  // Switch chain
  Future<bool> switchChain(int newChainId) async {
    try {
      _chainId = newChainId;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error switching chain: $e');
      return false;
    }
  }
  
  // Format balance to readable string
  String formatBalance() {
    if (balance == null) return '0.0';
    // Convert wei to ether (1 ether = 10^18 wei)
    final etherValue = balance! / BigInt.parse('1000000000000000000');
    return etherValue.toStringAsFixed(4);
  }
  
  // Get chain name from chainId
  String getChainName() {
    return _chainService.getChainName(_chainId);
  }
  
  // Get token symbol for the current chain
  String getTokenSymbol() {
    return _chainService.getNativeTokenSymbol(_chainId);
  }
  
  // Get chain color
  Color getChainColor() {
    return _chainService.getChainColor(_chainId);
  }
  
  // Get balance for specific chain
  BigInt? getBalanceForChain(int chainId) {
    return _balances[chainId];
  }
  
  // Format balance for specific chain
  String formatBalanceForChain(int chainId) {
    final chainBalance = _balances[chainId];
    if (chainBalance == null) return '0.0';
    
    final etherValue = chainBalance / BigInt.parse('1000000000000000000');
    return etherValue.toStringAsFixed(4);
  }
}
