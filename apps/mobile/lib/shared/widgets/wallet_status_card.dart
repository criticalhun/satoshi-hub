import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/wallet_service.dart';
import '../../core/theme/app_theme.dart';

class WalletStatusCard extends StatelessWidget {
  const WalletStatusCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final walletService = Provider.of<WalletService>(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Wallet Status',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildStatusIndicator(walletService.isConnected),
            ],
          ),
          const SizedBox(height: 16),
          if (!walletService.isConnected)
            _buildConnectButton(context, walletService)
          else
            _buildWalletInfo(context, walletService),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(bool isConnected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isConnected ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isConnected ? 'Connected' : 'Disconnected',
            style: TextStyle(
              color: isConnected ? Colors.green : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectButton(BuildContext context, WalletService walletService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connect your wallet to use the bridge',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await walletService.connectWallet();
                },
                child: const Text('Connect Wallet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWalletInfo(BuildContext context, WalletService walletService) {
    final address = walletService.address ?? '';
    final formattedAddress = address.length > 10
        ? '${address.substring(0, 6)}...${address.substring(address.length - 4)}'
        : address;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          'Address',
          formattedAddress,
          Icon(
            Icons.copy,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          onTap: () {
            // Copy address to clipboard
          },
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          'Network',
          walletService.getChainName(),
          null,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          'Balance',
          '${walletService.formatBalance()} ${walletService.getChainName() == 'Sepolia' ? 'ETH' : 'MATIC'}',
          Icon(
            Icons.refresh,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          onTap: () async {
            // Refresh balance
          },
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () async {
            await walletService.disconnectWallet();
          },
          child: const Text('Disconnect Wallet'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.withOpacity(0.2),
            foregroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, Widget? suffix, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (suffix != null) suffix,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
