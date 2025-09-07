class AppConstants {
  // API URLs
  static const String apiBaseUrl = 'http://localhost:3000';
  static const String apiVersion = 'v1';
  
  // Routes
  static const String homeRoute = '/';
  static const String bridgeRoute = '/bridge';
  static const String activityRoute = '/activity';
  static const String workspacesRoute = '/workspaces';
  static const String settingsRoute = '/settings';
  
  // Storage keys
  static const String walletAddressKey = 'wallet_address';
  static const String selectedChainKey = 'selected_chain';
  static const String themeKey = 'theme_mode';
  
  // Transaction statuses
  static const String statusPending = 'pending';
  static const String statusProcessing = 'processing';
  static const String statusCompleted = 'completed';
  static const String statusFailed = 'failed';
  
  // Supported chains (matching backend)
  static const List<Map<String, dynamic>> supportedChains = [
    {
      'chainId': 11155111,
      'name': 'Sepolia Testnet',
      'shortName': 'sep',
      'symbol': 'ETH',
      'isEVM': true,
    },
    {
      'chainId': 80002,
      'name': 'Polygon Amoy',
      'shortName': 'amoy',
      'symbol': 'MATIC',
      'isEVM': true,
    },
    {
      'chainId': 421614,
      'name': 'Arbitrum Sepolia',
      'shortName': 'arb-sep',
      'symbol': 'ETH',
      'isEVM': true,
    },
    {
      'chainId': 43113,
      'name': 'Avalanche Fuji',
      'shortName': 'fuji',
      'symbol': 'AVAX',
      'isEVM': true,
    },
    {
      'chainId': 97,
      'name': 'BNB Chain Testnet',
      'shortName': 'bnbt',
      'symbol': 'tBNB',
      'isEVM': true,
    },
  ];
}
