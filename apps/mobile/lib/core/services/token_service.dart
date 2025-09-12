import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:satoshi_hub/core/models/token.dart';
import 'package:satoshi_hub/core/services/chain_service.dart';
import 'package:satoshi_hub/core/services/local_storage_service.dart';
import 'package:satoshi_hub/core/services/api_client.dart';
import 'package:satoshi_hub/core/services/auth_service.dart';
import 'package:satoshi_hub/core/config/api_config.dart';

class TokenService extends ChangeNotifier {
  final ChainService _chainService;
  final LocalStorageService _localStorage;
  final AuthService _authService;
  final ApiClient _apiClient;
  final Random _random = Random();
  
  // List of tokens
  List<Token> _tokens = [];
  
  // Selected token
  Token? _selectedToken;
  
  // State tracking
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Token> get tokens => _tokens;
  Token? get selectedToken => _selectedToken;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Constructor
  TokenService({
    required ChainService chainService,
    required LocalStorageService localStorage,
    required AuthService authService,
  }) : _chainService = chainService, 
       _localStorage = localStorage,
       _authService = authService,
       _apiClient = ApiClient(authToken: authService.token) {
    _initializeTokens();
  }
  
  // Initialize tokens
  Future<void> _initializeTokens() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // First try to get tokens from API
      if (_authService.isAuthenticated) {
        await _fetchTokensFromApi();
      }
      
      // If API fails or no tokens returned, try local storage
      if (_tokens.isEmpty) {
        await _loadTokensFromStorage();
      }
      
      // If still no tokens, create default ones
      if (_tokens.isEmpty) {
        _createDefaultTokens();
      }
      
      // Set default selected token
      if (_tokens.isNotEmpty) {
        _selectedToken = _tokens.firstWhere(
          (token) => token.isNative, 
          orElse: () => _tokens.first
        );
      }
    } catch (e) {
      _error = 'Error initializing tokens: ${e.toString()}';
      // If error, create default tokens
      _createDefaultTokens();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Fetch tokens from API
  Future<void> _fetchTokensFromApi() async {
    try {
      // Mock API call for now
      await Future.delayed(Duration(milliseconds: 1000));
      
      // Here we'd actually fetch tokens from the API
      // For now, we'll leave it empty to fall back to local storage or defaults
      
      /* Real implementation would be like:
      final response = await _apiClient.get<List<dynamic>>(
        ApiConfig.tokens,
      );
      
      if (response.success && response.data != null) {
        _tokens = response.data!.map((item) => Token.fromJson(item)).toList();
      }
      */
    } catch (e) {
      _error = 'Error fetching tokens: ${e.toString()}';
    }
  }
  
  // Load tokens from local storage
  Future<void> _loadTokensFromStorage() async {
    try {
      final savedTokens = await _localStorage.getTokens();
      
      if (savedTokens.isNotEmpty) {
        // Convert each Map to Token object
        _tokens = savedTokens.map((map) => Token.fromJson(map)).toList();
      }
    } catch (e) {
      _error = 'Error loading tokens from storage: ${e.toString()}';
    }
  }
  
  // Create default tokens
  void _createDefaultTokens() {
    // Get all chain IDs
    final allChains = _chainService.chains.map((chain) => chain.chainId).toList();
    
    // Common native tokens
    _tokens = [
      // Native tokens for each chain
      Token(
        address: 'native',
        symbol: 'ETH',
        name: 'Ethereum',
        logoUrl: 'assets/tokens/eth.png',
        decimals: 18,
        balance: (10 + _random.nextDouble() * 5).toStringAsFixed(6),
        supportedChains: [11155111, 421613, 420], // Sepolia, Arbitrum, Optimism
        isNative: true,
      ),
      Token(
        address: 'native',
        symbol: 'MATIC',
        name: 'Polygon',
        logoUrl: 'assets/tokens/matic.png',
        decimals: 18,
        balance: (100 + _random.nextDouble() * 200).toStringAsFixed(6),
        supportedChains: [80001], // Mumbai
        isNative: true,
      ),
      Token(
        address: 'native',
        symbol: 'BNB',
        name: 'Binance Coin',
        logoUrl: 'assets/tokens/bnb.png',
        decimals: 18,
        balance: (5 + _random.nextDouble() * 3).toStringAsFixed(6),
        supportedChains: [97], // BNB Testnet
        isNative: true,
      ),
      Token(
        address: 'native',
        symbol: 'AVAX',
        name: 'Avalanche',
        logoUrl: 'assets/tokens/avax.png',
        decimals: 18,
        balance: (20 + _random.nextDouble() * 10).toStringAsFixed(6),
        supportedChains: [43113], // Avalanche Fuji
        isNative: true,
      ),
      
      // Common ERC-20 tokens
      Token(
        address: '0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8',
        symbol: 'USDT',
        name: 'Tether USD',
        logoUrl: 'assets/tokens/usdt.png',
        decimals: 6,
        balance: (1000 + _random.nextDouble() * 500).toStringAsFixed(2),
        supportedChains: allChains,
        isNative: false,
      ),
      Token(
        address: '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
        symbol: 'USDC',
        name: 'USD Coin',
        logoUrl: 'assets/tokens/usdc.png',
        decimals: 6,
        balance: (1000 + _random.nextDouble() * 500).toStringAsFixed(2),
        supportedChains: allChains,
        isNative: false,
      ),
      Token(
        address: '0x6B175474E89094C44Da98b954EedeAC495271d0F',
        symbol: 'DAI',
        name: 'Dai Stablecoin',
        logoUrl: 'assets/tokens/dai.png',
        decimals: 18,
        balance: (1000 + _random.nextDouble() * 500).toStringAsFixed(2),
        supportedChains: allChains,
        isNative: false,
      ),
      Token(
        address: '0x2260fac5e5542a773aa44fbcfedf7c193bc2c599',
        symbol: 'WBTC',
        name: 'Wrapped Bitcoin',
        logoUrl: 'assets/tokens/wbtc.png',
        decimals: 8,
        balance: (0.5 + _random.nextDouble() * 0.5).toStringAsFixed(6),
        supportedChains: allChains,
        isNative: false,
      ),
    ];
    
    // Save tokens to storage
    final tokensJson = _tokens.map((token) => token.toJson()).toList();
    _localStorage.saveTokens(tokensJson);
  }
  
  // Reload tokens (useful after authentication changes)
  Future<void> reloadTokens() async {
    _tokens = [];
    await _initializeTokens();
  }
  
  // Get tokens for a specific chain
  List<Token> getTokensForChain(int chainId) {
    return _tokens.where((token) => token.supportedChains.contains(chainId)).toList();
  }
  
  // Select a token
  void selectToken(String address) {
    final token = _tokens.firstWhere(
      (token) => token.address == address, 
      orElse: () => _tokens.first
    );
    
    _selectedToken = token;
    notifyListeners();
  }
  
  // Get token by address
  Token? getTokenByAddress(String address) {
    try {
      return _tokens.firstWhere((token) => token.address == address);
    } catch (e) {
      return null;
    }
  }
  
  // Get token by symbol
  Token? getTokenBySymbol(String symbol) {
    try {
      return _tokens.firstWhere((token) => token.symbol == symbol);
    } catch (e) {
      return null;
    }
  }
  
  // Get native token for a chain
  Token? getNativeTokenForChain(int chainId) {
    try {
      return _tokens.firstWhere(
        (token) => token.isNative && token.supportedChains.contains(chainId)
      );
    } catch (e) {
      return null;
    }
  }
  
  // Update token balance
  Future<void> updateTokenBalance(String address, String newBalance) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final index = _tokens.indexWhere((token) => token.address == address);
      if (index >= 0) {
        _tokens[index] = _tokens[index].copyWithBalance(newBalance);
        
        // If this is the selected token, update it too
        if (_selectedToken?.address == address) {
          _selectedToken = _tokens[index];
        }
        
        // Save tokens to storage
        final tokensJson = _tokens.map((token) => token.toJson()).toList();
        await _localStorage.saveTokens(tokensJson);
        
        // In a real implementation, we would also update the balance on the server
        if (_authService.isAuthenticated) {
          /* Real implementation would be like:
          await _apiClient.put(
            '${ApiConfig.tokens}/${address}/balance',
            body: {'balance': newBalance},
          );
          */
        }
      }
    } catch (e) {
      _error = 'Error updating token balance: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Simulate token transfer
  Future<bool> simulateTokenTransfer({
    required String tokenAddress,
    required int fromChainId,
    required int toChainId,
    required String amount,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final token = getTokenByAddress(tokenAddress);
      if (token == null) {
        _error = 'Token not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Check if token is supported on both chains
      if (!token.supportedChains.contains(fromChainId) || 
          !token.supportedChains.contains(toChainId)) {
        _error = 'Token not supported on both chains';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Check if balance is sufficient
      final currentBalance = double.parse(token.balance);
      final transferAmount = double.parse(amount);
      
      if (currentBalance < transferAmount) {
        _error = 'Insufficient balance';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // In a real implementation, we would call the API to simulate the transfer
      if (_authService.isAuthenticated) {
        /* Real implementation would be like:
        final response = await _apiClient.post<Map<String, dynamic>>(
          '${ApiConfig.tokens}/simulate-transfer',
          body: {
            'tokenAddress': tokenAddress,
            'fromChainId': fromChainId,
            'toChainId': toChainId,
            'amount': amount,
          },
        );
        
        if (!response.success) {
          _error = response.error ?? 'Simulation failed';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        */
      }
      
      // Simulate success (deduct balance)
      final newBalance = (currentBalance - transferAmount).toString();
      await updateTokenBalance(tokenAddress, newBalance);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error simulating token transfer: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Add token
  Future<void> addToken({
    required String address,
    required String symbol,
    required String name,
    required int decimals,
    required List<int> supportedChains,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Check if token already exists
      if (_tokens.any((token) => token.address == address)) {
        _error = 'Token already exists';
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      // Create new token
      final newToken = Token(
        address: address,
        symbol: symbol,
        name: name,
        logoUrl: 'assets/tokens/unknown.png', // Default logo
        decimals: decimals,
        balance: '0',
        supportedChains: supportedChains,
        isNative: false,
      );
      
      // Add to tokens list
      _tokens.add(newToken);
      
      // Save tokens to storage
      final tokensJson = _tokens.map((token) => token.toJson()).toList();
      await _localStorage.saveTokens(tokensJson);
      
      // In a real implementation, we would also add the token on the server
      if (_authService.isAuthenticated) {
        /* Real implementation would be like:
        await _apiClient.post(
          ApiConfig.tokens,
          body: newToken.toJson(),
        );
        */
      }
    } catch (e) {
      _error = 'Error adding token: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
