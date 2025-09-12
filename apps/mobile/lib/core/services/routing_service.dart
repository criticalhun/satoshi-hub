import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:satoshi_hub/core/models/bridge_route.dart';
import 'package:satoshi_hub/core/services/chain_service.dart';
import 'package:satoshi_hub/core/services/historical_data_service.dart';
import 'package:satoshi_hub/core/models/token.dart';

class SlippageEstimate {
  final double minSlippagePercent;
  final double maxSlippagePercent;
  final double averageSlippagePercent;
  
  SlippageEstimate({
    required this.minSlippagePercent,
    required this.maxSlippagePercent,
    required this.averageSlippagePercent,
  });
}

class RouteAnalysis {
  final BridgeRoute route;
  final SlippageEstimate slippage;
  final double liquidityImpact;
  final double gasEfficiency;
  final double securityScore;
  final String? warning;
  
  RouteAnalysis({
    required this.route,
    required this.slippage,
    required this.liquidityImpact,
    required this.gasEfficiency,
    required this.securityScore,
    this.warning,
  });
}

class RoutingService extends ChangeNotifier {
  final ChainService _chainService;
  final HistoricalDataService _historicalDataService;
  final Random _random = Random();
  
  // List of bridge providers
  final List<BridgeProvider> _providers = [];
  
  // Current routing results
  List<BridgeRoute> _availableRoutes = [];
  BridgeRoute? _selectedRoute;
  
  // Routing preferences
  bool _prioritizeCost = true; // true = prioritize cost, false = prioritize speed
  bool _considerSlippage = true; // whether to factor in slippage in route selection
  bool _considerSecurity = true; // whether to factor in security in route selection
  double _maxAcceptableSlippage = 1.0; // max acceptable slippage in percent
  
  // Route analysis results
  final Map<String, RouteAnalysis> _routeAnalysis = {};
  
  // Getters
  List<BridgeRoute> get availableRoutes => _availableRoutes;
  BridgeRoute? get selectedRoute => _selectedRoute;
  bool get prioritizeCost => _prioritizeCost;
  bool get considerSlippage => _considerSlippage;
  bool get considerSecurity => _considerSecurity;
  double get maxAcceptableSlippage => _maxAcceptableSlippage;
  Map<String, RouteAnalysis> get routeAnalysis => _routeAnalysis;
  
  // Constructor
  RoutingService({
    required ChainService chainService,
    required HistoricalDataService historicalDataService,
  }) : _chainService = chainService, _historicalDataService = historicalDataService {
    _initProviders();
  }
  
  // Initialize bridge providers
  void _initProviders() {
    // All chains supported by our app
    final allChains = _chainService.chains.map((chain) => chain.chainId).toList();
    
    // Common provider supporting all chains
    _providers.add(
      BridgeProvider(
        id: 'anyswap',
        name: 'Anyswap',
        logoUrl: 'assets/images/providers/anyswap.png',
        feePercentage: 0.3,
        estimatedTimeMinutes: 15,
        supportedChains: allChains,
        reliabilityScore: 92,
      ),
    );
    
    // Ethereum ecosystem providers
    _providers.add(
      BridgeProvider(
        id: 'hop',
        name: 'Hop Protocol',
        logoUrl: 'assets/images/providers/hop.png',
        feePercentage: 0.2,
        estimatedTimeMinutes: 10,
        supportedChains: [11155111, 421613, 420], // Sepolia, Arbitrum, Optimism
        reliabilityScore: 95,
      ),
    );
    
    // All L2s provider
    _providers.add(
      BridgeProvider(
        id: 'across',
        name: 'Across',
        logoUrl: 'assets/images/providers/across.png',
        feePercentage: 0.15,
        estimatedTimeMinutes: 12,
        supportedChains: [11155111, 421613, 420, 80001], // ETH L2s and Polygon
        reliabilityScore: 90,
      ),
    );
    
    // Polygon specific provider
    _providers.add(
      BridgeProvider(
        id: 'polygon',
        name: 'Polygon Bridge',
        logoUrl: 'assets/images/providers/polygon.png',
        feePercentage: 0.1,
        estimatedTimeMinutes: 20,
        supportedChains: [11155111, 80001], // Sepolia and Mumbai
        reliabilityScore: 98,
      ),
    );
    
    // Avalanche specific provider
    _providers.add(
      BridgeProvider(
        id: 'avalanche',
        name: 'Avalanche Bridge',
        logoUrl: 'assets/images/providers/avalanche.png',
        feePercentage: 0.1,
        estimatedTimeMinutes: 8,
        supportedChains: [11155111, 43113], // Sepolia and Avalanche
        reliabilityScore: 97,
      ),
    );
    
    // Arbitrum specific provider
    _providers.add(
      BridgeProvider(
        id: 'arbitrum',
        name: 'Arbitrum Bridge',
        logoUrl: 'assets/images/providers/arbitrum.png',
        feePercentage: 0.05,
        estimatedTimeMinutes: 7,
        supportedChains: [11155111, 421613], // Sepolia and Arbitrum
        reliabilityScore: 96,
      ),
    );
    
    // Optimism specific provider
    _providers.add(
      BridgeProvider(
        id: 'optimism',
        name: 'Optimism Bridge',
        logoUrl: 'assets/images/providers/optimism.png',
        feePercentage: 0.05,
        estimatedTimeMinutes: 5,
        supportedChains: [11155111, 420], // Sepolia and Optimism
        reliabilityScore: 94,
      ),
    );
    
    // BNB specific provider
    _providers.add(
      BridgeProvider(
        id: 'bnb',
        name: 'BNB Bridge',
        logoUrl: 'assets/images/providers/bnb.png',
        feePercentage: 0.1,
        estimatedTimeMinutes: 10,
        supportedChains: [11155111, 97], // Sepolia and BNB
        reliabilityScore: 95,
      ),
    );
  }
  
  // Set routing preferences
  void setPrioritizeCost(bool value) {
    _prioritizeCost = value;
    _sortRoutes();
    notifyListeners();
  }
  
  void setConsiderSlippage(bool value) {
    _considerSlippage = value;
    _sortRoutes();
    notifyListeners();
  }
  
  void setConsiderSecurity(bool value) {
    _considerSecurity = value;
    _sortRoutes();
    notifyListeners();
  }
  
  void setMaxAcceptableSlippage(double value) {
    _maxAcceptableSlippage = value;
    _sortRoutes();
    notifyListeners();
  }
  
  // Find routes between chains for a specific token
  Future<List<BridgeRoute>> findRoutes({
    required int fromChainId,
    required int toChainId,
    required Token token,
    required String amount,
  }) async {
    // Reset routes
    _availableRoutes = [];
    _selectedRoute = null;
    _routeAnalysis.clear();
    
    // Check if token is supported on destination chain
    if (!token.supportedChains.contains(toChainId)) {
      return [];
    }
    
    // Find direct routes
    final directRoutes = _findDirectRoutes(fromChainId, toChainId, token, amount);
    
    // Find multi-hop routes if direct routes are not available or limited
    List<BridgeRoute> multiHopRoutes = [];
    if (directRoutes.length < 2) {
      multiHopRoutes = _findMultiHopRoutes(fromChainId, toChainId, token, amount);
    }
    
    // Combine routes
    _availableRoutes = [...directRoutes, ...multiHopRoutes];
    
    // Analyze routes
    await _analyzeRoutes(token, amount);
    
    // Sort routes based on preference
    _sortRoutes();
    
    // Select best route
    if (_availableRoutes.isNotEmpty) {
      _selectedRoute = _availableRoutes.first;
    }
    
    notifyListeners();
    return _availableRoutes;
  }
  
  // Analyze routes for slippage, liquidity impact, etc.
  Future<void> _analyzeRoutes(Token token, String amount) async {
    final amountValue = double.tryParse(amount) ?? 0.0;
    
    for (final route in _availableRoutes) {
      // Estimate slippage
      final slippage = _estimateSlippage(route, token, amountValue);
      
      // Estimate liquidity impact
      final liquidityImpact = _estimateLiquidityImpact(route, token, amountValue);
      
      // Estimate gas efficiency
      final gasEfficiency = _estimateGasEfficiency(route);
      
      // Calculate security score
      final securityScore = _calculateSecurityScore(route);
      
      // Generate warning if needed
      String? warning;
      if (slippage.averageSlippagePercent > _maxAcceptableSlippage) {
        warning = 'High slippage expected (${slippage.averageSlippagePercent.toStringAsFixed(2)}%)';
      } else if (liquidityImpact > 0.1) {
        warning = 'High liquidity impact (${(liquidityImpact * 100).toStringAsFixed(2)}%)';
      } else if (securityScore < 70) {
        warning = 'Low security score (${securityScore.toStringAsFixed(0)}/100)';
      }
      
      // Create route analysis
      final analysis = RouteAnalysis(
        route: route,
        slippage: slippage,
        liquidityImpact: liquidityImpact,
        gasEfficiency: gasEfficiency,
        securityScore: securityScore,
        warning: warning,
      );
      
      _routeAnalysis[route.id] = analysis;
    }
  }
  
  // Estimate slippage for a route
  SlippageEstimate _estimateSlippage(BridgeRoute route, Token token, double amount) {
    double minSlippage = double.infinity;
    double maxSlippage = 0;
    double totalSlippage = 0;
    
    for (final hop in route.hops) {
      // Get historical slippage data for this provider and chain pair
      final metrics = _historicalDataService.getMetrics(
        hop.provider.id, 
        hop.fromChainId, 
        hop.toChainId
      );
      
      double hopSlippage;
      if (metrics != null) {
        // Use historical slippage data with some random variation
        final baseSlippage = metrics.averageSlippagePercent;
        final slippageVariance = baseSlippage * 0.2 * (_random.nextDouble() * 2 - 1);
        
        // Adjust slippage based on amount (higher amounts = higher slippage)
        final amountFactor = 1.0 + (amount / 100).clamp(0, 0.5); // max 50% increase for large amounts
        
        hopSlippage = (baseSlippage + slippageVariance) * amountFactor;
      } else {
        // Default slippage if no historical data
        hopSlippage = 0.5 + _random.nextDouble() * 0.5; // 0.5% to 1%
      }
      
      // Track min and max slippage
      minSlippage = min(minSlippage, hopSlippage);
      maxSlippage = max(maxSlippage, hopSlippage);
      totalSlippage += hopSlippage;
    }
    
    // For multi-hop routes, slippage compounds
    final avgSlippage = totalSlippage / route.hops.length;
    
    return SlippageEstimate(
      minSlippagePercent: minSlippage,
      maxSlippagePercent: maxSlippage,
      averageSlippagePercent: avgSlippage,
    );
  }
  
  // Estimate liquidity impact
  double _estimateLiquidityImpact(BridgeRoute route, Token token, double amount) {
    // In a real implementation, we would query liquidity pools
    // For this demo, we'll simulate it
    
    // Base impact is proportional to amount and inverse to pool size
    double impact = 0;
    
    for (final hop in route.hops) {
      // Simulate pool size based on chain and token
      double poolSize;
      
      // Major chains and tokens have more liquidity
      if (token.address == 'native') {
        // Native tokens have more liquidity
        poolSize = 1000000.0;
      } else if (token.symbol == 'USDT' || token.symbol == 'USDC' || token.symbol == 'DAI') {
        // Stablecoins have good liquidity
        poolSize = 500000.0;
      } else {
        // Other tokens have less liquidity
        poolSize = 100000.0;
      }
      
      // Adjust based on chain
      if (hop.fromChainId == 11155111 || hop.toChainId == 11155111) {
        // Ethereum has more liquidity
        poolSize *= 1.5;
      } else if (hop.fromChainId == 80001 || hop.toChainId == 80001) {
        // Polygon has good liquidity
        poolSize *= 1.2;
      }
      
      // Calculate impact for this hop
      final hopImpact = amount / poolSize;
      
      // Impact compounds across hops
      impact = impact + hopImpact * (1 - impact);
    }
    
    return impact;
  }
  
  // Estimate gas efficiency
  double _estimateGasEfficiency(BridgeRoute route) {
    // Gas efficiency is based on number of hops and chains involved
    // More hops = less efficiency
    
    // Base efficiency
    double efficiency = 1.0;
    
    // Penalize multi-hop routes
    efficiency -= (route.hopCount - 1) * 0.2; // Each additional hop reduces efficiency by 20%
    
    // Consider chain gas costs
    double totalGasCost = 0;
    for (final hop in route.hops) {
      double chainGasCost;
      
      // Estimate gas cost based on chain
      switch (hop.fromChainId) {
        case 11155111: // Sepolia (Ethereum)
          chainGasCost = 1.0;
          break;
        case 421613: // Arbitrum
          chainGasCost = 0.2;
          break;
        case 420: // Optimism
          chainGasCost = 0.3;
          break;
        case 80001: // Mumbai (Polygon)
          chainGasCost = 0.1;
          break;
        case 97: // BNB
          chainGasCost = 0.05;
          break;
        case 43113: // Avalanche
          chainGasCost = 0.15;
          break;
        default:
          chainGasCost = 0.5;
      }
      
      totalGasCost += chainGasCost;
    }
    
    // Normalize gas cost (lower is better)
    final normalizedGasCost = 1.0 - (totalGasCost / (route.hopCount * 1.0)).clamp(0, 0.9);
    
    // Combine factors
    efficiency = 0.6 * efficiency + 0.4 * normalizedGasCost;
    
    return efficiency.clamp(0, 1);
  }
  
  // Calculate security score
  double _calculateSecurityScore(BridgeRoute route) {
    double score = 0;
    
    for (final hop in route.hops) {
      // Get reliability score from historical data
      double reliabilityScore = _historicalDataService.getReliabilityScore(
        hop.provider.id, 
        hop.fromChainId, 
        hop.toChainId
      );
      
      // If no historical data, use the provider's base reliability
      if (reliabilityScore == 0) {
        reliabilityScore = hop.provider.reliabilityScore;
      }
      
      score += reliabilityScore;
    }
    
    // Average score across hops
    score = score / route.hops.length;
    
    // Penalize multi-hop routes
    score = score * (1 - (route.hopCount - 1) * 0.05); // Each additional hop reduces security by 5%
    
    return score;
  }
  
  // Sort routes based on user preferences
  void _sortRoutes() {
    if (_availableRoutes.isEmpty) return;
    
    _availableRoutes.sort((a, b) {
      // Get route analysis
      final analysisA = _routeAnalysis[a.id];
      final analysisB = _routeAnalysis[b.id];
      
      if (analysisA == null || analysisB == null) {
        // If analysis not available, sort by fee or time
        if (_prioritizeCost) {
          return a.totalFeeAmount.compareTo(b.totalFeeAmount);
        } else {
          return a.totalEstimatedTimeMinutes.compareTo(b.totalEstimatedTimeMinutes);
        }
      }
      
      // Base score
      double scoreA = 0;
      double scoreB = 0;
      
      // Factor in cost (lower is better)
      if (_prioritizeCost) {
        scoreA -= a.totalFeeAmount * 5; // Higher weight for cost
        scoreB -= b.totalFeeAmount * 5;
      } else {
        // Factor in time (lower is better)
        scoreA -= a.totalEstimatedTimeMinutes * 0.5;
        scoreB -= b.totalEstimatedTimeMinutes * 0.5;
      }
      
      // Factor in slippage (lower is better)
      if (_considerSlippage) {
        scoreA -= analysisA.slippage.averageSlippagePercent * 3;
        scoreB -= analysisB.slippage.averageSlippagePercent * 3;
      }
      
      // Factor in liquidity impact (lower is better)
      scoreA -= analysisA.liquidityImpact * 100;
      scoreB -= analysisB.liquidityImpact * 100;
      
      // Factor in gas efficiency (higher is better)
      scoreA += analysisA.gasEfficiency * 2;
      scoreB += analysisB.gasEfficiency * 2;
      
      // Factor in security (higher is better)
      if (_considerSecurity) {
        scoreA += analysisA.securityScore * 0.1;
        scoreB += analysisB.securityScore * 0.1;
      }
      
      // Prefer direct routes
      if (a.isDirectRoute && !b.isDirectRoute) {
        scoreA += 1;
      } else if (!a.isDirectRoute && b.isDirectRoute) {
        scoreB += 1;
      }
      
      // Higher score is better
      return scoreB.compareTo(scoreA);
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
  
  // Find direct routes between two chains
  List<BridgeRoute> _findDirectRoutes(int fromChainId, int toChainId, Token token, String amount) {
    final routes = <BridgeRoute>[];
    final amountValue = double.tryParse(amount) ?? 0.0;
    
    // Find providers that support both chains
    final eligibleProviders = _providers.where((provider) {
      return provider.supportedChains.contains(fromChainId) && 
             provider.supportedChains.contains(toChainId);
    }).toList();
    
    // Create routes for each eligible provider
    for (final provider in eligibleProviders) {
      final feeAmount = amountValue * (provider.feePercentage / 100);
      
      final hop = RouteHop(
        fromChainId: fromChainId,
        toChainId: toChainId,
        provider: provider,
        feeAmount: feeAmount,
        feeToken: token.symbol,
        estimatedTimeMinutes: provider.estimatedTimeMinutes,
      );
      
      // Apply some random variation to make it more realistic
      final timeVariation = provider.estimatedTimeMinutes * 0.2 * (_random.nextDouble() - 0.5);
      final adjustedTime = (provider.estimatedTimeMinutes + timeVariation).round();
      
      // Get historical reliability data
      double reliabilityScore = _historicalDataService.getReliabilityScore(
        provider.id, 
        fromChainId, 
        toChainId
      );
      
      // If no historical data, use the provider's base reliability
      if (reliabilityScore == 0) {
        reliabilityScore = provider.reliabilityScore;
      }
      
      final route = BridgeRoute(
        id: 'route_${provider.id}_direct',
        hops: [hop],
        totalFeeAmount: feeAmount,
        primaryFeeToken: token.symbol,
        totalEstimatedTimeMinutes: adjustedTime,
        reliabilityScore: reliabilityScore,
        isDirectRoute: true,
      );
      
      routes.add(route);
    }
    
    return routes;
  }
  
  // Find multi-hop routes between two chains
  List<BridgeRoute> _findMultiHopRoutes(int fromChainId, int toChainId, Token token, String amount) {
    final routes = <BridgeRoute>[];
    final amountValue = double.tryParse(amount) ?? 0.0;
    
    // Get all chains
    final allChains = _chainService.chains.map((chain) => chain.chainId).toList();
    
    // For each intermediate chain, try to create a 2-hop route
    for (final intermediateChainId in allChains) {
      // Skip if it's the source or destination chain
      if (intermediateChainId == fromChainId || intermediateChainId == toChainId) {
        continue;
      }
      
      // Skip if the token is not supported on the intermediate chain
      if (!token.supportedChains.contains(intermediateChainId)) {
        continue;
      }
      
      // Find providers for first hop
      final firstHopProviders = _providers.where((provider) {
        return provider.supportedChains.contains(fromChainId) && 
               provider.supportedChains.contains(intermediateChainId);
      }).toList();
      
      // Find providers for second hop
      final secondHopProviders = _providers.where((provider) {
        return provider.supportedChains.contains(intermediateChainId) && 
               provider.supportedChains.contains(toChainId);
      }).toList();
      
      // If both hops are possible, create a route
      if (firstHopProviders.isNotEmpty && secondHopProviders.isNotEmpty) {
        // Select best providers for each hop based on historical data
        final firstHopProvider = _selectBestProvider(firstHopProviders, fromChainId, intermediateChainId);
        final secondHopProvider = _selectBestProvider(secondHopProviders, intermediateChainId, toChainId);
        
        // Calculate fees and times
        final firstHopFee = amountValue * (firstHopProvider.feePercentage / 100);
        
        // For the second hop, the amount is reduced by the first hop fee
        final secondHopAmount = amountValue - firstHopFee;
        final secondHopFee = secondHopAmount * (secondHopProvider.feePercentage / 100);
        
        final firstHop = RouteHop(
          fromChainId: fromChainId,
          toChainId: intermediateChainId,
          provider: firstHopProvider,
          feeAmount: firstHopFee,
          feeToken: token.symbol,
          estimatedTimeMinutes: firstHopProvider.estimatedTimeMinutes,
        );
        
        final secondHop = RouteHop(
          fromChainId: intermediateChainId,
          toChainId: toChainId,
          provider: secondHopProvider,
          feeAmount: secondHopFee,
          feeToken: token.symbol,
          estimatedTimeMinutes: secondHopProvider.estimatedTimeMinutes,
        );
        
        // Apply some random variation to make it more realistic
        final totalTime = firstHopProvider.estimatedTimeMinutes + secondHopProvider.estimatedTimeMinutes;
        final timeVariation = totalTime * 0.1 * (_random.nextDouble() - 0.5);
        final adjustedTime = (totalTime + timeVariation).round();
        
        // Calculate the combined reliability score (weighted average)
        final firstHopReliability = _historicalDataService.getReliabilityScore(
          firstHopProvider.id, 
          fromChainId, 
          intermediateChainId
        );
        
        final secondHopReliability = _historicalDataService.getReliabilityScore(
          secondHopProvider.id, 
          intermediateChainId, 
          toChainId
        );
        
        // If no historical data, use the provider's base reliability
        final firstReliability = firstHopReliability > 0 ? firstHopReliability : firstHopProvider.reliabilityScore;
        final secondReliability = secondHopReliability > 0 ? secondHopReliability : secondHopProvider.reliabilityScore;
        
        final reliabilityScore = (firstReliability + secondReliability) / 2;
        
        final route = BridgeRoute(
          id: 'route_${firstHopProvider.id}_${secondHopProvider.id}_via_${intermediateChainId}',
          hops: [firstHop, secondHop],
          totalFeeAmount: firstHopFee + secondHopFee,
          primaryFeeToken: token.symbol,
          totalEstimatedTimeMinutes: adjustedTime,
          reliabilityScore: reliabilityScore * 0.9, // Multi-hop routes are inherently less reliable
          isDirectRoute: false,
        );
        
        routes.add(route);
      }
    }
    
    // Limit to top 3 multi-hop routes to avoid overwhelming the user
    routes.sort((a, b) => _prioritizeCost 
        ? a.totalFeeAmount.compareTo(b.totalFeeAmount)
        : a.totalEstimatedTimeMinutes.compareTo(b.totalEstimatedTimeMinutes));
    
    return routes.take(3).toList();
  }
  
  // Select the best provider based on historical data
  BridgeProvider _selectBestProvider(List<BridgeProvider> providers, int fromChainId, int toChainId) {
    if (providers.length == 1) {
      return providers.first;
    }
    
    // Score each provider based on historical data and user preferences
    final scores = <BridgeProvider, double>{};
    
    for (final provider in providers) {
      double score = 0;
      
      // Get metrics from historical data
      final metrics = _historicalDataService.getMetrics(provider.id, fromChainId, toChainId);
      
      if (metrics != null) {
        // Score based on success rate (0-40 points)
        score += metrics.successRate * 40;
        
        // Score based on execution time (0-30 points)
        // Normalize: 0-60s is excellent, 60-300s is good, >300s is poor
        score += 30 * (1 - (metrics.averageExecutionTimeSeconds / 300).clamp(0, 1));
        
        // Score based on fee accuracy (0-20 points)
        score += metrics.feeAccuracy * 20;
        
        // Score based on slippage (0-10 points)
        score += 10 * (1 - (metrics.averageSlippagePercent / 5).clamp(0, 1));
      } else {
        // If no historical data, use the provider's base reliability
        score = provider.reliabilityScore;
      }
      
      // Adjust score based on user preferences
      if (_prioritizeCost) {
        // Penalize high fees
        score -= provider.feePercentage * 10;
      } else {
        // Penalize slow bridges
        score -= provider.estimatedTimeMinutes * 0.5;
      }
      
      scores[provider] = score;
    }
    
    // Return provider with highest score
    return scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
  
  // Select a specific route
  void selectRoute(String routeId) {
    final route = _availableRoutes.firstWhere((r) => r.id == routeId);
    _selectedRoute = route;
    notifyListeners();
  }
  
  // Get analysis for a specific route
  RouteAnalysis? getRouteAnalysis(String routeId) {
    return _routeAnalysis[routeId];
  }
  
  // Get analysis for the selected route
  RouteAnalysis? getSelectedRouteAnalysis() {
    if (_selectedRoute == null) return null;
    return _routeAnalysis[_selectedRoute!.id];
  }
}
