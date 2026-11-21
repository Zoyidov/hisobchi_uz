import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// PIN slotlari ranglari — Hisup brend palitrasidan (logotipdagi och va
/// to'q ko'k) navbatma-navbat olinadi; xato holatida hammasi `error`.
class PincodeColors {
  static Color slotColor({
    required int index,
    required AppColorsExtension colors,
    required bool isError,
  }) {
    if (isError) return colors.error;
    return index.isEven ? colors.brandAccent : colors.primary;
  }
}

/// 4 Stadium / Capsule PIN slots with neon borders and centered luminous dots
class PincodeCapsulesView extends StatefulWidget {
  const PincodeCapsulesView({
    super.key,
    required this.code,
    this.length = 4,
    this.isError = false,
  });

  final String code;
  final int length;
  final bool isError;

  @override
  State<PincodeCapsulesView> createState() => PincodeCapsulesViewState();
}

class PincodeCapsulesViewState extends State<PincodeCapsulesView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 12.0, end: -8.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 8.0, end: -4.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -4.0, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );
  }

  @override
  void didUpdateWidget(covariant PincodeCapsulesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isError && !oldWidget.isError) {
      triggerShake();
    }
  }

  void triggerShake() {
    HapticFeedback.heavyImpact();
    _shakeController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          // Calculate responsive capsule dimensions
          // Standard width ~66px, height ~114px, spacing ~12px
          double spacing = 12.0;
          double capsuleWidth = 66.0;
          if (availableWidth < (4 * capsuleWidth + 3 * spacing + 32)) {
            spacing = 8.0;
            capsuleWidth = math.max(
              48.0,
              (availableWidth - 32 - 3 * spacing) / 4,
            );
          }
          final capsuleHeight = capsuleWidth * 1.72; // Stadium ratio ~1:1.72

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.length, (index) {
              final isFilled = index < widget.code.length;
              final slotColor = PincodeColors.slotColor(
                index: index,
                colors: colors,
                isError: widget.isError,
              );

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: capsuleWidth,
                  height: capsuleHeight,
                  decoration: BoxDecoration(
                    color: isDark
                        ? (isFilled
                              ? slotColor.withValues(alpha: 0.08)
                              : context.colors.onPrimary.withValues(
                                  alpha: 0.03,
                                ))
                        : (isFilled
                              ? slotColor.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.02)),
                    borderRadius: BorderRadius.circular(capsuleWidth / 2),
                    border: Border.all(color: slotColor, width: 2.5),
                    boxShadow: isFilled && isDark
                        ? [
                            BoxShadow(
                              color: slotColor.withValues(alpha: 0.25),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: AnimatedScale(
                      scale: isFilled ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutBack,
                      child: Container(
                        width: math.min(18.0, capsuleWidth * 0.3),
                        height: math.min(18.0, capsuleWidth * 0.3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? context.colors.onPrimary : slotColor,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (isDark
                                          ? context.colors.onPrimary
                                          : slotColor)
                                      .withValues(alpha: 0.6),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// Custom In-App Clean Numeric Keypad matching the screenshot:
/// 1 2 3
/// 4 5 6
/// 7 8 9
/// [Biometrics] 0 [Backspace]
class PincodeNumericKeypad extends StatelessWidget {
  const PincodeNumericKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.onLongPressBackspace,
    this.onBiometrics,
    this.showBiometrics = false,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onLongPressBackspace;
  final VoidCallback? onBiometrics;
  final bool showBiometrics;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final numberColor = context.colors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3'], numberColor, colors),
          const SizedBox(height: AppSpacing.sm),
          _buildRow(['4', '5', '6'], numberColor, colors),
          const SizedBox(height: AppSpacing.sm),
          _buildRow(['7', '8', '9'], numberColor, colors),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Bottom Left: Biometrics Key
              Expanded(
                child: showBiometrics && onBiometrics != null
                    ? _buildActionKey(
                        icon: AppIcons.fingerprint,
                        iconSize: 32,
                        color: numberColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onBiometrics?.call();
                        },
                      )
                    : const SizedBox(height: 60),
              ),
              // Bottom Center: Digit 0
              Expanded(child: _buildDigitKey('0', numberColor, colors)),
              // Bottom Right: Backspace Key
              Expanded(
                child: _buildActionKey(
                  icon: AppIcons.backspace,
                  iconSize: 26,
                  color: numberColor,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onBackspace();
                  },
                  onLongPress: onLongPressBackspace != null
                      ? () {
                          HapticFeedback.mediumImpact();
                          onLongPressBackspace!();
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    List<String> digits,
    Color numberColor,
    AppColorsExtension colors,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits
          .map((d) => Expanded(child: _buildDigitKey(d, numberColor, colors)))
          .toList(),
    );
  }

  Widget _buildDigitKey(
    String digit,
    Color numberColor,
    AppColorsExtension colors,
  ) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkResponse(
          onTap: () {
            HapticFeedback.lightImpact();
            onDigit(digit);
          },
          containedInkWell: true,
          highlightShape: BoxShape.circle,
          radius: 36,
          splashColor: numberColor.withValues(alpha: 0.12),
          highlightColor: numberColor.withValues(alpha: 0.06),
          child: Container(
            width: 68,
            height: 60,
            alignment: Alignment.center,
            child: Text(
              digit,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: numberColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey({
    required IconData icon,
    required double iconSize,
    required Color color,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkResponse(
          onTap: onTap,
          onLongPress: onLongPress,
          containedInkWell: true,
          highlightShape: BoxShape.circle,
          radius: 34,
          splashColor: color.withValues(alpha: 0.12),
          highlightColor: color.withValues(alpha: 0.06),
          child: Container(
            width: 68,
            height: 60,
            alignment: Alignment.center,
            child: Icon(icon, size: iconSize, color: color),
          ),
        ),
      ),
    );
  }
}

/// Frosted Glass Capsule Pill Button ("Forgot PIN" / "Skip")
class PincodePillButton extends StatelessWidget {
  const PincodePillButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.colors;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(AppRadius.large),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? context.colors.onPrimary.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(
                color: isDark
                    ? context.colors.onPrimary.withValues(alpha: 0.16)
                    : Colors.black.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full Senior-Level PIN Screen Scaffold matching the uploaded screenshot:
/// - Atmospheric luxury gradient background
/// - Security label and exit action.
/// - Greeting uses the signed-in user name when available.
/// - PIN entry instructions.
/// - 4 Neon Stadium Capsules
/// - PIN recovery action.
/// - Custom In-App Numeric Keypad
class PincodeScreenLayout extends StatelessWidget {
  const PincodeScreenLayout({
    super.key,
    required this.topLabel,
    this.onExit,
    this.exitIcon = AppIcons.logout,
    required this.title,
    required this.subtitle,
    this.errorMessage,
    required this.code,
    required this.onDigit,
    required this.onBackspace,
    this.onLongPressBackspace,
    this.onBiometrics,
    this.showBiometrics = false,
    this.pillButtonLabel,
    this.onPillButtonTap,
    this.capsulesKey,
    this.isError = false,
  });

  final String topLabel;
  final VoidCallback? onExit;
  final IconData exitIcon;
  final String title;
  final String subtitle;
  final String? errorMessage;
  final String code;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onLongPressBackspace;
  final VoidCallback? onBiometrics;
  final bool showBiometrics;
  final String? pillButtonLabel;
  final VoidCallback? onPillButtonTap;
  final Key? capsulesKey;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-.9, -1),
                    radius: 1.25,
                    colors: [
                      Color.alphaBlend(
                        colors.primary.withValues(alpha: isDark ? .13 : .07),
                        colors.surface,
                      ),
                      colors.surface,
                    ],
                    stops: const [0, .85],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            topLabel,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.colors.textSecondary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (onExit != null)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                exitIcon,
                                color: context.colors.textPrimary,
                                size: 22,
                              ),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                onExit?.call();
                              },
                            )
                          else
                            const SizedBox(width: 48, height: 48),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Greetings & Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: context.colors.textPrimary,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: context.colors.textSecondary,
                              letterSpacing: -0.4,
                            ),
                          ),
                          if (errorMessage != null &&
                              errorMessage!.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xs),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 250),
                              opacity: 1.0,
                              child: Text(
                                errorMessage!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colors.error,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const Spacer(flex: 1),

                    // 4 Stadium Capsules
                    PincodeCapsulesView(
                      key: capsulesKey,
                      code: code,
                      length: 4,
                      isError: isError,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Middle Pill Button (e.g. "Forgot PIN" or "Skip")
                    if (pillButtonLabel != null && onPillButtonTap != null)
                      PincodePillButton(
                        label: pillButtonLabel!,
                        onTap: onPillButtonTap!,
                      )
                    else
                      const SizedBox(height: 44),

                    const Spacer(flex: 2),

                    // Custom Numeric Keypad
                    PincodeNumericKeypad(
                      onDigit: onDigit,
                      onBackspace: onBackspace,
                      onLongPressBackspace: onLongPressBackspace,
                      onBiometrics: onBiometrics,
                      showBiometrics: showBiometrics,
                    ),

                    const SizedBox(height: AppSpacing.sm),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
