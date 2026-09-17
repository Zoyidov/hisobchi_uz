import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/app_button.dart';

/// Majburiy yangilash — chiqib bo'lmaydi (MOBILE_APP_TZ.md 5.2, 18-bo'lim).
class ForceUpdatePage extends StatelessWidget {
  const ForceUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.system_update_alt_rounded, size: 64, color: colors.primary),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Ilovani davom ettirish uchun yangilash talab qilinadi',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton.primary(
                  label: 'Yangilash',
                  onPressed: () => launchUrl(
                    Uri.parse('https://play.google.com/store/apps/details?id=com.example.hisobchi_uz'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
