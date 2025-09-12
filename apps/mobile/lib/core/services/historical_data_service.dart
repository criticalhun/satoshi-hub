import 'package:flutter/foundation.dart';
import 'package:satoshi_hub/core/models/historical_data.dart';
import 'package:satoshi_hub/core/models/bridge_route.dart';
import 'package:satoshi_hub/core/services/local_storage_service.dart';
import 'dart:math';

class HistoricalDataService extends ChangeNotifier {
  final LocalStorageService _localStorage;
  final Random _random = Random();
  
  // Store performance records by provider and chain pair
  final Map<String, List<ProviderPerformanceRecord>> _performanceRecords = {};
  
  // Cache calculated metrics
  final Map<String, ProviderPerformanceMetrics> _performanceMetrics = {};
  
  // Getters
  Map<String, ProviderPerformanceMetrics> get performanceMetrics => _performanceMetrics;
  
  // Constructor
  HistoricalDataService({required LocalStorageService localStorage})
      : _localStorage = localStorage {
    _loadHistoricalData();
  }
  
  // Load historical data from storage
  Future<void> _loadHistoricalData() async {
    try {
      // In a real implementation, we would load data from storage
      // For this demo, we'll generate mock data
      _generateMockData();
      
      // Calculate metrics
      _calculateMetrics();
      
      notifyListeners();
    } catch (e) {
      print('Error loading historical data: $e');
    }
  }
  
  // Generate mock historical data for bridge providers
  void _generateMockData() {
    // Define provider IDs and chain pairs
    final providerIds = ['anyswap', 'hop', 'across', 'polygon', 'avalanche', 'arbitrum', 'optimism', 'bnb'];
    
    // Define chain pairs (fromChainId, toChainId)
    final chainPairs = [
      (11155111, 80001),   // Sepolia to Mumbai
      (11155111, 421613),  // Sepolia to Arbitrum Goerli
      (11155111, 420),     // Sepolia to Optimism Goerli
      (11155111, 97),      // Sepolia to BNB Testnet
      (11155111, 43113),   // Sepolia to Avalanche Fuji
      (80001, 11155111),   // Mumbai to Sepolia
      (421613, 11155111),  // Arbitrum Goerli to Sepolia
      (420, 11155111),     // Optimism Goerli to Sepolia
      (97, 11155111),      // BNB Testnet to Sepolia
      (43113, 11155111),   // Avalanche Fuji to Sepolia
      // Add more cross-chain pairs
      (80001, 421613),     // Mumbai to Arbitrum Goerli
      (80001, 420),        // Mumbai to Optimism Goerli
      (421613, 80001),     // Arbitrum Goerli to Mumbai
      (420, 80001),        // Optimism Goerli to Mumbai
    ];
    
    // Generate random performance records for each provider and chain pair
    for (final providerId in providerIds) {
      for (final chainPair in chainPairs) {
        // Not all providers support all chain pairs
        if (_random.nextDouble() < 0.7) { // 70% chance of supporting a chain pair
          _generateProviderRecords(
            providerId, 
            chainPair.$1,  // fromChainId
            chainPair.$2,  // toChainId
          );
        }
      }
    }
  }
  
  // Generate mock performance records for a specific provider and chain pair
  void _generateProviderRecords(String providerId, int fromChainId, int toChainId) {
    final key = '$providerId-$fromChainId-$toChainId';
    _performanceRecords[key] = [];
    
    // Define provider characteristics (some providers are faster, some are cheaper, etc.)
    double baseSuccessRate = 0.95;
    double baseExecutionTime = 120.0; // in seconds
    double baseSlippage = 0.3; // in percent
    double baseFeeAccuracy = 0.95; // 1.0 means reported fee = actual fee
    
    // Adjust based on provider
    switch (providerId) {
      case 'anyswap':
        baseSuccessRate = 0.92;
        baseExecutionTime = 150.0;
        baseSlippage = 0.5;
        baseFeeAccuracy = 0.9;
        break;
      case 'hop':
        baseSuccessRate = 0.98;
        baseExecutionTime = 90.0;
        baseSlippage = 0.2;
        baseFeeAccuracy = 0.97;
        break;
      case 'across':
        baseSuccessRate = 0.97;
        baseExecutionTime = 100.0;
        baseSlippage = 0.15;
        baseFeeAccuracy = 0.99;
        break;
      case 'polygon':
        baseSuccessRate = 0.96;
        baseExecutionTime = 180.0;
        baseSlippage = 0.3;
        baseFeeAccuracy = 0.95;
        break;
      case 'avalanche':
        baseSuccessRate = 0.94;
        baseExecutionTime = 80.0;
        baseSlippage = 0.4;
        baseFeeAccuracy = 0.92;
        break;
      case 'arbitrum':
        baseSuccessRate = 0.99;
        baseExecutionTime = 60.0;
        baseSlippage = 0.1;
        baseFeeAccuracy = 0.98;
        break;
      case 'optimism':
        baseSuccessRate = 0.97;
        baseExecutionTime = 50.0;
        baseSlippage = 0.2;
        baseFeeAccuracy = 0.97;
        break;
      case 'bnb':
        baseSuccessRate = 0.93;
        baseExecutionTime = 120.0;
        baseSlippage = 0.4;
        baseFeeAccuracy = 0.94;
        break;
    }
    
    // Adjust based on chain pair
    // Some chains have faster/slower bridges
    if (fromChainId == 11155111 && toChainId == 80001) { // Sepolia to Mumbai
      baseExecutionTime *= 1.2; // Slower
    } else if (fromChainId == 11155111 && toChainId == 421613) { // Sepolia to Arbitrum
      baseExecutionTime *= 0.8; // Faster
    } else if (fromChainId == 11155111 && toChainId == 420) { // Sepolia to Optimism
      baseExecutionTime *= 0.7; // Even faster
    }
    
    // Generate 30-100 records per provider-chain pair
    final recordCount = 30 + _random.nextInt(70);
    
    for (int i = 0; i < recordCount; i++) {
      // Generate random timestamp in the last 30 days
      final daysAgo = _random.nextInt(30);
      final hoursAgo = _random.nextInt(24);
      final timestamp = DateTime.now().subtract(Duration(days: daysAgo, hours: hoursAgo));
      
      // Randomize success based on success rate
      final successful = _random.nextDouble() < baseSuccessRate;
      
      // Randomize execution time with some variance
      final executionTimeVariance = baseExecutionTime * 0.3 * (_random.nextDouble() * 2 - 1);
      final executionTime = (baseExecutionTime + executionTimeVariance).round();
      
      // Randomize fee
      final reportedFee = 0.1 + _random.nextDouble() * 0.4; // between 0.1 and 0.5
      
      // Randomize actual fee based on fee accuracy
      final feeVariance = reportedFee * (1 - baseFeeAccuracy) * (_random.nextDouble() * 2 - 1);
      final actualFee = reportedFee + feeVariance;
      
      // Randomize slippage
      final slippageVariance = baseSlippage * 0.5 * (_random.nextDouble() * 2 - 1);
      final slippage = baseSlippage + slippageVariance;
      
      // Generate record
      final record = ProviderPerformanceRecord(
        providerId: providerId,
        fromChainId: fromChainId,
        toChainId: toChainId,
        timestamp: timestamp,
        executionTimeSeconds: executionTime,
        reportedFee: reportedFee,
        actualFee: actualFee,
        successful: successful,
        errorMessage: successful ? null : 'Transaction failed: ${_getRandomErrorMessage()}',
        slippagePercent: slippage,
        confirmationBlocks: 1 + _random.nextInt(10), // between 1 and 10 blocks
      );
      
      _performanceRecords[key]!.add(record);
    }
  }
  
  // Get a random error message for failed transactions
  String _getRandomErrorMessage() {
    final errors = [
      'Insufficient liquidity',
      'Timeout waiting for confirmation',
      'Bridge contract error',
      'RPC node connection failed',
      'Slippage too high',
      'Invalid signature',
      'Gas price too low',
      'Destination chain congestion',
    ];
    
    return errors[_random.nextInt(errors.length)];
  }
  
  // Calculate performance metrics for all providers and chain pairs
  void _calculateMetrics() {
    _performanceMetrics.clear();
    
    _performanceRecords.forEach((key, records) {
      final parts = key.split('-');
      final providerId = parts[0];
      final fromChainId = int.parse(parts[1]);
      final toChainId = int.parse(parts[2]);
      
      if (records.isNotEmpty) {
        // Calculate success rate
        final successfulRecords = records.where((r) => r.successful).toList();
        final successRate = successfulRecords.length / records.length;
        
        // Calculate average execution time
        final totalExecutionTime = successfulRecords.fold<int>(
          0, (sum, record) => sum + record.executionTimeSeconds);
        final averageExecutionTime = totalExecutionTime / successfulRecords.length;
        
        // Calculate average slippage
        final totalSlippage = successfulRecords.fold<double>(
          0, (sum, record) => sum + record.slippagePercent);
        final averageSlippage = totalSlippage / successfulRecords.length;
        
        // Calculate fee accuracy
        final totalFeeAccuracy = successfulRecords.fold<double>(
          0, (sum, record) => sum + (1 - (record.actualFee - record.reportedFee).abs() / record.reportedFee));
        final averageFeeAccuracy = totalFeeAccuracy / successfulRecords.length;
        
        // Calculate average confirmation blocks
        final totalConfirmationBlocks = successfulRecords.fold<int>(
          0, (sum, record) => sum + record.confirmationBlocks);
        final averageConfirmationBlocks = totalConfirmationBlocks / successfulRecords.length;
        
        // Create metrics
        final metrics = ProviderPerformanceMetrics(
          providerId: providerId,
          fromChainId: fromChainId,
          toChainId: toChainId,
          successRate: successRate,
          averageExecutionTimeSeconds: averageExecutionTime,
          averageSlippagePercent: averageSlippage,
          feeAccuracy: averageFeeAccuracy,
          totalTransactions: records.length,
          averageConfirmationBlocks: averageConfirmationBlocks.round(),
          lastUpdated: DateTime.now(),
        );
        
        _performanceMetrics[key] = metrics;
      }
    });
  }
  
  // Get metrics for a specific provider and chain pair
  ProviderPerformanceMetrics? getMetrics(String providerId, int fromChainId, int toChainId) {
    final key = '$providerId-$fromChainId-$toChainId';
    return _performanceMetrics[key];
  }
  
  // Get reliability score for a specific provider and chain pair
  double getReliabilityScore(String providerId, int fromChainId, int toChainId) {
    final metrics = getMetrics(providerId, fromChainId, toChainId);
    if (metrics != null) {
      return metrics.calculateReliabilityScore();
    } else {
      // Default score if no data is available
      return 70.0;
    }
  }
  
  // Record a new transaction result
  Future<void> recordTransactionResult(ProviderPerformanceRecord record) async {
    final key = '${record.providerId}-${record.fromChainId}-${record.toChainId}';
    
    if (!_performanceRecords.containsKey(key)) {
      _performanceRecords[key] = [];
    }
    
    _performanceRecords[key]!.add(record);
    
    // Recalculate metrics for this provider and chain pair
    _calculateMetricsForKey(key);
    
    // In a real implementation, we would save the updated data to storage
    
    notifyListeners();
  }
  
  // Calculate metrics for a specific provider and chain pair
  void _calculateMetricsForKey(String key) {
    final records = _performanceRecords[key];
    if (records == null || records.isEmpty) return;
    
    final parts = key.split('-');
    final providerId = parts[0];
    final fromChainId = int.parse(parts[1]);
    final toChainId = int.parse(parts[2]);
    
    // Calculate metrics as in _calculateMetrics method
    final successfulRecords = records.where((r) => r.successful).toList();
    if (successfulRecords.isEmpty) return;
    
    final successRate = successfulRecords.length / records.length;
    
    final totalExecutionTime = successfulRecords.fold<int>(
      0, (sum, record) => sum + record.executionTimeSeconds);
    final averageExecutionTime = totalExecutionTime / successfulRecords.length;
    
    final totalSlippage = successfulRecords.fold<double>(
      0, (sum, record) => sum + record.slippagePercent);
    final averageSlippage = totalSlippage / successfulRecords.length;
    
    final totalFeeAccuracy = successfulRecords.fold<double>(
      0, (sum, record) => sum + (1 - (record.actualFee - record.reportedFee).abs() / record.reportedFee));
    final averageFeeAccuracy = totalFeeAccuracy / successfulRecords.length;
    
    final totalConfirmationBlocks = successfulRecords.fold<int>(
      0, (sum, record) => sum + record.confirmationBlocks);
    final averageConfirmationBlocks = totalConfirmationBlocks / successfulRecords.length;
    
    final metrics = ProviderPerformanceMetrics(
      providerId: providerId,
      fromChainId: fromChainId,
      toChainId: toChainId,
      successRate: successRate,
      averageExecutionTimeSeconds: averageExecutionTime,
      averageSlippagePercent: averageSlippage,
      feeAccuracy: averageFeeAccuracy,
      totalTransactions: records.length,
      averageConfirmationBlocks: averageConfirmationBlocks.round(),
      lastUpdated: DateTime.now(),
    );
    
    _performanceMetrics[key] = metrics;
  }
  
  // Get performance history for a specific provider and chain pair
  List<ProviderPerformanceRecord> getPerformanceHistory(String providerId, int fromChainId, int toChainId) {
    final key = '$providerId-$fromChainId-$toChainId';
    return _performanceRecords[key] ?? [];
  }
}
