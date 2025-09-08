import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/bridge/bridge_screen.dart';
import 'features/activity/activity_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/transaction_details/simple_transaction_details_screen.dart';
import 'features/connect_wallet/connect_wallet_screen.dart';

class SatoshiHubApp extends StatelessWidget {
  const SatoshiHubApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Satoshi Hub',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/bridge',
      builder: (context, state) => const BridgeScreen(),
    ),
    GoRoute(
      path: '/activity',
      builder: (context, state) => const ActivityScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/transaction/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return SimpleTransactionDetailsScreen(transactionId: id);
      },
    ),
    GoRoute(
      path: '/connect-wallet',
      builder: (context, state) => const ConnectWalletScreen(),
    ),
  ],
);
