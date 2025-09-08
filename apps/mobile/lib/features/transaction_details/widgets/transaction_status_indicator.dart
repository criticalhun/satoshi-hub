import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TransactionStatusIndicator extends StatelessWidget {
  final String status;

  const TransactionStatusIndicator({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(status);
    final Color color = statusInfo.$1;
    final IconData icon = statusInfo.$2;
    final String label = statusInfo.$3;

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getStatusDescription(status),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textPrimary.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  (Color, IconData, String) _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return (
          Colors.orange,
          Icons.hourglass_empty,
          'Pending'
        );
      case 'processing':
        return (
          Colors.blue,
          Icons.sync,
          'Processing'
        );
      case 'completed':
        return (
          AppTheme.success,
          Icons.check_circle,
          'Completed'
        );
      case 'failed':
        return (
          AppTheme.error,
          Icons.error,
          'Failed'
        );
      default:
        return (
          Colors.grey,
          Icons.help,
          'Unknown'
        );
    }
  }

  String _getStatusDescription(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Your transaction is waiting to be processed';
      case 'processing':
        return 'Your transaction is being processed';
      case 'completed':
        return 'Your transaction has been successfully completed';
      case 'failed':
        return 'Your transaction has failed. Please see details below';
      default:
        return 'Transaction status is unknown';
    }
  }
}