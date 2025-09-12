import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:satoshi_hub/core/models/swap.dart';
import 'package:satoshi_hub/core/models/token.dart';
import 'package:satoshi_hub/core/services/token_service.dart';

class SwapService extends ChangeNotifier {
  final TokenService _tokenService;
  final Random _random = Random();
  
  // List of swap providers
  final List<SwapProvider> _providers = [];
  
  // Current swap results
  List<SwapRoute> _availableRoutes = [];
  SwapRoute? _selectedRoute;
  
  // Swap preferences
  bool _prioritizeCost = true; // true = prioritize cost, false = prioritize output amount
  double _slippageTolerance = 0.5; // in percent
  
  // Getters
  List<SwapRoute> get availableRoutes => _availableRoutes;
  SwapRoute? get selectedRoute => _selectedRoute;
  bool get prioritizeCost => _prioritizeCost;
  double get slippageTolerance => _slippageTolerance;
  List<SwapProvider> get providers => _providers;
  
  // Constructor
  SwapService({required TokenService tokenService})
      : _tokenService = tokenService {
    _initProviders();
  }
  
  // Initialize swap providers
  void _initProviders() {
    // Initialize providers
    _providers.add(
      SwapProvider(
        id: 'uniswap',
        name: 'Uniswap',
        logoUrl: 'assets/images/providers/uniswap.png',
        feePercentage: 0.3,
        supportedChains: [11155111, 421613, 420, 80001], // Ethereum ecosystem + Polygon
        supportedTokens: ['ETH', 'USDT', 'USDC', 'DAI', 'WBTC', 'UNI', 'AAVE', 'SUSHI'],
        reliabilityScore: 95,
      ),
    );
    
    _providers.add(
      SwapProvider(
        id: 'sushiswap',
        name: 'SushiSwap',
        logoUrl: 'assets/images/providers/sushiswap.png',
        feePercentage: 0.3,
        supportedChains: [11155111, 421613, 420, 80001, 43113], // All chains except BNB
        supportedTokens: ['ETH', 'USDT', 'USDC', 'DAI', 'WBTC', 'SUSHI', 'AAVE'],
        reliabilityScore: 92,
      ),
    );
    
    _providers.add(
      SwapProvider(
        id: 'pancakeswap',
        name: 'PancakeSwap',
        logoUrl: 'assets/images/providers/pancakeswap.png',
        feePercentage: 0.25,
        supportedChains: [97], // BNB only
        supportedTokens: ['BNB', 'USDT', 'USDC', 'DAI', 'WBTC', 'CAKE'],
        reliabilityScore: 94,
      ),
    );
    
    _providers.add(
      SwapProvider(
        id: 'quickswap',
        name: 'QuickSwap',
        logoUrl: 'assets/images/providers/quickswap.png',
        feePercentage: 0.3,
        supportedChains: [80001], // Polygon only
        supportedTokens: ['MATIC', 'USDT', 'USDC', 'DAI', 'WBTC', 'AAVE'],
        reliabilityScore: 90,
      ),
    );
    
    _providers.add(
      SwapProvider(
        id: 'traderjoe',
        name: 'Trader Joe',
        logoUrl: 'assets/images/providers/traderjoe.png',
        feePercentage: 0.3,
        supportedChains: [43113], // Avalanche only
        supportedTokens: ['AVAX', 'USDT', 'USDC', 'DAI', 'WBTC', 'JOE'],
        reliabilityScore: 91,
      ),
    );
    
    _providers.add(
      SwapProvider(
        id: '1inch',
        name: '1inch',
        logoUrl: 'assets/images/providers/1inch.png',
        feePercentage: 0.1,
        supportedChains: [11155111, 421613, 420, 80001, 97, 43113], // All chains
        supportedTokens: ['ETH', 'MATIC', 'BNB', 'AVAX', 'USDT', 'USDC', 'DAI', 'WBTC', 'UNI', 'AAVE', 'SUSHI', 'CAKE', 'JOE'],
        reliabilityScore: 93,
      ),
    );
  }
  
  // Set swap preferences
  void setPrioritizeCost(bool value) {
    _prioritizeCost = value;
    _sortRoutes();
    notifyListeners();
  }
  
  void setSlippageTolerance(double value) {
    _slippageTolerance = value;
    notifyListeners();
  }
  
  // Find swap routes
  Future<List<SwapRoute>> findSwapRoutes({
    required String fromTokenAddress,
    required String toTokenAddress,
    required int chainId,
    required String amount,
  }) async {
    // Reset routes
    _availableRoutes = [];
    _selectedRoute = null;
    
    // Get tokens
    final fromToken = _tokenService.getTokenByAddress(fromTokenAddress);
    final toToken = _tokenService.getTokenByAddress(toTokenAddress);
    
    if (fromToken == null || toToken == null) {
      return [];
    }
    
    // Check if tokens are supported on the chain
    if (!fromToken.supportedChains.contains(chainId) ||
        !toToken.supportedChains.contains(chainId)) {
      return [];
    }
    
    // Find direct swap routes
    final directRoutes = _findDirectSwapRoutes(
      fromToken,
      toToken,
      chainId,
      amount,
    );
    
    // Find multi-step routes if direct routes are not available or limited
    List<SwapRoute> multiStepRoutes = [];
    if (directRoutes.length < 2) {
      multiStepRoutes = _findMultiStepSwapRoutes(
        fromToken,
        toToken,
        chainId,
        amount,
      );
    }
    
    // Combine routes
    _availableRoutes = [...directRoutes, ...multiStepRoutes];
    
    // Sort routes based on preference
    _sortRoutes();
    
    // Select best route
    if (_availableRoutes.isNotEmpty) {
      _selectedRoute = _availableRoutes.first;
    }
    
    notifyListeners();
    return _availableRoutes;
  }
  
  // Sort routes based on user preferences
  void _sortRoutes() {
    if (_availableRoutes.isEmpty) return;
    
    _availableRoutes.sort((a, b) {
      if (_prioritizeCost) {
        // Sort by fee amount (lower is better)
        final costComparison = a.totalFeeAmount.compareTo(b.totalFeeAmount);
        if (costComparison != 0) return costComparison;
        
        // If fees are the same, compare price impact (lower is better)
        final impactComparison = a.totalPriceImpact.compareTo(b.totalPriceImpact);
        if (impactComparison != 0) return impactComparison;
        
        // If both fee and impact are the same, prefer direct swaps
        if (a.isDirectSwap && !b.isDirectSwap) return -1;
        if (!a.isDirectSwap && b.isDirectSwap) return 1;
        
        // Finally, compare output amount (higher is better)
        return double.parse(b.toAmount).compareTo(double.parse(a.toAmount));
      } else {
        // Sort by output amount (higher is better)
        final amountComparison = double.parse(b.toAmount).compareTo(double.parse(a.toAmount));
        if (amountComparison != 0) return amountComparison;
        
        // If output amounts are the same, prefer direct swaps
        if (a.isDirectSwap && !b.isDirectSwap) return -1;
        if (!a.isDirectSwap && b.isDirectSwap) return 1;
        
        // Finally, compare fee amount (lower is better)
        return a.totalFeeAmount.compareTo(b.totalFeeAmount);
      }
    });
    
    // If selected route exists, check if it's still in the sorted list
    if (_selectedRoute != null) {
      final routeExists = _availableRoutes.any((r) => r.id == _selectedRoute!.id);
      if (!routeExists) {
        // If not, select the first route
        _selectedRoute = _availableRoutes.isNotEmpty ? _availableRoutes.first : null;
      }
    }
  }
  
  // Find direct swap routes
  List<SwapRoute> _findDirectSwapRoutes(
    Token fromToken,
    Token toToken,
    int chainId,
    String amount,
  ) {
    final routes = <SwapRoute>[];
    final amountValue = double.tryParse(amount) ?? 0.0;
    
    // Find providers that support the chain and tokens
    final eligibleProviders = _providers.where((provider) {
      return provider.supportedChains.contains(chainId) &&
             provider.supportedTokens.contains(fromToken.symbol) &&
             provider.supportedTokens.contains(toToken.symbol);
    }).toList();
    
    for (final provider in eligibleProviders) {
      // Calculate exchange rate (with some random variation)
      final baseRate = _getExchangeRate(fromToken.symbol, toToken.symbol);
      final rateVariation = baseRate * 0.05 * (_random.nextDouble() * 2 - 1); // +/- 5%
      final rate = baseRate + rateVariation;
      
      // Calculate output amount
      final outputAmount = amountValue * rate;
      
      // Calculate fee
      final feeAmount = amountValue * (provider.feePercentage / 100);
      
      // Calculate price impact (higher for larger amounts)
      final priceImpact = 0.1 + (amountValue / 1000) * 0.4; // 0.1% base + up to 0.5% for large amounts
      
      // Calculate minimum received (after slippage)
      final minimumReceived = outputAmount * (1 - (_slippageTolerance / 100));
      
      // Create quote
      final quote = SwapQuote(
        id: 'quote_${provider.id}_${fromToken.symbol}_${toToken.symbol}',
        fromTokenAddress: fromToken.address,
        toTokenAddress: toToken.address,
        fromTokenSymbol: fromToken.symbol,
        toTokenSymbol: toToken.symbol,
        fromAmount: amount,
        toAmount: outputAmount.toStringAsFixed(6),
        provider: provider,
        feeAmount: feeAmount,
        feeToken: fromToken.symbol,
        priceImpact: priceImpact,
        slippagePercent: _slippageTolerance,
        minimumReceived: minimumReceived.toStringAsFixed(6),
        estimatedTimeSeconds: 10 + _random.nextInt(20), // 10-30 seconds
      );
      
      // Create route
      final route = SwapRoute(
        id: 'route_${provider.id}_direct',
        steps: [quote],
        fromTokenAddress: fromToken.address,
        toTokenAddress: toToken.address,
        fromTokenSymbol: fromToken.symbol,
        toTokenSymbol: toToken.symbol,
        fromAmount: amount,
        toAmount: outputAmount.toStringAsFixed(6),
        totalFeeAmount: feeAmount,
        primaryFeeToken: fromToken.symbol,
        totalPriceImpact: priceImpact,
        totalEstimatedTimeSeconds: quote.estimatedTimeSeconds,
        isDirectSwap: true,
      );
      
      routes.add(route);
    }
    
    return routes;
  }
  
  // Find multi-step swap routes
  List<SwapRoute> _findMultiStepSwapRoutes(
    Token fromToken,
    Token toToken,
    int chainId,
    String amount,
  ) {
    final routes = <SwapRoute>[];
    final amountValue = double.tryParse(amount) ?? 0.0;
    
    // Common intermediate tokens for routing
    final intermediateTokens = ['USDT', 'USDC', 'DAI', 'WBTC', 'ETH', 'MATIC', 'NATIVE'];
    
    for (final intermediateSymbol in intermediateTokens) {
      // Skip if it's the source or destination token
      if (intermediateSymbol == fromToken.symbol || intermediateSymbol == toToken.symbol) {
        continue;
      }
      
      // Get the intermediate token
      Token? intermediateToken;
      if (intermediateSymbol == 'NATIVE') {
        // Use the chain's native token
        switch (chainId) {
          case 11155111: // Sepolia
            intermediateToken = _tokenService.getTokenBySymbol('ETH');
            break;
          case 80001: // Mumbai
            intermediateToken = _tokenService.getTokenBySymbol('MATIC');
            break;
          case 97: // BNB
            intermediateToken = _tokenService.getTokenBySymbol('BNB');
            break;
          case 43113: // Avalanche
            intermediateToken = _tokenService.getTokenBySymbol('AVAX');
            break;
          default:
            intermediateToken = _tokenService.getTokenBySymbol('ETH');
        }
      } else {
        intermediateToken = _tokenService.getTokenBySymbol(intermediateSymbol);
      }
      
      if (intermediateToken == null || !intermediateToken.supportedChains.contains(chainId)) {
        continue;
      }
      
      // Find providers for first step
      final firstStepProviders = _providers.where((provider) {
        return provider.supportedChains.contains(chainId) &&
               provider.supportedTokens.contains(fromToken.symbol) &&
               provider.supportedTokens.contains(intermediateToken!.symbol);
      }).toList();
      
      // Find providers for second step
      final secondStepProviders = _providers.where((provider) {
        return provider.supportedChains.contains(chainId) &&
               provider.supportedTokens.contains(intermediateToken!.symbol) &&
               provider.supportedTokens.contains(toToken.symbol);
      }).toList();
      
      // If both steps are possible, create a route
      if (firstStepProviders.isNotEmpty && secondStepProviders.isNotEmpty) {
        // Select random providers for each step to create some variety
        final firstStepProvider = firstStepProviders[_random.nextInt(firstStepProviders.length)];
        final secondStepProvider = secondStepProviders[_random.nextInt(secondStepProviders.length)];
        
        // Calculate first step
        final firstStepRate = _getExchangeRate(fromToken.symbol, intermediateToken.symbol);
        final firstStepRateVariation = firstStepRate * 0.05 * (_random.nextDouble() * 2 - 1);
        final firstStepFinalRate = firstStepRate + firstStepRateVariation;
        
        final firstStepOutput = amountValue * firstStepFinalRate;
        final firstStepFee = amountValue * (firstStepProvider.feePercentage / 100);
        final firstStepPriceImpact = 0.1 + (amountValue / 1000) * 0.4;
        final firstStepMinReceived = firstStepOutput * (1 - (_slippageTolerance / 100));
        
        // Create first step quote
        final firstStepQuote = SwapQuote(
          id: 'quote_${firstStepProvider.id}_${fromToken.symbol}_${intermediateToken.symbol}',
          fromTokenAddress: fromToken.address,
          toTokenAddress: intermediateToken.address,
          fromTokenSymbol: fromToken.symbol,
          toTokenSymbol: intermediateToken.symbol,
          fromAmount: amount,
          toAmount: firstStepOutput.toStringAsFixed(6),
          provider: firstStepProvider,
          feeAmount: firstStepFee,
          feeToken: fromToken.symbol,
          priceImpact: firstStepPriceImpact,
          slippagePercent: _slippageTolerance,
          minimumReceived: firstStepMinReceived.toStringAsFixed(6),
          estimatedTimeSeconds: 10 + _random.nextInt(20),
        );
        
        // Calculate second step
        final secondStepRate = _getExchangeRate(intermediateToken.symbol, toToken.symbol);
        final secondStepRateVariation = secondStepRate * 0.05 * (_random.nextDouble() * 2 - 1);
        final secondStepFinalRate = secondStepRate + secondStepRateVariation;
        
        final secondStepInput = firstStepOutput;
        final secondStepOutput = secondStepInput * secondStepFinalRate;
        final secondStepFee = secondStepInput * (secondStepProvider.feePercentage / 100);
        final secondStepPriceImpact = 0.1 + (secondStepInput / 1000) * 0.4;
        final secondStepMinReceived = secondStepOutput * (1 - (_slippageTolerance / 100));
        
        // Create second step quote
        final secondStepQuote = SwapQuote(
          id: 'quote_${secondStepProvider.id}_${intermediateToken.symbol}_${toToken.symbol}',
          fromTokenAddress: intermediateToken.address,
          toTokenAddress: toToken.address,
          fromTokenSymbol: intermediateToken.symbol,
          toTokenSymbol: toToken.symbol,
          fromAmount: firstStepOutput.toStringAsFixed(6),
          toAmount: secondStepOutput.toStringAsFixed(6),
          provider: secondStepProvider,
          feeAmount: secondStepFee,
          feeToken: intermediateToken.symbol,
          priceImpact: secondStepPriceImpact,
          slippagePercent: _slippageTolerance,
          minimumReceived: secondStepMinReceived.toStringAsFixed(6),
          estimatedTimeSeconds: 10 + _random.nextInt(20),
        );
        
        // Calculate route totals
        final totalFeeInFromToken = firstStepFee + (secondStepFee / firstStepFinalRate);
        final totalEstimatedTime = firstStepQuote.estimatedTimeSeconds + secondStepQuote.estimatedTimeSeconds;
        
        // Price impact compounds
        final totalPriceImpact = firstStepPriceImpact + secondStepPriceImpact - (firstStepPriceImpact * secondStepPriceImpact / 100);
        
        // Create route
        final route = SwapRoute(
          id: 'route_${firstStepProvider.id}_${secondStepProvider.id}_via_${intermediateToken.symbol}',
          steps: [firstStepQuote, secondStepQuote],
          fromTokenAddress: fromToken.address,
          toTokenAddress: toToken.address,
          fromTokenSymbol: fromToken.symbol,
          toTokenSymbol: toToken.symbol,
          fromAmount: amount,
          toAmount: secondStepOutput.toStringAsFixed(6),
          totalFeeAmount: totalFeeInFromToken,
          primaryFeeToken: fromToken.symbol,
          totalPriceImpact: totalPriceImpact,
          totalEstimatedTimeSeconds: totalEstimatedTime,
          isDirectSwap: false,
        );
        
        routes.add(route);
      }
    }
    
    // Limit to top 2 multi-step routes to avoid overwhelming the user
    routes.sort((a, b) => _prioritizeCost
        ? a.totalFeeAmount.compareTo(b.totalFeeAmount)
        : double.parse(b.toAmount).compareTo(double.parse(a.toAmount)));
    
    return routes.take(2).toList();
  }
  
  // Get exchange rate between two tokens
  double _getExchangeRate(String fromSymbol, String toSymbol) {
    // In a real implementation, we would query market data
    // For this demo, we'll use fixed rates with some realistic relationships
    
    // Base rates against USD
    final usdRates = {
      'ETH': 3000.0,
      'MATIC': 1.5,
      'BNB': 400.0,
      'AVAX': 35.0,
      'USDT': 1.0,
      'USDC': 1.0,
      'DAI': 1.0,
      'WBTC': 50000.0,
      'UNI': 15.0,
      'AAVE': 150.0,
      'SUSHI': 2.0,
      'CAKE': 5.0,
      'JOE': 0.5,
    };
    
    // Get USD rates for the tokens
    final fromUsdRate = usdRates[fromSymbol] ?? 1.0;
    final toUsdRate = usdRates[toSymbol] ?? 1.0;
    
    // Calculate the exchange rate
    return toUsdRate / fromUsdRate;
  }
  
  // Select a specific route
  void selectRoute(String routeId) {
    final route = _availableRoutes.firstWhere((r) => r.id == routeId);
    _selectedRoute = route;
    notifyListeners();
  }
  
  // Execute a swap (simulation)
  Future<bool> executeSwap(SwapRoute route) async {
    // In a real implementation, we would execute the swap on-chain
    // For this demo, we'll simulate it
    
    // Simulate success (90% chance)
    final success = _random.nextDouble() < 0.9;
    
    if (success) {
      // Update token balances
      final fromToken = _tokenService.getTokenByAddress(route.fromTokenAddress);
      final toToken = _tokenService.getTokenByAddress(route.toTokenAddress);
      
      if (fromToken != null && toToken != null) {
        // Deduct fromToken balance
        final fromAmount = double.parse(route.fromAmount);
        
        // Add toToken balance
        final toAmount = double.parse(route.toAmount);
        
        // Simulate balance updates
        // This would be handled by the TokenService in a real implementation
      }
    }
    
    return success;
  }
}
