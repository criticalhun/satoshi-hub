import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BridgeScreen extends StatelessWidget {
  const BridgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Bridge'),
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swap_horiz,
              color: AppTheme.primaryColor,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Bridge Implementation',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
