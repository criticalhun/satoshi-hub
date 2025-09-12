class SwapProvider {
  final String id;
  final String name;
  final String logoUrl;
  final double feePercentage;
  final List<int> supportedChains;
  final List<String> supportedTokens;
  final double reliabilityScore; // 0-100
  
  SwapProvider({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.feePercentage,
    required this.supportedChains,
    required this.supportedTokens,
    required this.reliabilityScore,
  });
}

class SwapQuote {
  final String id;
  final String fromTokenAddress;
  final String toTokenAddress;
  final String fromTokenSymbol;
  final String toTokenSymbol;
  final String fromAmount;
  final String toAmount;
  final SwapProvider provider;
  final double feeAmount;
  final String feeToken;
  final double priceImpact;
  final double slippagePercent;
  final String minimumReceived;
  final int estimatedTimeSeconds;
  
  SwapQuote({
    required this.id,
    required this.fromTokenAddress,
    required this.toTokenAddress,
    required this.fromTokenSymbol,
    required this.toTokenSymbol,
    required this.fromAmount,
    required this.toAmount,
    required this.provider,
    required this.feeAmount,
    required this.feeToken,
    required this.priceImpact,
    required this.slippagePercent,
    required this.minimumReceived,
    required this.estimatedTimeSeconds,
  });
  
  double get exchangeRate => double.parse(toAmount) / double.parse(fromAmount);
}

class SwapRoute {
  final String id;
  final List<SwapQuote> steps;
  final String fromTokenAddress;
  final String toTokenAddress;
  final String fromTokenSymbol;
  final String toTokenSymbol;
  final String fromAmount;
  final String toAmount;
  final double totalFeeAmount;
  final String primaryFeeToken;
  final double totalPriceImpact;
  final int totalEstimatedTimeSeconds;
  final bool isDirectSwap;
  
  SwapRoute({
    required this.id,
    required this.steps,
    required this.fromTokenAddress,
    required this.toTokenAddress,
    required this.fromTokenSymbol,
    required this.toTokenSymbol,
    required this.fromAmount,
    required this.toAmount,
    required this.totalFeeAmount,
    required this.primaryFeeToken,
    required this.totalPriceImpact,
    required this.totalEstimatedTimeSeconds,
    required this.isDirectSwap,
  });
  
  int get stepCount => steps.length;
  
  List<String> get involvedTokens {
    final tokens = <String>[];
    tokens.add(fromTokenSymbol);
    for (int i = 0; i < steps.length - 1; i++) {
      tokens.add(steps[i].toTokenSymbol);
    }
    tokens.add(toTokenSymbol);
    return tokens;
  }
  
  String get routeDescription {
    if (isDirectSwap) {
      return 'Direct swap via ${steps.first.provider.name}';
    } else {
      return 'Multi-step swap (${steps.length} steps)';
    }
  }
  
  double get effectiveExchangeRate => double.parse(toAmount) / double.parse(fromAmount);
  
  double get minimumExchangeRate {
    final minReceived = double.parse(toAmount) * (1 - totalPriceImpact / 100);
    return minReceived / double.parse(fromAmount);
  }
}
