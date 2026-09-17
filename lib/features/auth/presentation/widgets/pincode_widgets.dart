import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// Neon capsule slot colors matching the design:
/// Slot 0: Cyan / Electric Sky Blue
/// Slot 1: White / Crisp Slate
/// Slot 2: Hot Pink / Rose
/// Slot 3: Cyan / Electric Sky Blue
class PincodeColors {
  static Color slotColor({
    required int index,
    required bool isDark,
    required bool isError,
    required Color errorColor,
  }) {
    if (isError) return errorColor;
    if (isDark) {
      switch (index) {
        case 0:
          return const Color(0xFF00E5FF); // Neon Cyan
        case 1:
          return const Color(0xFFFFFFFF); // Crisp White
        case 2:
          return const Color(0xFFFF5286); // Neon Rose/Pink
        case 3:
          return const Color(0xFF00E5FF); // Neon Cyan
        default:
          return const Color(0xFF00E5FF);
      }
    } else {
      switch (index) {
        case 0:
          return const Color(0xFF0284C7); // Deep Sky Blue
        case 1:
          return const Color(0xFF1E293B); // Slate 800 Charcoal
        case 2:
          return const Color(0xFFE11D48); // Vibrant Rose
        case 3:
          return const Color(0xFF0284C7); // Deep Sky Blue
        default:
          return const Color(0xFF0284C7);
      }
    }
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

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
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
            capsuleWidth = math.max(48.0, (availableWidth - 32 - 3 * spacing) / 4);
          }
          final capsuleHeight = capsuleWidth * 1.72; // Stadium ratio ~1:1.72

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.length, (index) {
              final isFilled = index < widget.code.length;
              final slotColor = PincodeColors.slotColor(
                index: index,
                isDark: isDark,
                isError: widget.isError,
                errorColor: colors.error,
              );

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: capsuleWidth,
                  height: capsuleHeight,
                  decoration: BoxDecoration(
                    color: isDark
                        ? (isFilled ? slotColor.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.03))
                        : (isFilled ? slotColor.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.02)),
                    borderRadius: BorderRadius.circular(capsuleWidth / 2),
                    border: Border.all(
                      color: slotColor,
                      width: 2.5,
                    ),
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
                          color: isDark ? Colors.white : slotColor,
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.white : slotColor).withValues(alpha: 0.6),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final numberColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3'], numberColor, colors),
          const SizedBox(height: 12),
          _buildRow(['4', '5', '6'], numberColor, colors),
          const SizedBox(height: 12),
          _buildRow(['7', '8', '9'], numberColor, colors),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Bottom Left: Biometrics Key
              Expanded(
                child: showBiometrics && onBiometrics != null
                    ? _buildActionKey(
                        icon: Icons.fingerprint_rounded,
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
              Expanded(
                child: _buildDigitKey('0', numberColor, colors),
              ),
              // Bottom Right: Backspace Key
              Expanded(
                child: _buildActionKey(
                  icon: Icons.backspace_rounded,
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

  Widget _buildRow(List<String> digits, Color numberColor, AppColorsExtension colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => Expanded(child: _buildDigitKey(d, numberColor, colors))).toList(),
    );
  }

  Widget _buildDigitKey(String digit, Color numberColor, AppColorsExtension colors) {
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
                fontSize: 28,
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
            child: Icon(
              icon,
              size: iconSize,
              color: color,
            ),
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
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.16) : Colors.black.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : colors.textPrimary,
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
/// - Top bar: Security check label + Exit/Logout icon
/// - Big bold greeting: "Hi, Faruxjon!"
/// - Subtitle: "Enter your PIN"
/// - 4 Neon Stadium Capsules
/// - "Forgot PIN" Frosted Pill Button
/// - Custom In-App Numeric Keypad
class PincodeScreenLayout extends StatelessWidget {
  const PincodeScreenLayout({
    super.key,
    required this.topLabel,
    this.onExit,
    this.exitIcon = Icons.logout_rounded,
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

    final bgGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1424),
              Color(0xFF090D18),
              Color(0xFF04060B),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFF1F5F9),
              Color(0xFFE2E8F0),
            ],
          );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D18) : const Color(0xFFF8FAFC),
      body: Container(
        decoration: BoxDecoration(
          gradient: bgGradient,
        ),
        child: Stack(
          children: [
            // Ambient Radial Glow for luxury depth
            Positioned(
              top: -60,
              left: 0,
              right: 0,
              height: 380,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.2),
                      radius: 0.85,
                      colors: [
                        isDark ? const Color(0xFF1E293B).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              topLabel,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                letterSpacing: -0.2,
                              ),
                            ),
                            if (onExit != null)
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: Icon(
                                  exitIcon,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
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

                      const SizedBox(height: 12),

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
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                letterSpacing: -0.4,
                              ),
                            ),
                            if (errorMessage != null && errorMessage!.isNotEmpty) ...[
                              const SizedBox(height: 8),
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

                      const SizedBox(height: 24),

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

                      const SizedBox(height: 12),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
