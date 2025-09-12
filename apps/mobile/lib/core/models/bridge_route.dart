class BridgeProvider {
  final String id;
  final String name;
  final String logoUrl;
  final double feePercentage;
  final int estimatedTimeMinutes;
  final List<int> supportedChains;
  final double reliabilityScore; // 0-100
  
  BridgeProvider({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.feePercentage,
    required this.estimatedTimeMinutes,
    required this.supportedChains,
    required this.reliabilityScore,
  });
}

class RouteHop {
  final int fromChainId;
  final int toChainId;
  final BridgeProvider provider;
  final double feeAmount;
  final String feeToken;
  final int estimatedTimeMinutes;
  
  RouteHop({
    required this.fromChainId,
    required this.toChainId,
    required this.provider,
    required this.feeAmount,
    required this.feeToken,
    required this.estimatedTimeMinutes,
  });
}

class BridgeRoute {
  final String id;
  final List<RouteHop> hops;
  final double totalFeeAmount;
  final String primaryFeeToken;
  final int totalEstimatedTimeMinutes;
  final double reliabilityScore; // 0-100
  final bool isDirectRoute;
  
  BridgeRoute({
    required this.id,
    required this.hops,
    required this.totalFeeAmount,
    required this.primaryFeeToken,
    required this.totalEstimatedTimeMinutes,
    required this.reliabilityScore,
    required this.isDirectRoute,
  });
  
  int get hopCount => hops.length;
  
  List<int> get involvedChains {
    final chains = <int>[];
    chains.add(hops.first.fromChainId);
    for (final hop in hops) {
      chains.add(hop.toChainId);
    }
    return chains;
  }
  
  String get routeDescription {
    if (isDirectRoute) {
      return 'Direct route via ${hops.first.provider.name}';
    } else {
      return 'Multi-hop route (${hops.length} hops)';
    }
  }
}
