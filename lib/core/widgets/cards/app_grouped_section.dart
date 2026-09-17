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
                  indent: 64,
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
      splashColor: effectiveIconColor.withValues(alpha: 0.08),
      highlightColor: effectiveIconColor.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 19, color: effectiveIconColor),
            ),
            const SizedBox(width: AppSpacing.md),
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
                      fontWeight: FontWeight.w500,
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
