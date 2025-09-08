import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/wallet/wallet_manager.dart';
import '../../core/services/wallet/wallet_state.dart';
import 'widgets/wallet_option_card.dart';

class ConnectWalletScreen extends ConsumerStatefulWidget {
  const ConnectWalletScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConnectWalletScreen> createState() => _ConnectWalletScreenState();
}

class _ConnectWalletScreenState extends ConsumerState<ConnectWalletScreen> {
  String? _walletConnectUri;
  bool _showQrCode = false;

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletStateProvider);
    final walletManager = ref.watch(walletManagerProvider);
    
    // Ha már csatlakozva vagyunk, akkor átirányítunk a bridge képernyőre
    if (walletState.isConnected && walletState.address != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/bridge');
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Connect Wallet'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: walletState.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _showQrCode && _walletConnectUri != null
              ? _buildQrCode()
              : _buildWalletOptions(walletManager),
    );
  }

  Widget _buildQrCode() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Scan with WalletConnect',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Open your WalletConnect compatible wallet and scan this QR code',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: _walletConnectUri!,
              version: QrVersions.auto,
              size: 250,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showQrCode = false;
                _walletConnectUri = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletOptions(WalletManager walletManager) {
    final walletState = ref.watch(walletStateProvider);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connect Your Wallet',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect your wallet to start bridging assets between networks',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          
          // Hibaüzenet megjelenítése
          if (walletState.error != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.error.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppTheme.error,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      walletState.error!,
                      style: TextStyle(
                        color: AppTheme.error,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Demo Mode Option
          WalletOptionCard(
            title: 'Demo Mode',
            description: 'Connect with a demo account',
            icon: 'assets/images/metamask.svg',
            onTap: () async {
              await walletManager.connectDemo();
            },
          ),
          
          // MetaMask opció (csak web környezetben)
          if (kIsWeb)
            WalletOptionCard(
              title: 'MetaMask',
              description: 'Connect using browser extension',
              icon: 'assets/images/metamask.svg',
              onTap: () async {
                await walletManager.connectMetamask();
              },
            ),
          
          // WalletConnect opció
          WalletOptionCard(
            title: 'WalletConnect',
            description: 'Scan with your mobile wallet',
            icon: 'assets/images/walletconnect.svg',
            onTap: () async {
              try {
                final uri = await walletManager.generateWalletConnectQrCode();
                setState(() {
                  _walletConnectUri = uri;
                  _showQrCode = true;
                });
              } catch (e) {
                // Hiba kezelése a WalletManager-ben történik
              }
            },
          ),
          
          const SizedBox(height: 32),
          
          // Link a támogatott hálózatokról
          Center(
            child: TextButton(
              onPressed: () {
                // Itt megnyithatnánk egy információs képernyőt a támogatott hálózatokról
              },
              child: Text(
                'View supported networks',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
