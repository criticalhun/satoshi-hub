import 'package:flutter/foundation.dart';
import 'dart:math';
import 'dart:async';
import 'package:satoshi_hub/core/models/price_data.dart';
import 'package:satoshi_hub/core/models/token.dart';

class PriceService extends ChangeNotifier {
  // Random generator for mock data
  final Random _random = Random();
  
  // Timer for periodic updates
  Timer? _updateTimer;
  
  // Cache for price data
  final Map<String, PriceData> _priceCache = {};
  
  // Cache for token pairs
  final Map<String, TokenPair> _pairCache = {};
  
  // Selected time range for charts
  String _selectedTimeRange = '7d';
  
  // Getters
  String get selectedTimeRange => _selectedTimeRange;
  
  // Constructor
  PriceService() {
    // Initialize with default data
    _initializeData();
    
    // Set up periodic updates every 30 seconds
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updatePrices();
    });
  }
  
  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
  
  // Initialize price data
  void _initializeData() {
    final tokens = [
      'ETH', 'MATIC', 'BNB', 'AVAX', 'USDT', 'USDC', 
      'DAI', 'WBTC', 'UNI', 'AAVE', 'SUSHI', 'CAKE', 'JOE'
    ];
    
    // Initialize price data for each token
    for (final symbol in tokens) {
      _priceCache[symbol] = _generateMockPriceData(symbol);
    }
    
    // Initialize some common token pairs
    _pairCache['ETH/USDT'] = _generateMockTokenPair('ETH', 'USDT');
    _pairCache['BTC/USDT'] = _generateMockTokenPair('WBTC', 'USDT');
    _pairCache['ETH/BTC'] = _generateMockTokenPair('ETH', 'WBTC');
    _pairCache['BNB/USDT'] = _generateMockTokenPair('BNB', 'USDT');
    _pairCache['MATIC/USDT'] = _generateMockTokenPair('MATIC', 'USDT');
    _pairCache['AVAX/USDT'] = _generateMockTokenPair('AVAX', 'USDT');
    
    notifyListeners();
  }
  
  // Update prices periodically
  void _updatePrices() {
    // Update token prices with small variations
    _priceCache.forEach((symbol, data) {
      final priceChange = data.price * (_random.nextDouble() * 0.02 - 0.01); // +/- 1%
      final newPrice = data.price + priceChange;
      
      // Add a new data point to the chart
      final now = DateTime.now();
      final newPoint = ChartDataPoint(timestamp: now, price: newPrice);
      
      final updatedChartData7d = List<ChartDataPoint>.from(data.chartData7d);
      final updatedChartData30d = List<ChartDataPoint>.from(data.chartData30d);
      
      // Add new point and remove old ones if needed
      updatedChartData7d.add(newPoint);
      updatedChartData30d.add(newPoint);
      
      // Keep only last 7 days worth of data (168 points at 1 hour interval)
      if (updatedChartData7d.length > 168) {
        updatedChartData7d.removeAt(0);
      }
      
      // Keep only last 30 days worth of data (720 points at 1 hour interval)
      if (updatedChartData30d.length > 720) {
        updatedChartData30d.removeAt(0);
      }
      
      // Calculate new 24h high and low
      final high = max(data.high24h, newPrice);
      final low = data.low24h > 0 ? min(data.low24h, newPrice) : newPrice;
      
      // Get the last 24 data points for 24h price change calculation
      final last24hData = updatedChartData7d.length > 24 
          ? updatedChartData7d.sublist(updatedChartData7d.length - 24) 
          : updatedChartData7d;
      
      // Calculate new 24h price change percentage
      final priceChangePercent = last24hData.isNotEmpty && last24hData.first.price > 0
          ? ((newPrice - last24hData.first.price) / last24hData.first.price) * 100
          : 0.0;
      
      // Update price data
      _priceCache[symbol] = PriceData(
        symbol: symbol,
        price: newPrice,
        priceChangePercentage24h: priceChangePercent,
        marketCap: data.marketCap * (newPrice / data.price), // Adjust market cap based on price change
        volume24h: data.volume24h * (1 + (_random.nextDouble() * 0.1 - 0.05)), // Adjust volume +/- 5%
        high24h: high,
        low24h: low,
        lastUpdated: now,
        chartData7d: updatedChartData7d,
        chartData30d: updatedChartData30d,
      );
    });
    
    // Update token pairs
    _pairCache.forEach((pairSymbol, pair) {
      final parts = pairSymbol.split('/');
      final baseSymbol = parts[0];
      final quoteSymbol = parts[1];
      
      if (_priceCache.containsKey(baseSymbol) && _priceCache.containsKey(quoteSymbol)) {
        final basePrice = _priceCache[baseSymbol]!.price;
        final quotePrice = _priceCache[quoteSymbol]!.price;
        
        // Calculate new exchange rate
        final newRate = basePrice / quotePrice;
        
        // Add a new data point to the chart
        final now = DateTime.now();
        final newPoint = ChartDataPoint(timestamp: now, price: newRate);
        
        final updatedChartData = List<ChartDataPoint>.from(pair.chartData);
        updatedChartData.add(newPoint);
        
        // Keep only last 7 days worth of data (168 points at 1 hour interval)
        if (updatedChartData.length > 168) {
          updatedChartData.removeAt(0);
        }
        
        // Calculate new 24h price change percentage
        final priceChangePercent = updatedChartData.isNotEmpty && updatedChartData.first.price > 0
            ? ((newRate - updatedChartData.first.price) / updatedChartData.first.price) * 100
            : 0.0;
        
        // Update pair data
        _pairCache[pairSymbol] = TokenPair(
          baseSymbol: baseSymbol,
          quoteSymbol: quoteSymbol,
          exchangeRate: newRate,
          priceChangePercentage24h: priceChangePercent,
          volume24h: pair.volume24h * (1 + (_random.nextDouble() * 0.1 - 0.05)), // Adjust volume +/- 5%
          chartData: updatedChartData,
          lastUpdated: now,
        );
      }
    });
    
    notifyListeners();
  }
  
  // Generate mock price data for a token
  PriceData _generateMockPriceData(String symbol) {
    double basePrice;
    double marketCap;
    double volume;
    
    // Set realistic base values for each token
    switch (symbol) {
      case 'ETH':
        basePrice = 3000.0;
        marketCap = 350000000000.0;
        volume = 15000000000.0;
        break;
      case 'WBTC':
        basePrice = 50000.0;
        marketCap = 900000000000.0;
        volume = 30000000000.0;
        break;
      case 'BNB':
        basePrice = 400.0;
        marketCap = 60000000000.0;
        volume = 2000000000.0;
        break;
      case 'MATIC':
        basePrice = 1.5;
        marketCap = 10000000000.0;
        volume = 500000000.0;
        break;
      case 'AVAX':
        basePrice = 35.0;
        marketCap = 8000000000.0;
        volume = 400000000.0;
        break;
      case 'USDT':
      case 'USDC':
      case 'DAI':
        basePrice = 1.0;
        marketCap = 80000000000.0;
        volume = 50000000000.0;
        break;
      case 'UNI':
        basePrice = 15.0;
        marketCap = 7000000000.0;
        volume = 300000000.0;
        break;
      case 'AAVE':
        basePrice = 150.0;
        marketCap = 2000000000.0;
        volume = 200000000.0;
        break;
      case 'SUSHI':
        basePrice = 2.0;
        marketCap = 500000000.0;
        volume = 100000000.0;
        break;
      case 'CAKE':
        basePrice = 5.0;
        marketCap = 800000000.0;
        volume = 150000000.0;
        break;
      case 'JOE':
        basePrice = 0.5;
        marketCap = 200000000.0;
        volume = 50000000.0;
        break;
      default:
        basePrice = 10.0;
        marketCap = 1000000000.0;
        volume = 100000000.0;
    }
    
    // Add some randomness to price
    final price = basePrice * (1 + (_random.nextDouble() * 0.1 - 0.05)); // +/- 5%
    
    // Generate chart data for last 7 days (hourly data points)
    final chartData7d = _generateChartData(price, 168); // 7 days * 24 hours
    
    // Generate chart data for last 30 days (hourly data points)
    final chartData30d = _generateChartData(price, 720); // 30 days * 24 hours
    
    // Calculate 24h price change percentage
    final last24h = chartData7d.length > 24 
        ? chartData7d.sublist(chartData7d.length - 24) 
        : chartData7d;
    
    final priceChangePercent = last24h.isNotEmpty
        ? ((price - last24h.first.price) / last24h.first.price) * 100
        : 0.0;
    
    // Calculate 24h high and low
    double high = price;
    double low = price;
    for (int i = chartData7d.length - 24; i < chartData7d.length; i++) {
      if (i >= 0) {
        high = max(high, chartData7d[i].price);
        low = min(low, chartData7d[i].price);
      }
    }
    
    return PriceData(
      symbol: symbol,
      price: price,
      priceChangePercentage24h: priceChangePercent,
      marketCap: marketCap,
      volume24h: volume,
      high24h: high,
      low24h: low,
      lastUpdated: DateTime.now(),
      chartData7d: chartData7d,
      chartData30d: chartData30d,
    );
  }
  
  // Generate mock token pair data
  TokenPair _generateMockTokenPair(String baseSymbol, String quoteSymbol) {
    // Calculate exchange rate from token prices
    final basePrice = _priceCache[baseSymbol]?.price ?? 100.0;
    final quotePrice = _priceCache[quoteSymbol]?.price ?? 1.0;
    final exchangeRate = basePrice / quotePrice;
    
    // Generate chart data for the pair (7 days)
    final chartData = _generateChartData(exchangeRate, 168);
    
    // Calculate 24h price change percentage
    final last24h = chartData.length > 24 
        ? chartData.sublist(chartData.length - 24) 
        : chartData;
    
    final priceChangePercent = last24h.isNotEmpty
        ? ((exchangeRate - last24h.first.price) / last24h.first.price) * 100
        : 0.0;
    
    // Set volume based on token popularity
    double volume;
    if (baseSymbol == 'ETH' || baseSymbol == 'WBTC' || quoteSymbol == 'USDT') {
      volume = 5000000000.0 * (1 + (_random.nextDouble() * 0.5 - 0.25)); // +/- 25%
    } else {
      volume = 500000000.0 * (1 + (_random.nextDouble() * 0.5 - 0.25)); // +/- 25%
    }
    
    return TokenPair(
      baseSymbol: baseSymbol,
      quoteSymbol: quoteSymbol,
      exchangeRate: exchangeRate,
      priceChangePercentage24h: priceChangePercent,
      volume24h: volume,
      chartData: chartData,
      lastUpdated: DateTime.now(),
    );
  }
  
  // Generate realistic looking chart data with trends and patterns
  List<ChartDataPoint> _generateChartData(double currentPrice, int dataPoints) {
    final data = <ChartDataPoint>[];
    final now = DateTime.now();
    
    // Start from oldest data point
    final startTime = now.subtract(Duration(hours: dataPoints));
    
    // Generate the first price (10-20% lower or higher than current price)
    final startPriceVariation = currentPrice * (_random.nextDouble() * 0.3 - 0.15); // +/- 15%
    double price = currentPrice + startPriceVariation;
    
    // Ensure price is positive
    price = max(price, currentPrice * 0.5);
    
    // Create trends and patterns
    final trendPeriods = _random.nextInt(3) + 2; // 2-4 trend periods
    final trendsLengths = List.generate(trendPeriods, (_) => dataPoints ~/ trendPeriods);
    
    // Ensure last trend period length is adjusted to match total data points
    int totalLength = trendsLengths.fold(0, (sum, length) => sum + length);
    trendsLengths[trendPeriods - 1] += dataPoints - totalLength;
    
    // Generate trends
    int currentPoint = 0;
    for (int i = 0; i < trendPeriods; i++) {
      // Decide trend direction (up, down, or sideways)
      double trendStrength;
      if (i == trendPeriods - 1) {
        // Last trend should lead to current price
        final totalChange = currentPrice - price;
        trendStrength = totalChange / trendsLengths[i] / price;
      } else {
        trendStrength = _random.nextDouble() * 0.002 * (_random.nextBool() ? 1 : -1); // +/- 0.2% per point
      }
      
      // Generate data for this trend
      for (int j = 0; j < trendsLengths[i]; j++) {
        // Add some noise to the trend
        final noise = price * (_random.nextDouble() * 0.01 - 0.005); // +/- 0.5%
        
        // Update price with trend and noise
        price = price * (1 + trendStrength) + noise;
        
        // Ensure price is positive
        price = max(price, 0.000001);
        
        // Calculate timestamp
        final timestamp = startTime.add(Duration(hours: currentPoint));
        
        // Add data point
        data.add(ChartDataPoint(timestamp: timestamp, price: price));
        
        currentPoint++;
      }
    }
    
    // Ensure the last point matches current price
    if (data.isNotEmpty) {
      data.last = ChartDataPoint(timestamp: data.last.timestamp, price: currentPrice);
    }
    
    return data;
  }
  
  // Get price data for a token
  PriceData? getPriceData(String symbol) {
    return _priceCache[symbol];
  }
  
  // Get token pair data
  TokenPair? getTokenPair(String baseSymbol, String quoteSymbol) {
    final key = '$baseSymbol/$quoteSymbol';
    return _pairCache[key];
  }
  
  // Get token pair data by key
  TokenPair? getTokenPairByKey(String key) {
    return _pairCache[key];
  }
  
  // Get all available token pairs
  List<String> getAvailablePairs() {
    return _pairCache.keys.toList();
  }
  
  // Set selected time range
  void setTimeRange(String range) {
    if (_selectedTimeRange != range) {
      _selectedTimeRange = range;
      notifyListeners();
    }
  }
  
  // Get chart data based on selected time range
  List<ChartDataPoint> getChartData(String symbol) {
    final data = _priceCache[symbol];
    if (data == null) return [];
    
    if (_selectedTimeRange == '7d') {
      return data.chartData7d;
    } else if (_selectedTimeRange == '30d') {
      return data.chartData30d;
    } else {
      return data.chartData7d;
    }
  }
  
  // Calculate exchange rate between two tokens
  double calculateExchangeRate(String fromSymbol, String toSymbol) {
    final fromPrice = _priceCache[fromSymbol]?.price;
    final toPrice = _priceCache[toSymbol]?.price;
    
    if (fromPrice == null || toPrice == null) return 0;
    
    return fromPrice / toPrice;
  }
}
