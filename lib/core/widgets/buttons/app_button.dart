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

    final content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: isLoading
          ? SizedBox(
              key: const ValueKey('loading'),
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
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Text(label),
              ],
            ),
    );

    final button = switch (variant) {
      AppButtonVariant.primary => Container(
          decoration: disabled
              ? null
              : BoxDecoration(
                  borderRadius: AppRadius.mediumRadius,
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
          child: ElevatedButton(
            onPressed: disabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: colors.disabled,
              minimumSize: Size(0, _height),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
              textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
            ),
            child: content,
          ),
        ),
      AppButtonVariant.secondary => OutlinedButton(
          onPressed: disabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: colors.surfaceSecondary.withValues(alpha: 0.6),
            foregroundColor: colors.textPrimary,
            minimumSize: Size(0, _height),
            side: BorderSide(color: colors.border.withValues(alpha: 0.9), width: 1.2),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
          ),
          child: content,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: disabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: colors.primary,
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          child: content,
        ),
      AppButtonVariant.destructive => Container(
          decoration: disabled
              ? null
              : BoxDecoration(
                  borderRadius: AppRadius.mediumRadius,
                  boxShadow: [
                    BoxShadow(
                      color: colors.error.withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
          child: ElevatedButton(
            onPressed: disabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: Colors.white,
              disabledBackgroundColor: colors.disabled,
              minimumSize: Size(0, _height),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
              textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
            ),
            child: content,
          ),
        ),
    };

    final wrappedButton = AppButtonPressable(
      enabled: !disabled,
      child: button,
    );

    if (!expand) return wrappedButton;
    return SizedBox(width: double.infinity, child: wrappedButton);
  }
}

/// Tactile press scale micro-interaction wrapper
class AppButtonPressable extends StatefulWidget {
  const AppButtonPressable({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  State<AppButtonPressable> createState() => _AppButtonPressableState();
}

class _AppButtonPressableState extends State<AppButtonPressable> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        if (widget.enabled) _controller.forward();
      },
      onPointerUp: (_) {
        if (widget.enabled) _controller.reverse();
      },
      onPointerCancel: (_) {
        if (widget.enabled) _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
