class AppConstants {
  static const String appName = 'Satoshi Hub';
  // Állítsuk be a valódi backend URL-t
  static const String apiBaseUrl = 'http://localhost:3001';
  
  static const List<Map<String, dynamic>> supportedChains = [
    {
      'chainId': 11155111,
      'name': 'Sepolia',
      'symbol': 'ETH',
      'rpcUrl': 'https://rpc.sepolia.org',
      'blockExplorer': 'https://sepolia.etherscan.io',
    },
    {
      'chainId': 80001,
      'name': 'Mumbai',
      'symbol': 'MATIC',
      'rpcUrl': 'https://rpc-mumbai.maticvigil.com',
      'blockExplorer': 'https://mumbai.polygonscan.com',
    },
  ];
}
