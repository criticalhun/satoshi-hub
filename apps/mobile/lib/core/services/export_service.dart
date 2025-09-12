import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:satoshi_hub/core/services/transaction_service.dart';
import 'package:intl/intl.dart';

class ExportService {
  final TransactionService _transactionService;

  ExportService({required TransactionService transactionService})
      : _transactionService = transactionService;

  // Export all transactions to CSV
  Future<String> exportTransactionsToCSV() async {
    final transactions = await _transactionService.getTransactions();
    
    if (transactions.isEmpty) {
      return 'No transactions to export';
    }
    
    // Create CSV header
    final csv = StringBuffer();
    csv.writeln('Id,Type,Status,Date,From,To,Amount,Token,Chain,Fee,Hash');
    
    // Add transactions
    for (final transaction in transactions) {
      final date = DateFormat('yyyy-MM-dd HH:mm').format(transaction.timestamp);
      
      csv.writeln(
        '${transaction.id},'
        '${transaction.type.toString().split('.').last},'
        '${transaction.status.toString().split('.').last},'
        '$date,'
        '${transaction.from},'
        '${transaction.to},'
        '${transaction.amount},'
        '${transaction.tokenSymbol ?? ''},'
        '${transaction.chainId},'
        '${transaction.fee ?? ''},'
        '${transaction.hash}'
      );
    }
    
    // Copy to clipboard
    await Clipboard.setData(ClipboardData(text: csv.toString()));
    
    return 'Transactions exported to clipboard';
  }
  
  // Export all transactions to JSON
  Future<String> exportTransactionsToJSON() async {
    final transactions = await _transactionService.getTransactions();
    
    if (transactions.isEmpty) {
      return 'No transactions to export';
    }
    
    final jsonList = transactions.map((tx) => tx.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    
    // Copy to clipboard
    await Clipboard.setData(ClipboardData(text: jsonString));
    
    return 'Transactions exported to clipboard';
  }
  
  // Export a single transaction to JSON
  Future<String> exportTransactionToJSON(String transactionId) async {
    final transaction = await _transactionService.getTransaction(transactionId);
    
    if (transaction == null) {
      return 'Transaction not found';
    }
    
    final jsonString = jsonEncode(transaction.toJson());
    
    // Copy to clipboard
    await Clipboard.setData(ClipboardData(text: jsonString));
    
    return 'Transaction exported to clipboard';
  }
}
