import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

enum AppButtonVariant { primary, secondary, text, destructive }

enum AppButtonSize { small, medium, large }

/// Yagona tugma komponenti — barcha variantlar (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 44-48).
/// Loading holatida double-submit avtomatik bloklanadi.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.icon,
    this.expand = true,
  });

  const AppButton.primary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    Widget? icon,
    bool expand = true,
    AppButtonSize size = AppButtonSize.large,
  }) : this(
          key: key,
          label: label,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
          expand: expand,
          size: size,
        );

  const AppButton.secondary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool expand = true,
    AppButtonSize size = AppButtonSize.large,
  }) : this(
          key: key,
          label: label,
          onPressed: onPressed,
          variant: AppButtonVariant.secondary,
          isLoading: isLoading,
          expand: expand,
          size: size,
        );

  const AppButton.text({
    Key? key,
    required String label,
    VoidCallback? onPressed,
  }) : this(
          key: key,
          label: label,
          onPressed: onPressed,
          variant: AppButtonVariant.text,
          expand: false,
        );

  const AppButton.destructive({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool expand = true,
    AppButtonSize size = AppButtonSize.large,
  }) : this(
          key: key,
          label: label,
          onPressed: onPressed,
          variant: AppButtonVariant.destructive,
          isLoading: isLoading,
          expand: expand,
          size: size,
        );

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final Widget? icon;
  final bool expand;

  double get _height => switch (size) {
        AppButtonSize.small => 40,
        AppButtonSize.medium => 48,
        AppButtonSize.large => 52,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final disabled = onPressed == null || isLoading;

    Widget child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation(
                variant == AppButtonVariant.secondary || variant == AppButtonVariant.text
                    ? colors.primary
                    : Colors.white,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(label),
            ],
          );

    final button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: disabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: colors.disabled,
            minimumSize: Size(0, _height),
            elevation: disabled ? 0 : 2,
            shadowColor: colors.primary.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
          ),
          child: child,
        ),
      AppButtonVariant.secondary => OutlinedButton(
          onPressed: disabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: colors.surfaceSecondary.withValues(alpha: 0.6),
            foregroundColor: colors.textPrimary,
            minimumSize: Size(0, _height),
            side: BorderSide(color: colors.border.withValues(alpha: 0.8), width: 1.2),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
          ),
          child: child,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: disabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: colors.primary,
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          child: child,
        ),
      AppButtonVariant.destructive => ElevatedButton(
          onPressed: disabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: Colors.white,
            minimumSize: Size(0, _height),
            elevation: disabled ? 0 : 2,
            shadowColor: colors.error.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
          ),
          child: child,
        ),
    };

    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
