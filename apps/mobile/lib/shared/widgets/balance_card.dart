import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// Ezt a widgetet már nem használjuk, de megtartjuk a kompatibilitás miatt
class BalanceCard extends StatelessWidget {
  const BalanceCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Üres konténer, helyette a WalletStatusCard-ot használjuk
    return const SizedBox();
  }
}
