import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService extends ChangeNotifier {
  final String _baseUrl = 'http://localhost:3000/api';
  
  ApiService();
  
  // Get supported chains
  Future<List<Map<String, dynamic>>> getSupportedChains() async {
    try {
      // Mock data for demo
      return [
        {
          'id': 11155111,
          'name': 'Sepolia',
          'nativeToken': 'ETH',
          'rpcUrl': 'https://rpc.sepolia.org',
          'explorerUrl': 'https://sepolia.etherscan.io',
        },
        {
          'id': 80001,
          'name': 'Mumbai',
          'nativeToken': 'MATIC',
          'rpcUrl': 'https://rpc-mumbai.maticvigil.com',
          'explorerUrl': 'https://mumbai.polygonscan.com',
        },
      ];
    } catch (e) {
      print('Error getting supported chains: $e');
      return [];
    }
  }
  
  // Get transaction fees
  Future<Map<String, dynamic>> getTransactionFees(int fromChainId, int toChainId) async {
    try {
      // Mock data for demo
      return {
        'gasFee': '0.0001',
        'bridgeFee': '0.0002',
        'totalFee': '0.0003',
      };
    } catch (e) {
      print('Error getting transaction fees: $e');
      return {
        'gasFee': '0.0001',
        'bridgeFee': '0.0002',
        'totalFee': '0.0003',
      };
    }
  }
}
