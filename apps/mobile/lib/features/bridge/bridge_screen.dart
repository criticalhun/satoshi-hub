import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/chain_info.dart';
import 'providers/bridge_provider.dart';
import 'widgets/chain_selection_card.dart';
import 'widgets/amount_input_card.dart';
import 'widgets/address_input_card.dart';
import 'widgets/bridge_button.dart';

class BridgeScreen extends ConsumerWidget {
  const BridgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bridgeState = ref.watch(bridgeProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Bridge'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header text
            Text(
              'Cross-chain Bridge',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Transfer tokens between testnet networks',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // From Chain Selection
            ChainSelectionCard(
              title: 'From',
              selectedChain: bridgeState.fromChain,
              onChainSelected: (chain) {
                ref.read(bridgeProvider.notifier).setFromChain(chain);
              },
            ),
            const SizedBox(height: 16),

            // Swap Button
            Center(
              child: GestureDetector(
                onTap: () {
                  ref.read(bridgeProvider.notifier).swapChains();
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.swap_vert,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // To Chain Selection
            ChainSelectionCard(
              title: 'To',
              selectedChain: bridgeState.toChain,
              onChainSelected: (chain) {
                ref.read(bridgeProvider.notifier).setToChain(chain);
              },
            ),
            const SizedBox(height: 24),

            // Amount Input
            AmountInputCard(
              amount: bridgeState.amount,
              selectedChain: bridgeState.fromChain,
              onAmountChanged: (amount) {
                ref.read(bridgeProvider.notifier).setAmount(amount);
              },
            ),
            const SizedBox(height: 16),

            // Address Input
            AddressInputCard(
              address: bridgeState.toAddress,
              onAddressChanged: (address) {
                ref.read(bridgeProvider.notifier).setToAddress(address);
              },
            ),
            const SizedBox(height: 24),

            // Error Message
            if (bridgeState.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppTheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        bridgeState.error!,
                        style: TextStyle(
                          color: AppTheme.error,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Bridge Button
            BridgeButton(
              isLoading: bridgeState.isLoading,
              onPressed: () {
                ref.read(bridgeProvider.notifier).submitBridge();
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
