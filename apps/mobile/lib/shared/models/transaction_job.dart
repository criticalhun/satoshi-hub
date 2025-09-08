import 'dart:convert';

class TransactionJob {
  final String id;
  final int fromChainId;
  final int toChainId;
  final String status;
  final dynamic payload;
  final String? result;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionJob({
    required this.id,
    required this.fromChainId,
    required this.toChainId,
    required this.status,
    required this.payload,
    this.result,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionJob.fromJson(Map<String, dynamic> json) {
    dynamic processedPayload;
    if (json['payload'] is String) {
      try {
        processedPayload = jsonDecode(json['payload'] as String);
      } catch (e) {
        processedPayload = json['payload'];
      }
    } else {
      processedPayload = json['payload'];
    }

    return TransactionJob(
      id: json['id'] as String,
      fromChainId: json['fromChainId'] as int,
      toChainId: json['toChainId'] as int,
      status: json['status'] as String,
      payload: processedPayload,
      result: json['result'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromChainId': fromChainId,
      'toChainId': toChainId,
      'status': status,
      'payload': payload is String ? payload : jsonEncode(payload),
      'result': result,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isFailed => status.toLowerCase() == 'failed';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isProcessing => status.toLowerCase() == 'processing';

  String? get txHash {
    if (result == null) return null;
    
    try {
      final resultMap = jsonDecode(result!) as Map<String, dynamic>;
      return resultMap['txHash'] as String?;
    } catch (e) {
      return null;
    }
  }

  String? get errorMessage {
    if (result == null) return null;
    
    try {
      final resultMap = jsonDecode(result!) as Map<String, dynamic>;
      return resultMap['message'] as String?;
    } catch (e) {
      return null;
    }
  }
}
