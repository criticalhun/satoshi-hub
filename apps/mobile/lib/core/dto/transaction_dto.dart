import 'package:satoshi_hub/core/services/transaction_service.dart';

/// Adattranszfer objektum a tranzakciók API-hoz való illesztéséhez
class TransactionDTO {
  final String id;
  final String hash;
  final String type;
  final String status;
  final String fromAddress;
  final String toAddress;
  final String amount;
  final String tokenSymbol;
  final int chainId;
  final int? toChainId;
  final String? bridgeProvider;
  final String? fee;
  final String? feeToken;
  final String? error;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  TransactionDTO({
    required this.id,
    required this.hash,
    required this.type,
    required this.status,
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.tokenSymbol,
    required this.chainId,
    this.toChainId,
    this.bridgeProvider,
    this.fee,
    this.feeToken,
    this.error,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory TransactionDTO.fromJson(Map<String, dynamic> json) {
    return TransactionDTO(
      id: json['id'],
      hash: json['hash'],
      type: json['type'],
      status: json['status'],
      fromAddress: json['fromAddress'],
      toAddress: json['toAddress'],
      amount: json['amount'],
      tokenSymbol: json['tokenSymbol'],
      chainId: json['chainId'],
      toChainId: json['toChainId'],
      bridgeProvider: json['bridgeProvider'],
      fee: json['fee'],
      feeToken: json['feeToken'],
      error: json['error'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hash': hash,
      'type': type,
      'status': status,
      'fromAddress': fromAddress,
      'toAddress': toAddress,
      'amount': amount,
      'tokenSymbol': tokenSymbol,
      'chainId': chainId,
      'toChainId': toChainId,
      'bridgeProvider': bridgeProvider,
      'fee': fee,
      'feeToken': feeToken,
      'error': error,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  // Konvertálás Transaction modellé
  Transaction toTransaction() {
    TransactionType txType;
    switch (type) {
      case 'SEND':
        txType = TransactionType.send;
        break;
      case 'RECEIVE':
        txType = TransactionType.receive;
        break;
      case 'SWAP':
        txType = TransactionType.swap;
        break;
      case 'BRIDGE':
        txType = TransactionType.bridge;
        break;
      case 'STAKE':
        txType = TransactionType.stake;
        break;
      case 'UNSTAKE':
        txType = TransactionType.unstake;
        break;
      default:
        txType = TransactionType.send;
    }
    
    TransactionStatus txStatus;
    switch (status) {
      case 'PENDING':
        txStatus = TransactionStatus.pending;
        break;
      case 'CONFIRMED':
        txStatus = TransactionStatus.confirmed;
        break;
      case 'FAILED':
        txStatus = TransactionStatus.failed;
        break;
      default:
        txStatus = TransactionStatus.pending;
    }
    
    return Transaction(
      id: id,
      hash: hash,
      type: txType,
      status: txStatus,
      timestamp: createdAt,
      from: fromAddress,
      to: toAddress,
      amount: amount,
      tokenSymbol: tokenSymbol,
      chainId: chainId,
      bridgeProvider: bridgeProvider,
      toChain: toChainId?.toString(),
      fee: fee,
      feeToken: feeToken,
      error: error,
      fromChainId: chainId,
      toChainId: toChainId,
      recipient: toAddress,
      txHash: hash,
      createdAt: createdAt,
    );
  }
  
  // Létrehozás Transaction modellből
  static TransactionDTO fromTransaction(Transaction transaction) {
    String txType;
    switch (transaction.type) {
      case TransactionType.send:
        txType = 'SEND';
        break;
      case TransactionType.receive:
        txType = 'RECEIVE';
        break;
      case TransactionType.swap:
        txType = 'SWAP';
        break;
      case TransactionType.bridge:
        txType = 'BRIDGE';
        break;
      case TransactionType.stake:
        txType = 'STAKE';
        break;
      case TransactionType.unstake:
        txType = 'UNSTAKE';
        break;
    }
    
    String txStatus;
    switch (transaction.status) {
      case TransactionStatus.pending:
        txStatus = 'PENDING';
        break;
      case TransactionStatus.confirmed:
        txStatus = 'CONFIRMED';
        break;
      case TransactionStatus.failed:
        txStatus = 'FAILED';
        break;
    }
    
    return TransactionDTO(
      id: transaction.id,
      hash: transaction.hash,
      type: txType,
      status: txStatus,
      fromAddress: transaction.from,
      toAddress: transaction.to,
      amount: transaction.amount,
      tokenSymbol: transaction.tokenSymbol,
      chainId: transaction.chainId,
      toChainId: transaction.toChainId ?? (transaction.toChain != null ? int.tryParse(transaction.toChain!) : null),
      bridgeProvider: transaction.bridgeProvider,
      fee: transaction.fee,
      feeToken: transaction.feeToken,
      error: transaction.error,
      createdAt: transaction.createdAt ?? transaction.timestamp,
      updatedAt: DateTime.now(),
    );
  }
}
