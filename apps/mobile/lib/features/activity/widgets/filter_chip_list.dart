import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class FilterChipList extends StatelessWidget {
  final String? statusFilter;
  final int? fromChainIdFilter;
  final int? toChainIdFilter;
  final VoidCallback onClearFilters;

  const FilterChipList({
    Key? key,
    this.statusFilter,
    this.fromChainIdFilter,
    this.toChainIdFilter,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> chips = [];

    if (statusFilter != null) {
      chips.add(
        _buildFilterChip(
          getStatusLabel(statusFilter!),
          AppTheme.primaryColor,
        ),
      );
    }

    if (fromChainIdFilter != null) {
      chips.add(
        _buildFilterChip(
          'From: ${getChainName(fromChainIdFilter!)}',
          AppTheme.primaryColor,
        ),
      );
    }

    if (toChainIdFilter != null) {
      chips.add(
        _buildFilterChip(
          'To: ${getChainName(toChainIdFilter!)}',
          AppTheme.primaryColor,
        ),
      );
    }

    // Add clear button if there are filters
    if (chips.isNotEmpty) {
      chips.add(
        TextButton(
          onPressed: onClearFilters,
          child: Text(
            'Clear All',
            style: TextStyle(
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips,
      ),
    );
  }

  Widget _buildFilterChip(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        backgroundColor: color.withOpacity(0.2),
        labelStyle: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }

  String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      default:
        return 'Status: $status';
    }
  }

  String getChainName(int chainId) {
    switch (chainId) {
      case 11155111:
        return 'Sepolia';
      case 80001:
        return 'Mumbai';
      default:
        return 'Chain $chainId';
    }
  }
}
