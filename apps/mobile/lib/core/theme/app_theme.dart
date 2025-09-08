import 'package:flutter/material.dart';

class AppTheme {
  // Fő színek
  static const primaryColor = Color(0xFF6200EE);
  static const secondaryColor = Color(0xFF03DAC6);  // Hiányzó másodlagos szín
  static const accentColor = Color(0xFF03DAC6);
  
  // Háttér és felület színek
  static const backgroundColor = Color(0xFF121212);
  static const surfaceColor = Color(0xFF1E1E1E);
  static const cardColor = Color(0xFF242424);
  
  // Szöveg színek
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
  
  // Állapot színek
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE53935);
  static const warning = Color(0xFFFFC107);
  static const info = Color(0xFF2196F3);
  
  // Alap téma
  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceColor,
      background: backgroundColor,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
