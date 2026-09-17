import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'app_card.dart';

/// Dashboard/report KPI kartasi — 0 bo'lsa bosilmaydi va kulrang bo'ladi
/// (MOBILE_APP_TZ.md 7.1, E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 22).
class AppKpiCard extends StatelessWidget {
  const AppKpiCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.onTap,
    this.isZero = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;
  final bool isZero;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tint = isZero ? colors.textTertiary : (color ?? colors.primary);

    return AppCard(
      onTap: isZero ? null : onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (icon != null)
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: tint, size: 19),
                ),
              if (!isZero)
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: tint,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: tint.withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: isZero ? colors.textTertiary : colors.textPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
