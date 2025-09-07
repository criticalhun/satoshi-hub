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
    required this.testnet,
    required this.rpcUrl,
    required this.explorerUrl,
  });

  factory ChainInfo.fromJson(Map<String, dynamic> json) {
    return ChainInfo(
      chainId: json['chainId'] as int,
      name: json['name'] as String,
      shortName: json['shortName'] as String,
      symbol: json['nativeCurrency']['symbol'] as String,
      isEVM: json['isEVM'] as bool,
      testnet: json['testnet'] as bool,
      rpcUrl: (json['rpc'] as List<dynamic>).first as String,
      explorerUrl: json['explorers']?.isNotEmpty == true 
          ? json['explorers'][0]['url'] as String
          : '',
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
}
