import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:satoshi_hub/core/models/bridge_route.dart';
import 'package:satoshi_hub/core/services/chain_service.dart';

class BridgeProviderDetails {
  final String id;
  final String name;
  final String logoUrl;
  final String website;
  final String description;
  final List<int> supportedChains;
  final List<String> supportedTokens;
  final double feePercentage;
  final bool hasLiquidityFees;
  final bool hasGasFees;
  final int typicalTimeMinutes;
  final double reliabilityScore;
  final Map<String, dynamic> features;
  
  BridgeProviderDetails({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.website,
    required this.description,
    required this.supportedChains,
    required this.supportedTokens,
    required this.feePercentage,
    required this.hasLiquidityFees,
    required this.hasGasFees,
    required this.typicalTimeMinutes,
    required this.reliabilityScore,
    required this.features,
  });
  
  // Convert to BridgeProvider
  BridgeProvider toBridgeProvider() {
    return BridgeProvider(
      id: id,
      name: name,
      logoUrl: logoUrl,
      feePercentage: feePercentage,
      estimatedTimeMinutes: typicalTimeMinutes,
      supportedChains: supportedChains,
      reliabilityScore: reliabilityScore,
    );
  }
}

class BridgeProviderService extends ChangeNotifier {
  final ChainService _chainService;
  final Random _random = Random();
  
  // List of all bridge providers
  final List<BridgeProviderDetails> _providers = [];
  
  // Getters
  List<BridgeProviderDetails> get providers => _providers;
  
  // Constructor
  BridgeProviderService({required ChainService chainService})
      : _chainService = chainService {
    _initializeProviders();
  }
  
  // Initialize bridge providers
  void _initializeProviders() {
    // All chains supported by our app
    final allChains = _chainService.chains.map((chain) => chain.chainId).toList();
    
    // Common provider supporting all chains
    _providers.add(
      BridgeProviderDetails(
        id: 'anyswap',
        name: 'Anyswap',
        logoUrl: 'assets/images/providers/anyswap.png',
        website: 'https://anyswap.exchange',
        description: 'Anyswap is a fully decentralized cross chain swap protocol, based on Fusion DCRM technology, with automated pricing and liquidity system.',
        supportedChains: allChains,
        supportedTokens: ['ETH', 'USDT', 'USDC', 'DAI', 'WBTC'],
        feePercentage: 0.3,
        hasLiquidityFees: true,
        hasGasFees: true,
        typicalTimeMinutes: 15,
        reliabilityScore: 92,
        features: {
          'decentralized': true,
          'hasLiquidityPools': true,
          'requiresApproval': true,
          'hasMessageBridging': false,
          'hasNativeBridging': true,
        },
      ),
    );
    
    // Ethereum ecosystem providers
    _providers.add(
      BridgeProviderDetails(
        id: 'hop',
        name: 'Hop Protocol',
        logoUrl: 'assets/images/providers/hop.png',
        website: 'https://hop.exchange',
        description: 'Hop is a scalable rollup-to-rollup general token bridge. It allows users to send tokens from one rollup to another almost immediately without having to wait for the rollup\'s challenge period.',
        supportedChains: [11155111, 421613, 420], // Sepolia, Arbitrum, Optimism
        supportedTokens: ['ETH', 'USDT', 'USDC', 'DAI'],
        feePercentage: 0.2,
        hasLiquidityFees: true,
        hasGasFees: true,
        typicalTimeMinutes: 10,
        reliabilityScore: 95,
        features: {
          'decentralized': true,
          'hasLiquidityPools': true,
          'requiresApproval': true,
          'hasMessageBridging': false,
          'hasNativeBridging': true,
        },
      ),
    );
    
    // All L2s provider
    _providers.add(
      BridgeProviderDetails(
        id: 'across',
        name: 'Across',
        logoUrl: 'assets/images/providers/across.png',
        website: 'https://across.to',
        description: 'Across is a cross-chain bridge optimized for fast, secure, and low-cost token transfers. It leverages a unique bonded relayer model to provide near-instant transfers between chains.',
        supportedChains: [11155111, 421613, 420, 80001], // ETH L2s and Polygon
        supportedTokens: ['ETH', 'USDT', 'USDC', 'DAI'],
        feePercentage: 0.15,
        hasLiquidityFees: true,
        hasGasFees: false,
        typicalTimeMinutes: 12,
        reliabilityScore: 90,
        features: {
          'decentralized': true,
          'hasLiquidityPools': false,
          'requiresApproval': true,
          'hasMessageBridging': false,
          'hasNativeBridging': true,
        },
      ),
    );
    
    // Polygon specific provider
    _providers.add(
      BridgeProviderDetails(
        id: 'polygon',
        name: 'Polygon Bridge',
        logoUrl: 'assets/images/providers/polygon.png',
        website: 'https://wallet.polygon.technology/bridge',
        description: 'The Polygon Bridge allows users to transfer tokens between Ethereum and Polygon networks. It leverages the Plasma framework and a PoS security layer for fast and secure transfers.',
        supportedChains: [11155111, 80001], // Sepolia and Mumbai
        supportedTokens: ['ETH', 'USDT', 'USDC', 'DAI', 'WBTC', 'MATIC'],
        feePercentage: 0.1,
        hasLiquidityFees: false,
        hasGasFees: true,
        typicalTimeMinutes: 20,
        reliabilityScore: 98,
        features: {
          'decentralized': false,
          'hasLiquidityPools': false,
          'requiresApproval': true,
          'hasMessageBridging': true,
          'hasNativeBridging': true,
        },
      ),
    );
    
    // Avalanche specific provider
    _providers.add(
      BridgeProviderDetails(
        id: 'avalanche',
        name: 'Avalanche Bridge',
        logoUrl: 'assets/images/providers/avalanche.png',
        website: 'https://bridge.avax.network',
        description: 'The Avalanche Bridge enables quick, secure transfers between Avalanche and Ethereum with low fees. It uses a combination of Intel SGX and MPC technology for security.',
        supportedChains: [11155111, 43113], // Sepolia and Avalanche
        supportedTokens: ['ETH', 'USDT', 'USDC', 'DAI', 'WBTC', 'AVAX'],
        feePercentage: 0.1,
        hasLiquidityFees: false,
        hasGasFees: true,
        typicalTimeMinutes: 8,
        reliabilityScore: 97,
        features: {
          'decentralized': false,
          'hasLiquidityPools': false,
          'requiresApproval': true,
          'hasMessageBridging': false,
          'hasNativeBridging': true,
        },
      ),
    );
    
    // Arbitrum specific provider
    _providers.add(
      BridgeProviderDetails(
        id: 'arbitrum',
        name: 'Arbitrum Bridge',
        logoUrl: 'assets/images/providers/arbitrum.png',
        website: 'https://bridge.arbitrum.io',
        description: 'The Arbitrum Bridge allows users to transfer ETH and ERC-20 tokens between Ethereum and Arbitrum. It leverages optimistic rollups for fast, secure, and low-cost transfers.',
        supportedChains: [11155111, 421613], // Sepolia and Arbitrum
        supportedTokens: ['ETH', 'USDT', 'USDC', 'DAI', 'WBTC'],
        feePercentage: 0.05,
        hasLiquidityFees: false,
        hasGasFees: true,
        typicalTimeMinutes: 7,
        reliabilityScore: 96,
        features: {
          'decentralized': false,
          'hasLiquidityPools': false,
          'requiresApproval': true,
          'hasMessageBridging': true,
          'hasNativeBridging': true,
        },
      ),
    );
    
    // Optimism specific provider
    _providers.add(
      BridgeProviderDetails(
        id: 'optimism',
        name: 'Optimism Bridge',
        logoUrl: 'assets/images/providers/optimism.png',
        website: 'https://app.optimism.io/bridge',
        description: 'The Optimism Bridge enables transfers between Ethereum and Optimism networks. It uses optimistic rollups to provide fast, secure, and low-cost transfers while maintaining Ethereum-level security.',
        supportedChains: [11155111, 420], // Sepolia and Optimism
        supportedTokens: ['ETH', 'USDT', 'USDC', 'DAI', 'WBTC'],
        feePercentage: 0.05,
        hasLiquidityFees: false,
        hasGasFees: true,
        typicalTimeMinutes: 5,
        reliabilityScore: 94,
        features: {
          'decentralized': false,
          'hasLiquidityPools': false,
          'requiresApproval': true,
          'hasMessageBridging': true,
          'hasNativeBridging': true,
        },
      ),
    );
    
    // BNB specific provider
    _providers.add(
      BridgeProviderDetails(
        id: 'bnb',
        name: 'BNB Bridge',
        logoUrl: 'assets/images/providers/bnb.png',
        website: 'https://www.bnbchain.org/en/bridge',
        description: 'The BNB Bridge allows users to transfer tokens between Ethereum and BNB Chain. It is a centralized bridge operated by Binance that offers fast and secure transfers.',
        supportedChains: [11155111, 97], // Sepolia and BNB
        supportedTokens: ['ETH', 'USDT', 'USDC', 'DAI', 'WBTC', 'BNB'],
        feePercentage: 0.1,
        hasLiquidityFees: false,
        hasGasFees: true,
        typicalTimeMinutes: 10,
        reliabilityScore: 95,
        features: {
          'decentralized': false,
          'hasLiquidityPools': false,
          'requiresApproval': true,
          'hasMessageBridging': false,
          'hasNativeBridging': true,
        },
      ),
    );
    
    // Connext
    _providers.add(
      BridgeProviderDetails(
        id: 'connext',
        name: 'Connext',
        logoUrl: 'assets/images/providers/connext.png',
        website: 'https://connext.network',
        description: 'Connext is a cross-chain liquidity network that enables fast, non-custodial bridging between EVM chains and L2s. It uses state channels and liquidity providers to enable instant transfers.',
        supportedChains: [11155111, 421613, 420, 80001], // Ethereum, Arbitrum, Optimism, Polygon
        supportedTokens: ['ETH', 'USDT', 'USDC', 'DAI'],
        feePercentage: 0.08,
        hasLiquidityFees: true,
        hasGasFees: false,
        typicalTimeMinutes: 3,
        reliabilityScore: 89,
        features: {
          'decentralized': true,
          'hasLiquidityPools': true,
          'requiresApproval': true,
          'hasMessageBridging': true,
          'hasNativeBridging': false,
        },
      ),
    );
    
    // Synapse
    _providers.add(
      BridgeProviderDetails(
        id: 'synapse',
        name: 'Synapse',
        logoUrl: 'assets/images/providers/synapse.png',
        website: 'https://synapseprotocol.com',
        description: 'Synapse is a cross-chain layer for tokens and data. It enables cross-chain swaps, bridging, and messaging between multiple chains through a unified liquidity and messaging framework.',
        supportedChains: [11155111, 421613, 420, 80001, 43113], // All except BNB
        supportedTokens: ['ETH', 'USDT', 'USDC', 'DAI', 'WBTC'],
        feePercentage: 0.12,
        hasLiquidityFees: true,
        hasGasFees: false,
        typicalTimeMinutes: 5,
        reliabilityScore: 91,
        features: {
          'decentralized': true,
          'hasLiquidityPools': true,
          'requiresApproval': true,
          'hasMessageBridging': true,
          'hasNativeBridging': true,
        },
      ),
    );
    
    // cBridge
    _providers.add(
      BridgeProviderDetails(
        id: 'cbridge',
        name: 'cBridge',
        logoUrl: 'assets/images/providers/cbridge.png',
        website: 'https://cbridge.celer.network',
        description: 'cBridge is a multi-chain bridge powered by Celer Network. It enables quick, secure, and low-cost token transfers between different blockchains using a network of liquidity providers.',
        supportedChains: allChains,
        supportedTokens: ['ETH', 'USDT', 'USDC', 'DAI', 'WBTC', 'BNB', 'MATIC', 'AVAX'],
        feePercentage: 0.04,
        hasLiquidityFees: true,
        hasGasFees: false,
        typicalTimeMinutes: 8,
        reliabilityScore: 93,
        features: {
          'decentralized': true,
          'hasLiquidityPools': true,
          'requiresApproval': true,
          'hasMessageBridging': false,
          'hasNativeBridging': true,
        },
      ),
    );
    
    // Multichain (formerly AnySwap)
    _providers.add(
      BridgeProviderDetails(
        id: 'multichain',
        name: 'Multichain',
        logoUrl: 'assets/images/providers/multichain.png',
        website: 'https://multichain.org',
        description: 'Multichain (formerly AnySwap) is a cross-chain router protocol that enables cross-chain swaps and bridges. It supports multiple chains and uses a decentralized MPC network for security.',
        supportedChains: allChains,
        supportedTokens: ['ETH', 'USDT', 'USDC', 'DAI', 'WBTC', 'BNB', 'MATIC', 'AVAX'],
        feePercentage: 0.2,
        hasLiquidityFees: true,
        hasGasFees: true,
        typicalTimeMinutes: 15,
        reliabilityScore: 88,
        features: {
          'decentralized': true,
          'hasLiquidityPools': false,
          'requiresApproval': true,
          'hasMessageBridging': false,
          'hasNativeBridging': true,
        },
      ),
    );
    
    // Wormhole
    _providers.add(
      BridgeProviderDetails(
        id: 'wormhole',
        name: 'Wormhole',
        logoUrl: 'assets/images/providers/wormhole.png',
        website: 'https://wormhole.com',
        description: 'Wormhole is a generic message passing protocol that connects multiple chains. It enables token transfers, NFT movements, and arbitrary message passing between different blockchains.',
        supportedChains: [11155111, 80001, 97, 43113], // Ethereum, Polygon, BNB, Avalanche
        supportedTokens: ['ETH', 'USDT', 'USDC', 'DAI', 'WBTC', 'BNB', 'MATIC', 'AVAX'],
        feePercentage: 0.15,
        hasLiquidityFees: false,
        hasGasFees: true,
        typicalTimeMinutes: 12,
        reliabilityScore: 92,
        features: {
          'decentralized': true,
          'hasLiquidityPools': false,
          'requiresApproval': true,
          'hasMessageBridging': true,
          'hasNativeBridging': true,
        },
      ),
    );
  }
  
  // Get provider details by ID
  BridgeProviderDetails? getProviderDetails(String id) {
    try {
      return _providers.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Get all providers supporting a chain pair
  List<BridgeProviderDetails> getProvidersForChainPair(int fromChainId, int toChainId) {
    return _providers.where((p) => 
      p.supportedChains.contains(fromChainId) && 
      p.supportedChains.contains(toChainId)
    ).toList();
  }
  
  // Get all providers supporting a token
  List<BridgeProviderDetails> getProvidersForToken(String tokenSymbol) {
    return _providers.where((p) => 
      p.supportedTokens.contains(tokenSymbol)
    ).toList();
  }
  
  // Get all providers as BridgeProvider objects
  List<BridgeProvider> getAllBridgeProviders() {
    return _providers.map((p) => p.toBridgeProvider()).toList();
  }
}
