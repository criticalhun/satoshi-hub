class ChainInfo {
  final String name;
  final int chainId;
  final String symbol;
  final String rpcUrl;
  final String blockExplorer;

  const ChainInfo({
    required this.name,
    required this.chainId,
    required this.symbol,
    required this.rpcUrl,
    required this.blockExplorer,
  });

  factory ChainInfo.fromJson(Map<String, dynamic> json) {
    return ChainInfo(
      name: json['name'] as String,
      chainId: json['chainId'] as int,
      symbol: json['symbol'] as String,
      rpcUrl: json['rpcUrl'] as String,
      blockExplorer: json['blockExplorer'] as String,
    );
  }
}
