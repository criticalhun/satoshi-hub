class Chain {
  final int chainId;
  final String name;
  final String fullName;
  final String rpcUrl;
  final String explorerUrl;
  final String iconUrl;
  final String nativeToken;
  final String nativeTokenSymbol;
  final int decimals;
  final String color;
  final String shortName;

  Chain({
    required this.chainId,
    required this.name,
    required this.fullName,
    required this.rpcUrl,
    required this.explorerUrl,
    required this.iconUrl,
    required this.nativeToken,
    required this.nativeTokenSymbol,
    required this.decimals,
    required this.color,
    required this.shortName,
  });

  Map<String, dynamic> toJson() {
    return {
      'chainId': chainId,
      'name': name,
      'fullName': fullName,
      'rpcUrl': rpcUrl,
      'explorerUrl': explorerUrl,
      'iconUrl': iconUrl,
      'nativeToken': nativeToken,
      'nativeTokenSymbol': nativeTokenSymbol,
      'decimals': decimals,
      'color': color,
      'shortName': shortName,
    };
  }

  factory Chain.fromJson(Map<String, dynamic> json) {
    return Chain(
      chainId: json['chainId'],
      name: json['name'],
      fullName: json['fullName'],
      rpcUrl: json['rpcUrl'],
      explorerUrl: json['explorerUrl'],
      iconUrl: json['iconUrl'],
      nativeToken: json['nativeToken'],
      nativeTokenSymbol: json['nativeTokenSymbol'],
      decimals: json['decimals'],
      color: json['color'],
      shortName: json['shortName'],
    );
  }
}
