import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:satoshi_hub/core/services/local_storage_service.dart';
import 'package:satoshi_hub/core/services/api_client.dart';
import 'package:satoshi_hub/core/services/auth_service.dart';
import 'package:satoshi_hub/core/config/api_config.dart';
import 'package:satoshi_hub/core/dto/transaction_dto.dart';

enum TransactionStatus {
  pending,
  confirmed,
  failed,
}

enum TransactionType {
  send,
  receive,
  swap,
  bridge,
  stake,
  unstake,
}

class Transaction {
  final String id;
  final String hash;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime timestamp;
  final String from;
  final String to;
  final String amount;
  final String tokenSymbol;
  final int chainId;
  final String? bridgeProvider;
  final String? toChain;
  final String? fee;
  final String? feeToken;
  final String? error;
  
  // Additional fields needed by TransactionsScreen
  final int? fromChainId;
  final int? toChainId;
  final String? recipient;
  final String? txHash;
  final DateTime? createdAt;
  
  Transaction({
    required this.id,
    required this.hash,
    required this.type,
    required this.status,
    required this.timestamp,
    required this.from,
    required this.to,
    required this.amount,
    required this.tokenSymbol,
    required this.chainId,
    this.bridgeProvider,
    this.toChain,
    this.fee,
    this.feeToken,
    this.error,
    this.fromChainId,
    this.toChainId,
    this.recipient,
    this.txHash,
    this.createdAt,
  });
  
  // Convert to Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hash': hash,
      'type': type.toString(),
      'status': status.toString(),
      'timestamp': timestamp.toIso8601String(),
      'from': from,
      'to': to,
      'amount': amount,
      'tokenSymbol': tokenSymbol,
      'chainId': chainId,
      'bridgeProvider': bridgeProvider,
      'toChain': toChain,
      'fee': fee,
      'feeToken': feeToken,
      'error': error,
      'fromChainId': fromChainId,
      'toChainId': toChainId,
      'recipient': recipient,
      'txHash': txHash,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
  
  // Create from Map<String, dynamic>
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      hash: json['hash'],
      type: _typeFromString(json['type']),
      status: _statusFromString(json['status']),
      timestamp: DateTime.parse(json['timestamp']),
      from: json['from'],
      to: json['to'],
      amount: json['amount'],
      tokenSymbol: json['tokenSymbol'],
      chainId: json['chainId'],
      bridgeProvider: json['bridgeProvider'],
      toChain: json['toChain'],
      fee: json['fee'],
      feeToken: json['feeToken'],
      error: json['error'],
      fromChainId: json['fromChainId'],
      toChainId: json['toChainId'],
      recipient: json['recipient'],
      txHash: json['txHash'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
  
  // Helper to convert string to TransactionType
  static TransactionType _typeFromString(String typeStr) {
    switch (typeStr) {
      case 'TransactionType.send':
        return TransactionType.send;
      case 'TransactionType.receive':
        return TransactionType.receive;
      case 'TransactionType.swap':
        return TransactionType.swap;
      case 'TransactionType.bridge':
        return TransactionType.bridge;
      case 'TransactionType.stake':
        return TransactionType.stake;
      case 'TransactionType.unstake':
        return TransactionType.unstake;
      default:
        return TransactionType.send;
    }
  }
  
  // Helper to convert string to TransactionStatus
  static TransactionStatus _statusFromString(String statusStr) {
    switch (statusStr) {
      case 'TransactionStatus.pending':
        return TransactionStatus.pending;
      case 'TransactionStatus.confirmed':
        return TransactionStatus.confirmed;
      case 'TransactionStatus.failed':
        return TransactionStatus.failed;
      default:
        return TransactionStatus.pending;
    }
  }
}

class TransactionService extends ChangeNotifier {
  final LocalStorageService _localStorage;
  final AuthService _authService;
  final ApiClient _apiClient;
  final Random _random = Random();
  
  // List of transactions
  List<Transaction> _transactions = [];
  
  // State tracking
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Constructor
  TransactionService({
    required LocalStorageService localStorage,
    required AuthService authService,
  }) : _localStorage = localStorage,
       _authService = authService,
       _apiClient = ApiClient(authToken: authService.token) {
    _loadTransactions();
  }
  
  // Load transactions
  Future<void> _loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // First try to get transactions from API
      if (_authService.isAuthenticated) {
        await _fetchTransactionsFromApi();
      }
      
      // If API fails or no transactions, try local storage
      if (_transactions.isEmpty) {
        await _loadTransactionsFromStorage();
      }
    } catch (e) {
      _error = 'Error loading transactions: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Fetch transactions from API
  Future<void> _fetchTransactionsFromApi() async {
    try {
      // Attempt to fetch transactions from the API
      final response = await _apiClient.get<List<dynamic>>(
        ApiConfig.transactions,
      );
      
      if (response.success && response.data != null) {
        // Convert API response to Transaction objects
        _transactions = response.data!.map((item) {
          final dto = TransactionDTO.fromJson(item as Map<String, dynamic>);
          return dto.toTransaction();
        }).toList();
        
        // Save to local storage for offline use
        await _saveTransactions();
      } else {
        // If API call fails, use mock data for now
        print('API call failed: ${response.error}. Using mock data for now.');
        await _createMockTransactions();
      }
    } catch (e) {
      print('Error fetching transactions from API: ${e.toString()}. Using mock data for now.');
      await _createMockTransactions();
    }
  }
  
  // Create mock transactions for development
  Future<void> _createMockTransactions() async {
    final now = DateTime.now();
    
    // Add some mock bridge transactions
    _transactions = [
      Transaction(
        id: '1',
        hash: '0x' + List.generate(64, (_) => _random.nextInt(16).toRadixString(16)).join(),
        type: TransactionType.bridge,
        status: TransactionStatus.confirmed,
        timestamp: now.subtract(Duration(days: 1)),
        from: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        to: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        amount: '1.5',
        tokenSymbol: 'ETH',
        chainId: 11155111,
        bridgeProvider: 'Satoshi Bridge',
        toChain: '421613',
        fee: '0.015',
        feeToken: 'ETH',
        fromChainId: 11155111,
        toChainId: 421613,
        recipient: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        txHash: '0x' + List.generate(64, (_) => _random.nextInt(16).toRadixString(16)).join(),
        createdAt: now.subtract(Duration(days: 1)),
      ),
      Transaction(
        id: '2',
        hash: '0x' + List.generate(64, (_) => _random.nextInt(16).toRadixString(16)).join(),
        type: TransactionType.bridge,
        status: TransactionStatus.pending,
        timestamp: now.subtract(Duration(hours: 2)),
        from: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        to: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        amount: '100',
        tokenSymbol: 'USDC',
        chainId: 421613,
        bridgeProvider: 'Satoshi Bridge',
        toChain: '80001',
        fee: '1.0',
        feeToken: 'USDC',
        fromChainId: 421613,
        toChainId: 80001,
        recipient: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        txHash: '0x' + List.generate(64, (_) => _random.nextInt(16).toRadixString(16)).join(),
        createdAt: now.subtract(Duration(hours: 2)),
      ),
      Transaction(
        id: '3',
        hash: '0x' + List.generate(64, (_) => _random.nextInt(16).toRadixString(16)).join(),
        type: TransactionType.bridge,
        status: TransactionStatus.failed,
        timestamp: now.subtract(Duration(days: 3)),
        from: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        to: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        amount: '50',
        tokenSymbol: 'USDT',
        chainId: 80001,
        bridgeProvider: 'Satoshi Bridge',
        toChain: '43113',
        fee: '0.5',
        feeToken: 'USDT',
        error: 'Insufficient liquidity',
        fromChainId: 80001,
        toChainId: 43113,
        recipient: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        txHash: '0x' + List.generate(64, (_) => _random.nextInt(16).toRadixString(16)).join(),
        createdAt: now.subtract(Duration(days: 3)),
      ),
    ];
    
    // Add some mock send transactions
    _transactions.addAll([
      Transaction(
        id: '4',
        hash: '0x' + List.generate(64, (_) => _random.nextInt(16).toRadixString(16)).join(),
        type: TransactionType.send,
        status: TransactionStatus.confirmed,
        timestamp: now.subtract(Duration(hours: 12)),
        from: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        to: '0x9876543210987654321098765432109876543210',
        amount: '0.5',
        tokenSymbol: 'ETH',
        chainId: 11155111,
        fee: '0.001',
        feeToken: 'ETH',
        fromChainId: 11155111,
        recipient: '0x9876543210987654321098765432109876543210',
        txHash: '0x' + List.generate(64, (_) => _random.nextInt(16).toRadixString(16)).join(),
        createdAt: now.subtract(Duration(hours: 12)),
      ),
      Transaction(
        id: '5',
        hash: '0x' + List.generate(64, (_) => _random.nextInt(16).toRadixString(16)).join(),
        type: TransactionType.send,
        status: TransactionStatus.confirmed,
        timestamp: now.subtract(Duration(days: 2)),
        from: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        to: '0x1234567890123456789012345678901234567890',
        amount: '25',
        tokenSymbol: 'USDT',
        chainId: 421613,
        fee: '0.001',
        feeToken: 'ETH',
        fromChainId: 421613,
        recipient: '0x1234567890123456789012345678901234567890',
        txHash: '0x' + List.generate(64, (_) => _random.nextInt(16).toRadixString(16)).join(),
        createdAt: now.subtract(Duration(days: 2)),
      ),
    ]);
    
    // Add some mock receive transactions
    _transactions.addAll([
      Transaction(
        id: '6',
        hash: '0x' + List.generate(64, (_) => _random.nextInt(16).toRadixString(16)).join(),
        type: TransactionType.receive,
        status: TransactionStatus.confirmed,
        timestamp: now.subtract(Duration(hours: 5)),
        from: '0x1234567890123456789012345678901234567890',
        to: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        amount: '0.25',
        tokenSymbol: 'ETH',
        chainId: 11155111,
        fee: '0.001',
        feeToken: 'ETH',
        fromChainId: 11155111,
        recipient: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        txHash: '0x' + List.generate(64, (_) => _random.nextInt(16).toRadixString(16)).join(),
        createdAt: now.subtract(Duration(hours: 5)),
      ),
      Transaction(
        id: '7',
        hash: '0x' + List.generate(64, (_) => _random.nextInt(16).toRadixString(16)).join(),
        type: TransactionType.receive,
        status: TransactionStatus.confirmed,
        timestamp: now.subtract(Duration(days: 4)),
        from: '0x9876543210987654321098765432109876543210',
        to: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        amount: '50',
        tokenSymbol: 'USDC',
        chainId: 80001,
        fee: '0.001',
        feeToken: 'MATIC',
        fromChainId: 80001,
        recipient: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        txHash: '0x' + List.generate(64, (_) => _random.nextInt(16).toRadixString(16)).join(),
        createdAt: now.subtract(Duration(days: 4)),
      ),
    ]);
    
    // Save to local storage
    await _saveTransactions();
  }
  
  // Load transactions from storage
  Future<void> _loadTransactionsFromStorage() async {
    try {
      final savedTransactions = await _localStorage.getTransactions();
      
      // Convert each Map to Transaction object
      _transactions = savedTransactions.map((map) => Transaction.fromJson(map)).toList();
      
      // If no saved transactions, create mock data
      if (_transactions.isEmpty) {
        await _createMockTransactions();
      }
    } catch (e) {
      _error = 'Error loading transactions from storage: ${e.toString()}';
      await _createMockTransactions();
    }
  }
  
  // Reload transactions (useful after authentication changes)
  Future<void> reloadTransactions() async {
    _transactions = [];
    await _loadTransactions();
  }
  
  // Get all transactions
  List<Transaction> getAllTransactions() {
    return _transactions;
  }
  
  // Get transactions by chain
  List<Transaction> getTransactionsByChain(int chainId) {
    return _transactions.where((tx) => tx.chainId == chainId).toList();
  }
  
  // Get transactions by type
  List<Transaction> getTransactionsByType(TransactionType type) {
    return _transactions.where((tx) => tx.type == type).toList();
  }
  
  // Get transactions (used by ExportService)
  Future<List<Transaction>> getTransactions() async {
    if (_transactions.isEmpty) {
      await _loadTransactions();
    }
    return _transactions;
  }
  
  // Get transaction by ID
  Future<Transaction?> getTransaction(String id) async {
    if (_transactions.isEmpty) {
      await _loadTransactions();
    }
    try {
      return _transactions.firstWhere((tx) => tx.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Save transactions to storage
  Future<void> _saveTransactions() async {
    // Convert each Transaction object to Map
    final transactionsJson = _transactions.map((tx) => tx.toJson()).toList();
    await _localStorage.saveTransactions(transactionsJson);
  }
  
  // Add a new transaction
  Future<void> addTransaction(Transaction transaction) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // If user is authenticated, try to save to API
      if (_authService.isAuthenticated) {
        final dto = TransactionDTO.fromTransaction(transaction);
        
        final response = await _apiClient.post<Map<String, dynamic>>(
          ApiConfig.transactions,
          body: dto.toJson(),
        );
        
        if (!response.success) {
          _error = response.error ?? 'Failed to save transaction';
          print('API error: $_error - Saving locally only');
        }
      }
      
      // Add to local transactions list regardless of API result
      _transactions.add(transaction);
      await _saveTransactions();
    } catch (e) {
      _error = 'Error adding transaction: ${e.toString()}';
      print('Error: $_error - Saving locally only');
      
      // Still add to local list even if API fails
      _transactions.add(transaction);
      await _saveTransactions();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Submit a bridge transaction
  Future<String> submitBridgeTransaction({
    required int fromChainId,
    required int toChainId,
    required String amount,
    required String recipient,
    String? tokenAddress,
    String? tokenSymbol,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Generate a random hash
      final hash = '0x' + List.generate(64, (_) => _random.nextInt(16).toRadixString(16)).join();
      
      // In a real implementation, we would submit the transaction to the blockchain
      // and then to our backend API
      if (_authService.isAuthenticated) {
        final response = await _apiClient.post<Map<String, dynamic>>(
          ApiConfig.bridges,
          body: {
            'fromChainId': fromChainId,
            'toChainId': toChainId,
            'amount': amount,
            'recipient': recipient,
            'tokenAddress': tokenAddress,
            'tokenSymbol': tokenSymbol,
          },
        );
        
        if (!response.success) {
          _error = response.error ?? 'Failed to submit bridge transaction';
          _isLoading = false;
          notifyListeners();
          
          // Use mock flow instead
          print('API error: $_error - Using mock flow instead');
        } else if (response.data != null && response.data!.containsKey('hash')) {
          // If API returns a transaction hash, use it
          final apiHash = response.data!['hash'] as String;
          
          // Create transaction from API response
          final transaction = TransactionDTO.fromJson(response.data!).toTransaction();
          _transactions.add(transaction);
          
          // Save to local storage
          await _saveTransactions();
          
          _isLoading = false;
          notifyListeners();
          
          // Simulate transaction confirmation if needed
          if (transaction.status == TransactionStatus.pending) {
            _simulateTransactionConfirmation(transaction.id);
          }
          
          return apiHash;
        }
      }
      
      // If API call failed or user not authenticated, use mock flow
      // Create transaction
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        hash: hash,
        type: TransactionType.bridge,
        status: TransactionStatus.pending,
        timestamp: DateTime.now(),
        from: _authService.currentUser?.walletAddress ?? '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        to: recipient,
        amount: amount,
        tokenSymbol: tokenSymbol ?? 'ETH',
        chainId: fromChainId,
        bridgeProvider: 'Satoshi Bridge',
        toChain: toChainId.toString(),
        fee: (double.parse(amount) * 0.01).toStringAsFixed(6), // 1% fee
        feeToken: tokenSymbol ?? 'ETH',
        fromChainId: fromChainId,
        toChainId: toChainId,
        recipient: recipient,
        txHash: hash,
        createdAt: DateTime.now(),
      );
      
      // Add to transactions list
      _transactions.add(transaction);
      
      // Save to storage
      await _saveTransactions();
      
      // Simulate transaction confirmation after a delay
      _simulateTransactionConfirmation(transaction.id);
      
      _isLoading = false;
      notifyListeners();
      return hash;
    } catch (e) {
      _error = 'Error submitting bridge transaction: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return '';
    }
  }
  
  // Simulate transaction confirmation
  Future<void> _simulateTransactionConfirmation(String id) async {
    // Wait for a random time between 3-8 seconds
    await Future.delayed(Duration(seconds: 3 + _random.nextInt(5)));
    
    // Find transaction by id
    final index = _transactions.indexWhere((tx) => tx.id == id);
    if (index >= 0) {
      // 90% chance of success
      final success = _random.nextDouble() < 0.9;
      
      // Create new transaction with updated status
      final updatedTransaction = Transaction(
        id: _transactions[index].id,
        hash: _transactions[index].hash,
        type: _transactions[index].type,
        status: success ? TransactionStatus.confirmed : TransactionStatus.failed,
        timestamp: _transactions[index].timestamp,
        from: _transactions[index].from,
        to: _transactions[index].to,
        amount: _transactions[index].amount,
        tokenSymbol: _transactions[index].tokenSymbol,
        chainId: _transactions[index].chainId,
        bridgeProvider: _transactions[index].bridgeProvider,
        toChain: _transactions[index].toChain,
        fee: _transactions[index].fee,
        feeToken: _transactions[index].feeToken,
        error: success ? null : 'Transaction failed: Insufficient liquidity',
        fromChainId: _transactions[index].fromChainId,
        toChainId: _transactions[index].toChainId,
        recipient: _transactions[index].recipient,
        txHash: _transactions[index].txHash,
        createdAt: _transactions[index].createdAt,
      );
      
      // Update transaction in list
      _transactions[index] = updatedTransaction;
      
      // Save to storage
      await _saveTransactions();
      
      // If authenticated, update on API too
      if (_authService.isAuthenticated) {
        try {
          final dto = TransactionDTO.fromTransaction(updatedTransaction);
          await _apiClient.put<Map<String, dynamic>>(
            '${ApiConfig.transactions}/${updatedTransaction.id}',
            body: dto.toJson(),
          );
        } catch (e) {
          print('Error updating transaction status on API: ${e.toString()}');
        }
      }
      
      notifyListeners();
    }
  }
  
  // Add a send transaction
  Future<void> addSendTransaction({
    required int chainId,
    required String amount,
    required String recipient,
    required String tokenSymbol,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Generate a random hash
      final hash = '0x' + List.generate(64, (_) => _random.nextInt(16).toRadixString(16)).join();
      
      // In a real implementation, we would submit the transaction to the blockchain
      // and then to our backend API
      if (_authService.isAuthenticated) {
        final response = await _apiClient.post<Map<String, dynamic>>(
          ApiConfig.transactions,
          body: {
            'type': 'SEND',
            'chainId': chainId,
            'amount': amount,
            'recipient': recipient,
            'tokenSymbol': tokenSymbol,
          },
        );
        
        if (!response.success) {
          _error = response.error ?? 'Failed to send transaction';
          print('API error: $_error - Using mock flow instead');
        } else if (response.data != null) {
          // Create transaction from API response
          final transaction = TransactionDTO.fromJson(response.data!).toTransaction();
          _transactions.add(transaction);
          
          // Save to local storage
          await _saveTransactions();
          
          _isLoading = false;
          notifyListeners();
          
          // Simulate transaction confirmation if needed
          if (transaction.status == TransactionStatus.pending) {
            _simulateTransactionConfirmation(transaction.id);
          }
          
          return;
        }
      }
      
      // If API call failed or user not authenticated, use mock flow
      // Create transaction
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        hash: hash,
        type: TransactionType.send,
        status: TransactionStatus.pending,
        timestamp: DateTime.now(),
        from: _authService.currentUser?.walletAddress ?? '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        to: recipient,
        amount: amount,
        tokenSymbol: tokenSymbol,
        chainId: chainId,
        fee: (0.001).toString(),
        feeToken: 'ETH',
        fromChainId: chainId,
        recipient: recipient,
        txHash: hash,
        createdAt: DateTime.now(),
      );
      
      // Add to transactions list
      _transactions.add(transaction);
      
      // Save to storage
      await _saveTransactions();
      
      // Simulate transaction confirmation after a delay
      _simulateTransactionConfirmation(transaction.id);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error sending transaction: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Refresh transaction status
  Future<void> refreshTransactionStatus(String transactionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Find transaction by id
      final index = _transactions.indexWhere((tx) => tx.id == transactionId);
      if (index >= 0 && _transactions[index].status == TransactionStatus.pending) {
        // In a real implementation, we would check the transaction status on the blockchain
        // and then update it in our backend API
        if (_authService.isAuthenticated) {
          final response = await _apiClient.get<Map<String, dynamic>>(
            '${ApiConfig.transactions}/${_transactions[index].id}/status',
          );
          
          if (response.success && response.data != null) {
            final status = response.data!['status'] as String;
            final error = response.data!['error'] as String?;
            
            TransactionStatus txStatus;
            switch (status) {
              case 'CONFIRMED':
                txStatus = TransactionStatus.confirmed;
                break;
              case 'FAILED':
                txStatus = TransactionStatus.failed;
                break;
              default:
                txStatus = TransactionStatus.pending;
            }
            
            // Only update if status changed
            if (txStatus != _transactions[index].status) {
              // Create new transaction with updated status
              final updatedTransaction = Transaction(
                id: _transactions[index].id,
                hash: _transactions[index].hash,
                type: _transactions[index].type,
                status: txStatus,
                timestamp: _transactions[index].timestamp,
                from: _transactions[index].from,
                to: _transactions[index].to,
                amount: _transactions[index].amount,
                tokenSymbol: _transactions[index].tokenSymbol,
                chainId: _transactions[index].chainId,
                bridgeProvider: _transactions[index].bridgeProvider,
                toChain: _transactions[index].toChain,
                fee: _transactions[index].fee,
                feeToken: _transactions[index].feeToken,
                error: error,
                fromChainId: _transactions[index].fromChainId,
                toChainId: _transactions[index].toChainId,
                recipient: _transactions[index].recipient,
                txHash: _transactions[index].txHash,
                createdAt: _transactions[index].createdAt,
              );
              
              // Update transaction in list
              _transactions[index] = updatedTransaction;
              
              // Save to storage
              await _saveTransactions();
              
              _isLoading = false;
              notifyListeners();
              return;
            }
          }
        }
        
        // If API call failed or user not authenticated, use mock flow
        // Simulate network request
        await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));
        
        // 70% chance of success
        final success = _random.nextDouble() < 0.7;
        
        // Only update if still pending
        if (_transactions[index].status == TransactionStatus.pending) {
          // Create new transaction with updated status
          final updatedTransaction = Transaction(
            id: _transactions[index].id,
            hash: _transactions[index].hash,
            type: _transactions[index].type,
            status: success ? TransactionStatus.confirmed : TransactionStatus.failed,
            timestamp: _transactions[index].timestamp,
            from: _transactions[index].from,
            to: _transactions[index].to,
            amount: _transactions[index].amount,
            tokenSymbol: _transactions[index].tokenSymbol,
            chainId: _transactions[index].chainId,
            bridgeProvider: _transactions[index].bridgeProvider,
            toChain: _transactions[index].toChain,
            fee: _transactions[index].fee,
            feeToken: _transactions[index].feeToken,
            error: success ? null : 'Transaction failed: Timeout',
            fromChainId: _transactions[index].fromChainId,
            toChainId: _transactions[index].toChainId,
            recipient: _transactions[index].recipient,
            txHash: _transactions[index].txHash,
            createdAt: _transactions[index].createdAt,
          );
          
          // Update transaction in list
          _transactions[index] = updatedTransaction;
          
          // Save to storage
          await _saveTransactions();
        }
      }
    } catch (e) {
      _error = 'Error refreshing transaction status: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
