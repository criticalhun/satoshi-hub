class PriceData {
  final String symbol;
  final double price;
  final double priceChangePercentage24h;
  final double marketCap;
  final double volume24h;
  final double high24h;
  final double low24h;
  final DateTime lastUpdated;
  final List<ChartDataPoint> chartData7d;
  final List<ChartDataPoint> chartData30d;
  
  PriceData({
    required this.symbol,
    required this.price,
    required this.priceChangePercentage24h,
    required this.marketCap,
    required this.volume24h,
    required this.high24h,
    required this.low24h,
    required this.lastUpdated,
    required this.chartData7d,
    required this.chartData30d,
  });
  
  // Helper method to get formatted price with right decimal places
  String get formattedPrice {
    if (price < 0.01) {
      return '\$${price.toStringAsFixed(6)}';
    } else if (price < 1) {
      return '\$${price.toStringAsFixed(4)}';
    } else if (price < 10000) {
      return '\$${price.toStringAsFixed(2)}';
    } else {
      return '\$${price.toStringAsFixed(0)}';
    }
  }
  
  // Helper method to get formatted market cap with K, M, B suffix
  String get formattedMarketCap {
    if (marketCap < 1000000) {
      return '\$${(marketCap / 1000).toStringAsFixed(2)}K';
    } else if (marketCap < 1000000000) {
      return '\$${(marketCap / 1000000).toStringAsFixed(2)}M';
    } else {
      return '\$${(marketCap / 1000000000).toStringAsFixed(2)}B';
    }
  }
  
  // Helper method to get formatted volume with K, M, B suffix
  String get formattedVolume {
    if (volume24h < 1000000) {
      return '\$${(volume24h / 1000).toStringAsFixed(2)}K';
    } else if (volume24h < 1000000000) {
      return '\$${(volume24h / 1000000).toStringAsFixed(2)}M';
    } else {
      return '\$${(volume24h / 1000000000).toStringAsFixed(2)}B';
    }
  }
  
  // Helper method to get formatted price change with +/- sign
  String get formattedPriceChange {
    final sign = priceChangePercentage24h >= 0 ? '+' : '';
    return '$sign${priceChangePercentage24h.toStringAsFixed(2)}%';
  }
  
  // Helper method to get color for price change
  bool get isPriceUp => priceChangePercentage24h >= 0;
  
  // Last 24 hours chart data
  List<ChartDataPoint> get chartData24h {
    // Get the last 24 data points from the 7d chart (assuming hourly data points)
    if (chartData7d.length >= 24) {
      return chartData7d.sublist(chartData7d.length - 24);
    } else {
      return chartData7d;
    }
  }
}

class ChartDataPoint {
  final DateTime timestamp;
  final double price;
  
  ChartDataPoint({
    required this.timestamp,
    required this.price,
  });
}

class TokenPair {
  final String baseSymbol;
  final String quoteSymbol;
  final double exchangeRate;
  final double priceChangePercentage24h;
  final double volume24h;
  final List<ChartDataPoint> chartData;
  final DateTime lastUpdated;
  
  TokenPair({
    required this.baseSymbol,
    required this.quoteSymbol,
    required this.exchangeRate,
    required this.priceChangePercentage24h,
    required this.volume24h,
    required this.chartData,
    required this.lastUpdated,
  });
  
  // Helper method to get formatted exchange rate with right decimal places
  String get formattedExchangeRate {
    if (exchangeRate < 0.01) {
      return exchangeRate.toStringAsFixed(6);
    } else if (exchangeRate < 1) {
      return exchangeRate.toStringAsFixed(4);
    } else if (exchangeRate < 10000) {
      return exchangeRate.toStringAsFixed(2);
    } else {
      return exchangeRate.toStringAsFixed(0);
    }
  }
  
  // Helper method to get formatted price change with +/- sign
  String get formattedPriceChange {
    final sign = priceChangePercentage24h >= 0 ? '+' : '';
    return '$sign${priceChangePercentage24h.toStringAsFixed(2)}%';
  }
  
  // Helper method to get color for price change
  bool get isPriceUp => priceChangePercentage24h >= 0;
}
