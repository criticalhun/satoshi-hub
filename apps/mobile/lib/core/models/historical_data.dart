class ProviderPerformanceRecord {
  final String providerId;
  final int fromChainId;
  final int toChainId;
  final DateTime timestamp;
  final int executionTimeSeconds;
  final double reportedFee;
  final double actualFee;
  final bool successful;
  final String? errorMessage;
  final double slippagePercent;
  final int confirmationBlocks;
  
  ProviderPerformanceRecord({
    required this.providerId,
    required this.fromChainId,
    required this.toChainId,
    required this.timestamp,
    required this.executionTimeSeconds,
    required this.reportedFee,
    required this.actualFee,
    required this.successful,
    this.errorMessage,
    required this.slippagePercent,
    required this.confirmationBlocks,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'fromChainId': fromChainId,
      'toChainId': toChainId,
      'timestamp': timestamp.toIso8601String(),
      'executionTimeSeconds': executionTimeSeconds,
      'reportedFee': reportedFee,
      'actualFee': actualFee,
      'successful': successful,
      'errorMessage': errorMessage,
      'slippagePercent': slippagePercent,
      'confirmationBlocks': confirmationBlocks,
    };
  }
  
  factory ProviderPerformanceRecord.fromJson(Map<String, dynamic> json) {
    return ProviderPerformanceRecord(
      providerId: json['providerId'],
      fromChainId: json['fromChainId'],
      toChainId: json['toChainId'],
      timestamp: DateTime.parse(json['timestamp']),
      executionTimeSeconds: json['executionTimeSeconds'],
      reportedFee: json['reportedFee'],
      actualFee: json['actualFee'],
      successful: json['successful'],
      errorMessage: json['errorMessage'],
      slippagePercent: json['slippagePercent'],
      confirmationBlocks: json['confirmationBlocks'],
    );
  }
}

class ProviderPerformanceMetrics {
  final String providerId;
  final int fromChainId;
  final int toChainId;
  final double successRate;
  final double averageExecutionTimeSeconds;
  final double averageSlippagePercent;
  final double feeAccuracy; // 1.0 means reported fee = actual fee
  final int totalTransactions;
  final int averageConfirmationBlocks;
  final DateTime lastUpdated;
  
  ProviderPerformanceMetrics({
    required this.providerId,
    required this.fromChainId,
    required this.toChainId,
    required this.successRate,
    required this.averageExecutionTimeSeconds,
    required this.averageSlippagePercent,
    required this.feeAccuracy,
    required this.totalTransactions,
    required this.averageConfirmationBlocks,
    required this.lastUpdated,
  });
  
  // Calculate a reliability score based on all metrics (0-100)
  double calculateReliabilityScore() {
    double score = 0;
    
    // Success rate contributes 40% to the score
    score += successRate * 40;
    
    // Fee accuracy contributes 20% to the score
    score += feeAccuracy * 20;
    
    // Slippage contributes 20% to the score (lower is better)
    double slippageScore = 20 * (1 - (averageSlippagePercent / 10).clamp(0, 1));
    score += slippageScore;
    
    // Execution time contributes 20% to the score
    // Normalize execution time: 0-60s is excellent, 60-300s is good, >300s is poor
    double timeScore = 20 * (1 - (averageExecutionTimeSeconds / 300).clamp(0, 1));
    score += timeScore;
    
    return score.clamp(0, 100);
  }
  
  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'fromChainId': fromChainId,
      'toChainId': toChainId,
      'successRate': successRate,
      'averageExecutionTimeSeconds': averageExecutionTimeSeconds,
      'averageSlippagePercent': averageSlippagePercent,
      'feeAccuracy': feeAccuracy,
      'totalTransactions': totalTransactions,
      'averageConfirmationBlocks': averageConfirmationBlocks,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
  
  factory ProviderPerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return ProviderPerformanceMetrics(
      providerId: json['providerId'],
      fromChainId: json['fromChainId'],
      toChainId: json['toChainId'],
      successRate: json['successRate'],
      averageExecutionTimeSeconds: json['averageExecutionTimeSeconds'],
      averageSlippagePercent: json['averageSlippagePercent'],
      feeAccuracy: json['feeAccuracy'],
      totalTransactions: json['totalTransactions'],
      averageConfirmationBlocks: json['averageConfirmationBlocks'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}
