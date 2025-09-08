import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/transaction_job.dart';

class TransactionDetailsCard extends StatelessWidget {
  final TransactionJob transaction;

  const TransactionDetailsCard({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final payload = transaction.payload;
    final type = payload['type'] as String? ?? 'Unknown';
    final to = payload['to'] as String? ?? 'Unknown';
    final amount = payload['amount'] as String? ?? '0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Transaction Type', type),
          const Divider(color: Colors.white24),
          _buildInfoRow('From Chain ID', transaction.fromChainId.toString()),
          const SizedBox(height: 8),
          _buildInfoRow('To Chain ID', transaction.toChainId.toString()),
          const Divider(color: Colors.white24),
          _buildInfoRow('Recipient Address', to),
          const SizedBox(height: 8),
          _buildInfoRow('Amount', amount),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}