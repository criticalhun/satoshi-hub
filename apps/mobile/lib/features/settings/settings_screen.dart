import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Settings Screen - Coming Soon',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
