class TransactionJob {
  final String id;
  final int fromChainId;
  final int toChainId;
  final Map<String, dynamic> payload;
  final String status;
  final Map<String, dynamic>? result;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionJob({
    required this.id,
    required this.fromChainId,
    required this.toChainId,
    required this.payload,
    required this.status,
    this.result,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionJob.fromJson(Map<String, dynamic> json) {
    return TransactionJob(
      id: json['id'] as String,
      fromChainId: json['fromChainId'] as int,
      toChainId: json['toChainId'] as int,
      payload: json['payload'] as Map<String, dynamic>,
      status: json['status'] as String,
      result: json['result'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  String get txHash => result?['txHash'] as String? ?? '';
  String get errorMessage => result?['error'] as String? ?? '';
  
  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}
