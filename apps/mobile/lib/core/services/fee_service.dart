import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:satoshi_hub/core/models/token.dart';
import 'package:satoshi_hub/core/services/chain_service.dart';

class FeeDetails {
  final String gasFee;
  final String bridgeFee;
  final String totalFee;
  final String feeToken;

  FeeDetails({
    required this.gasFee,
    required this.bridgeFee,
    required this.totalFee,
    required this.feeToken,
  });
}

class FeeService extends ChangeNotifier {
  final Random _random = Random();
  final ChainService _chainService;
  
  // Constructor
  FeeService({ChainService? chainService}) 
      : _chainService = chainService ?? ChainService();
  
  // Gas price for each chain (in gwei)
  final Map<int, double> _gasPrice = {
    11155111: 1.2,  // Sepolia
    80001: 5.0,     // Mumbai
    421613: 0.1,    // Arbitrum Goerli
    420: 0.001,     // Optimism Goerli
    97: 3.0,        // BNB Testnet
    43113: 25.0,    // Avalanche Fuji
  };
  
  // Bridge fee percentage for each token
  final Map<String, double> _bridgeFeePercentage = {
    'native': 0.1,  // 0.1% for native tokens
    'ERC20': 0.2,   // 0.2% for ERC20 tokens
    'USDT': 0.3,    // 0.3% for USDT
    'USDC': 0.3,    // 0.3% for USDC
    'DAI': 0.25,    // 0.25% for DAI
    'WBTC': 0.15,   // 0.15% for WBTC
  };
  
  // Default gas limit for transactions
  final int _defaultGasLimit = 21000;
  final int _erc20GasLimit = 65000;
  
  // Get gas price for a chain
  double getGasPrice(int chainId) {
    // Add some random fluctuation to gas price
    final basePrice = _gasPrice[chainId] ?? 1.0;
    final fluctuation = basePrice * 0.1 * (_random.nextDouble() - 0.5); // +/- 5%
    return basePrice + fluctuation;
  }
  
  // Calculate gas fee in native token
  String calculateGasFee(int chainId, bool isErc20) {
    final gasPrice = getGasPrice(chainId);
    final gasLimit = isErc20 ? _erc20GasLimit : _defaultGasLimit;
    
    // Gas fee in gwei
    final gasFeeGwei = gasPrice * gasLimit;
    
    // Convert to ether (1 ether = 10^9 gwei)
    final gasFeeEther = gasFeeGwei / 1e9;
    
    return gasFeeEther.toStringAsFixed(6);
  }
  
  // Calculate bridge fee
  String calculateBridgeFee(String amount, String tokenSymbol, bool isErc20) {
    final amountValue = double.tryParse(amount) ?? 0.0;
    
    // Get fee percentage based on token
    double feePercentage;
    if (_bridgeFeePercentage.containsKey(tokenSymbol)) {
      feePercentage = _bridgeFeePercentage[tokenSymbol]!;
    } else {
      feePercentage = isErc20 ? _bridgeFeePercentage['ERC20']! : _bridgeFeePercentage['native']!;
    }
    
    final fee = amountValue * feePercentage;
    return fee.toStringAsFixed(6);
  }
  
  // Calculate total fee
  FeeDetails calculateTotalFee(int fromChainId, int toChainId, String amount, Token? token) {
    final isErc20 = token != null && token.address != 'native';
    
    // Gas fee (source chain)
    final gasFee = calculateGasFee(fromChainId, isErc20);
    
    // Bridge fee
    final tokenSymbol = token?.symbol ?? _chainService.getNativeTokenSymbol(fromChainId);
    final bridgeFee = calculateBridgeFee(amount, tokenSymbol, isErc20);
    
    // Total fee in token
    final totalFee = (double.parse(gasFee) + double.parse(bridgeFee)).toStringAsFixed(6);
    
    // Fee token is the source chain's native token
    final feeToken = _chainService.getNativeTokenSymbol(fromChainId);
    
    return FeeDetails(
      gasFee: gasFee,
      bridgeFee: bridgeFee,
      totalFee: totalFee,
      feeToken: feeToken,
    );
  }
  
  // Estimate time to complete based on gas price and chain
  String estimateTransactionTime(int chainId) {
    final gasPrice = getGasPrice(chainId);
    
    // Different chains have different block times
    double multiplier = 1.0;
    
    switch (chainId) {
      case 11155111: // Sepolia
        multiplier = 1.0;
        break;
      case 80001: // Mumbai
        multiplier = 0.8; // Faster than Ethereum
        break;
      case 421613: // Arbitrum Goerli
        multiplier = 0.5; // Much faster than Ethereum
        break;
      case 420: // Optimism Goerli
        multiplier = 0.6; // Faster than Ethereum
        break;
      case 97: // BNB Testnet
        multiplier = 0.3; // Very fast
        break;
      case 43113: // Avalanche Fuji
        multiplier = 0.25; // Extremely fast
        break;
    }
    
    if (gasPrice < 1.0) {
      return '${(3 * multiplier).round()}-${(5 * multiplier).round()} minutes';
    } else if (gasPrice < 3.0) {
      return '${(1 * multiplier).round()}-${(3 * multiplier).round()} minutes';
    } else if (gasPrice < 10.0) {
      return '${(30 * multiplier).round()}-${(60 * multiplier).round()} seconds';
    } else {
      return '${(10 * multiplier).round()}-${(30 * multiplier).round()} seconds';
    }
  }
}
