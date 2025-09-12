import 'package:satoshi_hub/core/config/env_config.dart';

class ApiConfig {
  // API alapcíme
  static String get baseUrl => EnvConfig.apiBaseUrl;
  
  // API végpontok
  static const String auth = '/auth';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String users = '/users';
  static const String tokens = '/tokens';
  static const String transactions = '/tx';
  static const String prices = '/prices';
  static const String bridges = '/bridges';
  static const String routes = '/routes';
  static const String chains = '/chains';
  static const String swap = '/swap';
  
  // API kulcs
  static String get apiKey => EnvConfig.apiKey;
  
  // Timeout beállítások
  static const int connectTimeout = 15000; // 15 másodperc
  static const int receiveTimeout = 15000; // 15 másodperc
  
  // Retry beállítások
  static const int maxRetries = 3;
  static const int retryDelay = 1000; // 1 másodperc
}
