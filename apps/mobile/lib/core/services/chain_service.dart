import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:satoshi_hub/core/models/chain.dart';

class ChainService extends ChangeNotifier {
  List<Chain> _chains = [];
  
  // Getters
  List<Chain> get chains => _chains;
  
  // Constructor
  ChainService() {
    _initChains();
  }
  
  // Initialize chains
  void _initChains() {
    _chains = [
      // Ethereum Sepolia
      Chain(
        chainId: 11155111,
        name: 'Sepolia',
        fullName: 'Ethereum Sepolia Testnet',
        rpcUrl: 'https://rpc.sepolia.org',
        explorerUrl: 'https://sepolia.etherscan.io',
        iconUrl: 'assets/images/ethereum_logo.png',
        nativeToken: 'Ether',
        nativeTokenSymbol: 'ETH',
        decimals: 18,
        color: '#627EEA',
        shortName: 'ETH',
      ),
      
      // Polygon Mumbai
      Chain(
        chainId: 80001,
        name: 'Mumbai',
        fullName: 'Polygon Mumbai Testnet',
        rpcUrl: 'https://rpc-mumbai.maticvigil.com',
        explorerUrl: 'https://mumbai.polygonscan.com',
        iconUrl: 'assets/images/polygon_logo.png',
        nativeToken: 'MATIC',
        nativeTokenSymbol: 'MATIC',
        decimals: 18,
        color: '#8247E5',
        shortName: 'MATIC',
      ),
      
      // Arbitrum Goerli
      Chain(
        chainId: 421613,
        name: 'Arbitrum Goerli',
        fullName: 'Arbitrum Goerli Testnet',
        rpcUrl: 'https://goerli-rollup.arbitrum.io/rpc',
        explorerUrl: 'https://goerli-explorer.arbitrum.io',
        iconUrl: 'assets/images/arbitrum_logo.png',
        nativeToken: 'Ether',
        nativeTokenSymbol: 'ETH',
        decimals: 18,
        color: '#28A0F0',
        shortName: 'ARB',
      ),
      
      // Optimism Goerli
      Chain(
        chainId: 420,
        name: 'Optimism Goerli',
        fullName: 'Optimism Goerli Testnet',
        rpcUrl: 'https://goerli.optimism.io',
        explorerUrl: 'https://goerli-explorer.optimism.io',
        iconUrl: 'assets/images/optimism_logo.png',
        nativeToken: 'Ether',
        nativeTokenSymbol: 'ETH',
        decimals: 18,
        color: '#FF0420',
        shortName: 'OP',
      ),
      
      // BNB Chain Testnet
      Chain(
        chainId: 97,
        name: 'BNB Testnet',
        fullName: 'BNB Chain Testnet',
        rpcUrl: 'https://data-seed-prebsc-1-s1.binance.org:8545',
        explorerUrl: 'https://testnet.bscscan.com',
        iconUrl: 'assets/images/bnb_logo.png',
        nativeToken: 'BNB',
        nativeTokenSymbol: 'BNB',
        decimals: 18,
        color: '#F3BA2F',
        shortName: 'BNB',
      ),
      
      // Avalanche Fuji
      Chain(
        chainId: 43113,
        name: 'Avalanche Fuji',
        fullName: 'Avalanche Fuji Testnet',
        rpcUrl: 'https://api.avax-test.network/ext/bc/C/rpc',
        explorerUrl: 'https://testnet.snowtrace.io',
        iconUrl: 'assets/images/avalanche_logo.png',
        nativeToken: 'AVAX',
        nativeTokenSymbol: 'AVAX',
        decimals: 18,
        color: '#E84142',
        shortName: 'AVAX',
      ),
    ];
    
    notifyListeners();
  }
  
  // Get chain by chainId
  Chain? getChainById(int chainId) {
    try {
      return _chains.firstWhere((chain) => chain.chainId == chainId);
    } catch (e) {
      return null;
    }
  }
  
  // Get chain name
  String getChainName(int chainId) {
    final chain = getChainById(chainId);
    return chain?.name ?? 'Unknown Chain';
  }
  
  // Get chain color
  Color getChainColor(int chainId) {
    final chain = getChainById(chainId);
    if (chain == null) return Colors.grey;
    
    // Parse hex color
    final hexColor = chain.color.replaceFirst('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }
  
  // Get native token symbol
  String getNativeTokenSymbol(int chainId) {
    final chain = getChainById(chainId);
    return chain?.nativeTokenSymbol ?? '';
  }
  
  // Get transaction explorer URL
  String getTransactionExplorerUrl(int chainId, String txHash) {
    final chain = getChainById(chainId);
    if (chain == null) return '';
    
    return '${chain.explorerUrl}/tx/$txHash';
  }
  
  // Get address explorer URL
  String getAddressExplorerUrl(int chainId, String address) {
    final chain = getChainById(chainId);
    if (chain == null) return '';
    
    return '${chain.explorerUrl}/address/$address';
  }
}
