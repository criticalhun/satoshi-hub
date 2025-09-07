import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AddressInputCard extends StatelessWidget {
  final String address;
  final Function(String) onAddressChanged;

  const AddressInputCard({
    super.key,
    required this.address,
    required this.onAddressChanged,
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
        onChanged: onAddressChanged,
        decoration: const InputDecoration(
          labelText: 'Recipient Address',
          hintText: '0x...',
          border: InputBorder.none,
        ),
      ),
    );
  }
}
