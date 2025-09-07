import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/chain_info.dart';
import '../providers/bridge_provider.dart';

class ChainSelectionCard extends ConsumerWidget {
  final String title;
  final ChainInfo? selectedChain;
  final Function(ChainInfo) onChainSelected;

  const ChainSelectionCard({
    super.key,
    required this.title,
    required this.selectedChain,
    required this.onChainSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableChains = ref.watch(availableChainsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButton<ChainInfo>(
            value: selectedChain,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            hint: const Text(
              'Select Chain',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            onChanged: (ChainInfo? newValue) {
              if (newValue != null) {
                onChainSelected(newValue);
              }
            },
            items: availableChains.map<DropdownMenuItem<ChainInfo>>((ChainInfo chain) {
              return DropdownMenuItem<ChainInfo>(
                value: chain,
                child: Text(chain.name),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
