import 'package:flutter/material.dart';

import '../../errors/failure.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../buttons/app_button.dart';

/// Icon + message + Retry — 5xx/timeout/no-internet uchun umumiy holat
/// (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 70, 108, 135, 156).
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    this.failure,
    this.title,
    this.description,
    required this.onRetry,
  });

  final Failure? failure;
  final String? title;
  final String? description;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isNetwork = failure is NetworkFailure;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colors.error.withValues(alpha: 0.18), width: 1.5),
              ),
              child: Icon(
                isNetwork ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                size: 36,
                color: colors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title ?? (isNetwork ? 'Internet aloqasi yo\'q' : 'Ma\'lumotni yuklab bo\'lmadi'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              description ?? failure?.message ?? 'Internetni tekshiring yoki qayta urinib ko\'ring.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton.secondary(
              label: 'Qayta urinish',
              onPressed: onRetry,
              expand: false,
              size: AppButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }
}
