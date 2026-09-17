import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// Barcha bottom sheetlarning umumiy anatomiyasi: drag handle, title, content,
/// sticky action (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 51-52). Dropdown o'rniga
/// yagona selection patterni (MOBILE_APP_TZ.md — E_HISOB_FLUTTER_UI_UX_TZ.md 2-bo'lim).
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  required Widget child,
  Widget? stickyAction,
  bool isScrollControlled = true,
  double? heightFactor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final colors = context.colors;
      final sheetBody = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: colors.border.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colors.textSecondary,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colors.surfaceSecondary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded, size: 16, color: colors.textSecondary),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Flexible(child: child),
          if (stickyAction != null)
            Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.border.withValues(alpha: 0.5))),
              ),
              child: stickyAction,
            )
          else
            SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      );

      // Material (oddiy rangli Container emas) ishlatiladi: aks holda ichidagi
      // ListTile/InkWell effektlari eng yaqin Material'ni topa olmay
      // "background color or ink splashes may be invisible" xatosini beradi.
      return Material(
        color: colors.surface,
        borderRadius: AppRadius.sheetTop,
        clipBehavior: Clip.antiAlias,
        child: heightFactor != null
            ? ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * heightFactor),
                child: sheetBody,
              )
            : sheetBody,
      );
    },
  );
}
