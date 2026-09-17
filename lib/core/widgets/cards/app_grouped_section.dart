import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// Bir-biriga bog'liq qatorlarni (Profil/Sozlamalar menyusi kabi) yagona
/// yumaloq burchakli guruhga jamlaydi — bo'sh, tekis `ListView` o'rniga
/// (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 20-21, 31, 197-bo'lim: "SettingsSection").
///
/// `Material` ishlatiladi (oddiy rangli `Container` emas), aks holda ichidagi
/// `AppGroupedTile`larning bosilish effekti ko'rinmay qoladi.
class AppGroupedSection extends StatelessWidget {
  const AppGroupedSection({super.key, required this.children, this.margin});

  final List<Widget> children;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: colors.border.withValues(alpha: 0.8)),
        boxShadow: colors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colors.divider.withValues(alpha: 0.8),
                  indent: 58,
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Guruh ichidagi bitta qator — icon + label + qiymat/chevron
/// (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 32: "AppListTile").
class AppGroupedTile extends StatelessWidget {
  const AppGroupedTile({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
    this.destructive = false,
    this.showChevron = true,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final bool destructive;
  final bool showChevron;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveIconColor = iconColor ?? (destructive ? colors.error : colors.primary);
    final fg = destructive ? colors.error : colors.textPrimary;

    return InkWell(
      onTap: onTap,
      splashColor: colors.primary.withValues(alpha: 0.06),
      highlightColor: colors.primary.withValues(alpha: 0.03),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 18, color: effectiveIconColor),
            ),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (value != null) ...[
              Text(
                value!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
              ),
              const SizedBox(width: 4),
            ],
            if (showChevron && onTap != null)
              Icon(Icons.chevron_right_rounded, size: 20, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }
}
