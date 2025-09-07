import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletService {
  Web3App? _web3App;
  SessionData? session;

  Future<void> init() async {
    _web3App = await Web3App.createInstance(
      projectId: 'YOUR_WALLETCONNECT_PROJECT_ID', // TODO: Cseréld ki a saját Project ID-dre!
      metadata: const PairingMetadata(
        name: 'Satoshi Hub',
        description: 'Cross-chain Testnet Hub',
        url: 'https://walletconnect.com',
        icons: ['https://walletconnect.com/walletconnect-logo.png'],
      ),
    );
  }

  Future<void> connect(Function(String) onDisplayUri) async {
    if (_web3App == null) await init();

    ConnectResponse? response = await _web3App?.connect(
      requiredNamespaces: {
        'eip155': const RequiredNamespace(
          chains: ['eip155:11155111'], // Sepolia Testnet
          methods: ['eth_sendTransaction', 'personal_sign'],
          events: ['chainChanged', 'accountsChanged'],
        ),
      },
    );

    onDisplayUri(response?.uri.toString() ?? '');

    session = await response?.session.future;
  }
}

final walletServiceProvider = Provider((ref) => WalletService());

final sessionProvider = StateProvider<SessionData?>((ref) => null);
