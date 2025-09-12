import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:satoshi_hub/core/services/wallet_service.dart';
import 'package:satoshi_hub/core/services/api_service.dart';
import 'package:satoshi_hub/core/services/transaction_service.dart';
import 'package:satoshi_hub/core/services/token_service.dart';
import 'package:satoshi_hub/core/services/fee_service.dart';
import 'package:satoshi_hub/core/services/chain_service.dart';
import 'package:satoshi_hub/core/services/routing_service.dart';
import 'package:satoshi_hub/core/services/historical_data_service.dart';
import 'package:satoshi_hub/core/services/swap_service.dart';
import 'package:satoshi_hub/core/services/local_storage_service.dart';
import 'package:satoshi_hub/core/services/price_service.dart';
import 'package:satoshi_hub/core/services/web3_service.dart';
import 'package:satoshi_hub/core/services/bridge_provider_service.dart';
import 'package:satoshi_hub/core/services/auth_service.dart';
import 'package:satoshi_hub/core/config/env_config.dart';
import 'package:satoshi_hub/screens/home_screen.dart';
import 'package:satoshi_hub/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart';

void main() async {
  // Biztosítsuk, hogy a Flutter inicializálva legyen
  WidgetsFlutterBinding.ensureInitialized();
  
  // Környezeti változók betöltése
  try {
    await EnvConfig.load();
    debugPrint('Environment configured successfully');
  } catch (e) {
    debugPrint('Failed to load environment configuration: $e');
    debugPrint('Continuing with default configuration');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Register LocalStorageService first
        Provider(create: (_) => LocalStorageService()),
        
        // Register ChainService as it's a dependency for many services
        ChangeNotifierProvider(create: (_) => ChainService()),
        
        // Register AuthService before services that depend on authentication
        ChangeNotifierProvider(create: (_) => AuthService()),
        
        // Register services with dependencies
        ChangeNotifierProvider(
          create: (context) => HistoricalDataService(
            localStorage: Provider.of<LocalStorageService>(context, listen: false),
          ),
        ),
        
        ChangeNotifierProvider(
          create: (context) => WalletService(
            chainService: Provider.of<ChainService>(context, listen: false),
          ),
        ),
        
        ChangeNotifierProvider(create: (_) => ApiService()),
        
        ChangeNotifierProvider(
          create: (context) => TransactionService(
            localStorage: Provider.of<LocalStorageService>(context, listen: false),
            authService: Provider.of<AuthService>(context, listen: false),
          ),
        ),
        
        ChangeNotifierProvider(
          create: (context) => TokenService(
            chainService: Provider.of<ChainService>(context, listen: false),
            localStorage: Provider.of<LocalStorageService>(context, listen: false),
            authService: Provider.of<AuthService>(context, listen: false),
          ),
        ),
        
        ChangeNotifierProvider(
          create: (context) => FeeService(
            chainService: Provider.of<ChainService>(context, listen: false),
          ),
        ),
        
        ChangeNotifierProvider(
          create: (context) => RoutingService(
            chainService: Provider.of<ChainService>(context, listen: false),
            historicalDataService: Provider.of<HistoricalDataService>(context, listen: false),
          ),
        ),
        
        ChangeNotifierProvider(
          create: (context) => SwapService(
            tokenService: Provider.of<TokenService>(context, listen: false),
          ),
        ),
        
        ChangeNotifierProvider(create: (_) => PriceService()),
        
        ChangeNotifierProvider(
          create: (context) => Web3Service(
            chainService: Provider.of<ChainService>(context, listen: false),
          ),
        ),
        
        ChangeNotifierProvider(
          create: (context) => BridgeProviderService(
            chainService: Provider.of<ChainService>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Satoshi Hub',
        theme: ThemeData(
          scaffoldBackgroundColor: AppTheme.backgroundColor,
          appBarTheme: AppBarTheme(
            backgroundColor: AppTheme.backgroundColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          colorScheme: ColorScheme.dark(
            primary: AppTheme.primaryColor,
            secondary: AppTheme.accentColor,
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white70),
          ),
        ),
        home: const HomeScreen(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
        ],
      ),
    );
  }
}
