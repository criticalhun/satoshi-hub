import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/chain_info.dart';

class AmountInputCard extends StatelessWidget {
  final String amount;
  final ChainInfo? selectedChain;
  final Function(String) onAmountChanged;

  const AmountInputCard({
    super.key,
    required this.amount,
    required this.selectedChain,
    required this.onAmountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        onChanged: onAmountChanged,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'Amount',
          hintText: '0.0',
          suffixText: selectedChain?.symbol ?? '',
          border: InputBorder.none,
        ),
      ),
    );
  }
}
