import 'package:flutter/material.dart';

import '../states/app_empty_state.dart';
import '../../icons/app_icons.dart';

/// Keyingi bosqichda to'liq amalga oshiriladigan bo'limlar uchun vaqtinchalik
/// ekran — navigatsiya to'liq ishlaydi, faqat ekran mazmuni keyinroq to'ldiriladi.
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const AppEmptyState(
        icon: AppIcons.hourglass,
        title: 'Tez orada',
        description: 'Bu bo\'lim ustida hozir ishlanmoqda.',
      ),
    );
  }
}
