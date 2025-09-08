import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_theme.dart';

class WalletConnectDialog extends StatelessWidget {
  final String uri;

  const WalletConnectDialog({super.key, required this.uri});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.cardColor,
      title: const Text(
        'Scan to Connect',
        style: TextStyle(color: AppTheme.textPrimary),
      ),
      content: SizedBox(
        width: 250,
        height: 250,
        child: QrImageView(
          data: uri,
          version: QrVersions.auto,
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(16.0),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Close',
            style: TextStyle(color: AppTheme.primaryColor),
          ),
        ),
      ],
    );
  }
}
