import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class EnvConfig {
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
      debugPrint('Environment loaded successfully');
    } catch (e) {
      debugPrint('Failed to load environment: $e');
      debugPrint('Using default environment values');
      // Fallback értékek használata hiba esetén - ezeket már a getter-ekben kezeljük
    }
  }
  
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';
  static String get apiKey => dotenv.env['API_KEY'] ?? 'satoshi_hub_test_api_key';
}
