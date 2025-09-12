import 'package:satoshi_hub/core/models/token.dart';

/// Adattranszfer objektum a tokenek API-hoz való illesztéséhez
class TokenDTO {
  final String address;
  final String symbol;
  final String name;
  final String logoUrl;
  final int decimals;
  final String balance;
  final List<int> supportedChains;
  final bool isNative;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  TokenDTO({
    required this.address,
    required this.symbol,
    required this.name,
    required this.logoUrl,
    required this.decimals,
    required this.balance,
    required this.supportedChains,
    required this.isNative,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory TokenDTO.fromJson(Map<String, dynamic> json) {
    return TokenDTO(
      address: json['address'],
      symbol: json['symbol'],
      name: json['name'],
      logoUrl: json['logoUrl'],
      decimals: json['decimals'],
      balance: json['balance'],
      supportedChains: List<int>.from(json['supportedChains']),
      isNative: json['isNative'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  // Konvertálás Token modellé
  Token toToken() {
    return Token(
      address: address,
      symbol: symbol,
      name: name,
      logoUrl: logoUrl,
      decimals: decimals,
      balance: balance,
      supportedChains: supportedChains,
      isNative: isNative,
    );
  }
  
  // Létrehozás Token modellből
  static TokenDTO fromToken(Token token) {
    return TokenDTO(
      address: token.address,
      symbol: token.symbol,
      name: token.name,
      logoUrl: token.logoUrl,
      decimals: token.decimals,
      balance: token.balance,
      supportedChains: token.supportedChains,
      isNative: token.isNative,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
