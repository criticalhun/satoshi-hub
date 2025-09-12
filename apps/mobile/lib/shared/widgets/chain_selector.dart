import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:satoshi_hub/core/services/wallet_service.dart';
import 'package:satoshi_hub/core/theme/app_theme.dart';

class ChainSelector extends StatelessWidget {
  final int value;
  final String label;
  final ValueChanged<int?> onChanged;
  
  const ChainSelector({
    Key? key,
    required this.value,
    required this.label,
    required this.onChanged,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final walletService = Provider.of<WalletService>(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white24,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          DropdownButton<int>(
            value: value,
            onChanged: (newValue) {
              // Check if wallet is connected and current chain matches
              if (label == 'From' && walletService.isConnected && walletService.chainId != newValue) {
                // Ask to switch chain
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppTheme.cardBackgroundColor,
                    title: Text('Switch Network', style: TextStyle(color: Colors.white)),
                    content: Text(
                      'You need to switch to ${newValue == 11155111 ? "Sepolia" : "Mumbai"} network to proceed.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel', style: TextStyle(color: Colors.white70)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          final success = await walletService.switchChain(newValue!);
                          if (success) {
                            onChanged(newValue);
                          }
                        },
                        child: Text('Switch Network'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                onChanged(newValue);
              }
            },
            items: [
              DropdownMenuItem(
                value: 11155111,
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: Center(
                        child: Text(
                          'E',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Sepolia',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 80001,
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.purple,
                      ),
                      child: Center(
                        child: Text(
                          'M',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Mumbai',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            dropdownColor: AppTheme.backgroundColor,
            underline: const SizedBox(),
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}
