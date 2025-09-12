class Token {
  final String address;
  final String symbol;
  final String name;
  final String logoUrl;
  final int decimals;
  final String balance;
  final List<int> supportedChains;
  final bool isNative;
  
  Token({
    required this.address,
    required this.symbol,
    required this.name,
    required this.logoUrl,
    required this.decimals,
    required this.balance,
    required this.supportedChains,
    required this.isNative,
  });
  
  // Convert to Map
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'symbol': symbol,
      'name': name,
      'logoUrl': logoUrl,
      'decimals': decimals,
      'balance': balance,
      'supportedChains': supportedChains,
      'isNative': isNative,
    };
  }
  
  // Create from Map
  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      address: json['address'],
      symbol: json['symbol'],
      name: json['name'],
      logoUrl: json['logoUrl'],
      decimals: json['decimals'],
      balance: json['balance'],
      supportedChains: List<int>.from(json['supportedChains']),
      isNative: json['isNative'],
    );
  }
  
  // Return formatted balance
  String formattedBalance() {
    if (double.parse(balance) == 0) {
      return '0.0';
    }
    
    // Format based on token value
    final value = double.parse(balance);
    if (value < 0.0001) {
      return '<0.0001';
    } else if (value < 1) {
      return value.toStringAsFixed(4);
    } else if (value < 1000) {
      return value.toStringAsFixed(2);
    } else {
      return value.toStringAsFixed(0);
    }
  }
  
  // Create a copy with updated balance
  Token copyWithBalance(String newBalance) {
    return Token(
      address: address,
      symbol: symbol,
      name: name,
      logoUrl: logoUrl,
      decimals: decimals,
      balance: newBalance,
      supportedChains: supportedChains,
      isNative: isNative,
    );
  }
}
