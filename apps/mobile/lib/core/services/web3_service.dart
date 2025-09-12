import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:satoshi_hub/core/services/chain_service.dart';

enum TransactionStatus {
  pending,
  confirmed,
  failed,
}

class TransactionDetails {
  final String hash;
  final String from;
  final String to;
  final String? data;
  final String value;
  final int chainId;
  final int gasLimit;
  final String gasPrice;
  final TransactionStatus status;
  final DateTime timestamp;
  final int? confirmations;
  final String? errorMessage;
  
  TransactionDetails({
    required this.hash,
    required this.from,
    required this.to,
    this.data,
    required this.value,
    required this.chainId,
    required this.gasLimit,
    required this.gasPrice,
    required this.status,
    required this.timestamp,
    this.confirmations,
    this.errorMessage,
  });
}

class GasPrice {
  final String slow;
  final String standard;
  final String fast;
  final DateTime lastUpdated;
  
  GasPrice({
    required this.slow,
    required this.standard,
    required this.fast,
    required this.lastUpdated,
  });
}

class Web3Service extends ChangeNotifier {
  final ChainService _chainService;
  final Random _random = Random();
  
  // Cache for gas prices by chain
  final Map<int, GasPrice> _gasPrices = {};
  
  // Transaction records
  final List<TransactionDetails> _transactions = [];
  
  // Current gas price preference
  String _gasPreference = 'standard'; // 'slow', 'standard', 'fast'
  
  // Getters
  List<TransactionDetails> get transactions => _transactions;
  String get gasPreference => _gasPreference;
  Map<int, GasPrice> get gasPrices => _gasPrices;
  
  // Constructor
  Web3Service({required ChainService chainService})
      : _chainService = chainService {
    _initializeGasPrices();
  }
  
  // Initialize gas prices for all chains
  void _initializeGasPrices() {
    for (final chain in _chainService.chains) {
      _updateGasPriceForChain(chain.chainId);
    }
  }
  
  // Update gas price for a specific chain
  Future<void> _updateGasPriceForChain(int chainId) async {
    // In a real implementation, we would query the network
    // For this demo, we'll generate mock data
    
    String slow;
    String standard;
    String fast;
    
    switch (chainId) {
      case 11155111: // Sepolia (Ethereum)
        slow = '${15 + _random.nextInt(5)}';
        standard = '${25 + _random.nextInt(10)}';
        fast = '${40 + _random.nextInt(20)}';
        break;
      case 421613: // Arbitrum Goerli
        slow = '${0.1 + _random.nextDouble() * 0.1}';
        standard = '${0.3 + _random.nextDouble() * 0.2}';
        fast = '${0.7 + _random.nextDouble() * 0.3}';
        break;
      case 420: // Optimism Goerli
        slow = '${0.2 + _random.nextDouble() * 0.1}';
        standard = '${0.4 + _random.nextDouble() * 0.2}';
        fast = '${0.8 + _random.nextDouble() * 0.3}';
        break;
      case 80001: // Mumbai (Polygon)
        slow = '${30 + _random.nextInt(20)}';
        standard = '${60 + _random.nextInt(30)}';
        fast = '${100 + _random.nextInt(50)}';
        break;
      case 97: // BNB Testnet
        slow = '${3 + _random.nextInt(2)}';
        standard = '${6 + _random.nextInt(3)}';
        fast = '${10 + _random.nextInt(5)}';
        break;
      case 43113: // Avalanche Fuji
        slow = '${25 + _random.nextInt(10)}';
        standard = '${40 + _random.nextInt(15)}';
        fast = '${60 + _random.nextInt(20)}';
        break;
      default:
        slow = '5';
        standard = '10';
        fast = '20';
    }
    
    _gasPrices[chainId] = GasPrice(
      slow: slow,
      standard: standard,
      fast: fast,
      lastUpdated: DateTime.now(),
    );
    
    notifyListeners();
  }
  
  // Set gas price preference
  void setGasPreference(String preference) {
    if (_gasPreference != preference) {
      _gasPreference = preference;
      notifyListeners();
    }
  }
  
  // Get current gas price for a chain based on preference
  String getGasPrice(int chainId) {
    final gasPrice = _gasPrices[chainId];
    if (gasPrice == null) return '0';
    
    switch (_gasPreference) {
      case 'slow':
        return gasPrice.slow;
      case 'fast':
        return gasPrice.fast;
      case 'standard':
      default:
        return gasPrice.standard;
    }
  }
  
  // Update gas prices
  Future<void> updateGasPrices() async {
    for (final chainId in _gasPrices.keys) {
      await _updateGasPriceForChain(chainId);
    }
  }
  
  // Send a transaction
  Future<TransactionDetails> sendTransaction({
    required int chainId,
    required String to,
    required String value,
    String? data,
  }) async {
    // In a real implementation, we would use web3 library to send the transaction
    // For this demo, we'll simulate it
    
    // Generate a random hash
    final hash = '0x' + List.generate(64, (_) => _random.nextInt(16).toRadixString(16)).join();
    
    // Create transaction details
    final tx = TransactionDetails(
      hash: hash,
      from: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e', // Mock address
      to: to,
      data: data,
      value: value,
      chainId: chainId,
      gasLimit: 21000 + (_random.nextInt(50000)),
      gasPrice: getGasPrice(chainId),
      status: TransactionStatus.pending,
      timestamp: DateTime.now(),
    );
    
    // Add to transactions list
    _transactions.add(tx);
    notifyListeners();
    
    // Simulate transaction confirmation after delay
    await _simulateTransaction(tx);
    
    return tx;
  }
  
  // Simulate transaction confirmation
  Future<void> _simulateTransaction(TransactionDetails tx) async {
    // Wait for a random time between 1-5 seconds
    await Future.delayed(Duration(milliseconds: 1000 + _random.nextInt(4000)));
    
    // 90% chance of success
    final success = _random.nextDouble() < 0.9;
    
    // Update transaction status
    final index = _transactions.indexWhere((t) => t.hash == tx.hash);
    if (index >= 0) {
      final updatedTx = TransactionDetails(
        hash: tx.hash,
        from: tx.from,
        to: tx.to,
        data: tx.data,
        value: tx.value,
        chainId: tx.chainId,
        gasLimit: tx.gasLimit,
        gasPrice: tx.gasPrice,
        status: success ? TransactionStatus.confirmed : TransactionStatus.failed,
        timestamp: tx.timestamp,
        confirmations: success ? 1 + _random.nextInt(10) : 0,
        errorMessage: success ? null : _getRandomErrorMessage(),
      );
      
      _transactions[index] = updatedTx;
      notifyListeners();
    }
  }
  
  // Get a random error message
  String _getRandomErrorMessage() {
    final errors = [
      'Transaction underpriced',
      'Insufficient funds for gas * price + value',
      'Intrinsic gas too low',
      'Execution reverted',
      'Transaction rejected by user',
      'Nonce too low',
      'Already known',
    ];
    
    return errors[_random.nextInt(errors.length)];
  }
  
  // Get transaction by hash
  TransactionDetails? getTransaction(String hash) {
    return _transactions.firstWhere((tx) => tx.hash == hash, orElse: () => null as TransactionDetails);
  }
  
  // Get transactions for a specific chain
  List<TransactionDetails> getTransactionsForChain(int chainId) {
    return _transactions.where((tx) => tx.chainId == chainId).toList();
  }
  
  // Get gas used for a transaction (simulate)
  int getGasUsed(String hash) {
    final tx = getTransaction(hash);
    if (tx == null) return 0;
    
    // Simulate gas used (60-100% of gas limit)
    return (tx.gasLimit * (0.6 + _random.nextDouble() * 0.4)).round();
  }
  
  // Call contract view function (simulate)
  Future<String> callContractView({
    required int chainId,
    required String contractAddress,
    required String functionName,
    List<dynamic> params = const [],
  }) async {
    // In a real implementation, we would use web3 library to call the contract
    // For this demo, we'll simulate it
    
    // Simulate delay
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(700)));
    
    // Simulate result
    if (functionName == 'balanceOf') {
      return (1000 + _random.nextInt(9000)).toString();
    } else if (functionName == 'allowance') {
      return (10000 + _random.nextInt(90000)).toString();
    } else if (functionName == 'decimals') {
      return '18';
    } else if (functionName == 'name') {
      return 'Mock Token';
    } else if (functionName == 'symbol') {
      return 'MOCK';
    } else {
      return '0';
    }
  }
  
  // Estimate gas for a transaction
  Future<int> estimateGas({
    required int chainId,
    required String to,
    required String value,
    String? data,
  }) async {
    // In a real implementation, we would use web3 library to estimate gas
    // For this demo, we'll simulate it
    
    // Simulate delay
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));
    
    // Simulate result
    if (data == null || data.isEmpty) {
      // Basic transfer
      return 21000;
    } else {
      // Contract interaction
      return 50000 + _random.nextInt(100000);
    }
  }
  
  // Sign message (simulate)
  Future<String> signMessage(String message) async {
    // In a real implementation, we would use web3 library to sign the message
    // For this demo, we'll simulate it
    
    // Simulate delay
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(500)));
    
    // Generate a random signature
    return '0x' + List.generate(130, (_) => _random.nextInt(16).toRadixString(16)).join();
  }
  
  // Verify signature (simulate)
  Future<bool> verifySignature({
    required String message,
    required String signature,
    required String address,
  }) async {
    // In a real implementation, we would use web3 library to verify the signature
    // For this demo, we'll simulate it
    
    // Simulate delay
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(300)));
    
    // Simulate result (90% chance of success)
    return _random.nextDouble() < 0.9;
  }
}
