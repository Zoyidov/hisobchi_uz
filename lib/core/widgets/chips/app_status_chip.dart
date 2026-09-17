import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

enum AppStatusChipTone { success, error, warning, info, neutral }

/// Status har doim icon + label + color kombinatsiyasida (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 8, 18).
class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    super.key,
    required this.label,
    required this.tone,
    this.icon,
  });

  final String label;
  final AppStatusChipTone tone;
  final IconData? icon;

  Color _color(AppColorsExtension colors) => switch (tone) {
        AppStatusChipTone.success => colors.success,
        AppStatusChipTone.error => colors.error,
        AppStatusChipTone.warning => colors.warning,
        AppStatusChipTone.info => colors.info,
        AppStatusChipTone.neutral => colors.textTertiary,
      };

  IconData _defaultIcon() => switch (tone) {
        AppStatusChipTone.success => Icons.check_circle,
        AppStatusChipTone.error => Icons.error,
        AppStatusChipTone.warning => Icons.warning_amber_rounded,
        AppStatusChipTone.info => Icons.info,
        AppStatusChipTone.neutral => Icons.remove_circle_outline,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color(context.colors);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.pillRadius,
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? _defaultIcon(), size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
          ),
        ],
      ),
    );
  }
}
