import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// Yagona card konteyneri (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 20-21).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.selected = false,
    this.color,
    this.gradient,
    this.hasShadow = true,
    this.borderRadius,
    this.border,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final bool selected;
  final Color? color;
  final Gradient? gradient;
  final bool hasShadow;
  final BorderRadius? borderRadius;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = borderRadius ?? AppRadius.cardRadius;

    final effectiveBorder = border ??
        Border.all(
          color: selected ? colors.primary : colors.border.withValues(alpha: 0.8),
          width: selected ? 1.5 : 1,
        );

    final decoration = BoxDecoration(
      color: gradient != null ? null : (color ?? colors.surface),
      gradient: gradient,
      borderRadius: radius,
      border: effectiveBorder,
      boxShadow: hasShadow ? colors.cardShadow : null,
    );

    final isInteractive = onTap != null || onLongPress != null;

    if (!isInteractive) {
      return Container(
        padding: padding,
        decoration: decoration,
        child: child,
      );
    }

    return Container(
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: radius,
          splashColor: colors.primary.withValues(alpha: 0.08),
          highlightColor: colors.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
