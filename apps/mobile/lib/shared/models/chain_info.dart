class ChainInfo {
  final int chainId;
  final String name;
  final String shortName;
  final String symbol;
  final bool isEVM;
  final bool testnet;
  final String rpcUrl;
  final String explorerUrl;

  const ChainInfo({
    required this.chainId,
    required this.name,
    required this.shortName,
    required this.symbol,
    required this.isEVM,
    this.testnet = true,
    this.rpcUrl = '',
    this.explorerUrl = '',
  });

  factory ChainInfo.fromJson(Map<String, dynamic> json) {
    return ChainInfo(
      chainId: json['chainId'] as int,
      name: json['name'] as String,
      shortName: json['shortName'] as String,
      symbol: json['symbol'] as String,
      isEVM: json['isEVM'] as bool? ?? true,
      testnet: json['testnet'] as bool? ?? true,
      rpcUrl: json['rpcUrl'] as String? ?? '',
      explorerUrl: json['explorerUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chainId': chainId,
      'name': name,
      'shortName': shortName,
      'symbol': symbol,
      'isEVM': isEVM,
      'testnet': testnet,
      'rpcUrl': rpcUrl,
      'explorerUrl': explorerUrl,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChainInfo &&
          runtimeType == other.runtimeType &&
          chainId == other.chainId;

  @override
  int get hashCode => chainId.hashCode;
}
