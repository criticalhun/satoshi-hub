import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigálás az activity képernyőre a GoRouter használatával
                context.go('/activity');
              },
              child: Text(
                'See All',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTransactionItem(
          context,
          'Bridge',
          'Sepolia → Mumbai',
          '0.01 ETH',
          DateTime.now().subtract(const Duration(hours: 2)),
          true,
        ),
        _buildTransactionItem(
          context,
          'Receive',
          'From: 0x1234...5678',
          '0.05 ETH',
          DateTime.now().subtract(const Duration(days: 1)),
          true,
        ),
        _buildTransactionItem(
          context,
          'Send',
          'To: 0x8765...4321',
          '-0.02 ETH',
          DateTime.now().subtract(const Duration(days: 2)),
          false,
        ),
      ],
    );
  }

  Widget _buildTransactionItem(BuildContext context, String type, String description, String amount, DateTime time, bool isPositive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getIconColor(type).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(type),
              color: _getIconColor(type),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: isPositive ? AppTheme.success : AppTheme.error,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatTime(time),
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'Send':
        return Icons.arrow_upward;
      case 'Receive':
        return Icons.arrow_downward;
      case 'Bridge':
        return Icons.swap_horiz;
      default:
        return Icons.history;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'Send':
        return AppTheme.error;
      case 'Receive':
        return AppTheme.success;
      case 'Bridge':
        return AppTheme.primaryColor;
      default:
        return AppTheme.info;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
