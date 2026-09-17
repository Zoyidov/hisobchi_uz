import 'package:flutter/material.dart';

/// Semantik ranglar — feature kod ichida hech qachon `Colors.green` kabi
/// hardcode qilinmaydi, faqat `context.colors.success` orqali olinadi
/// (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md bo'lim 7–8, 130).
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.background,
    required this.surface,
    required this.surfaceSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.divider,
    required this.primary,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.disabled,
    required this.overlay,
  });

  final Color background;
  final Color surface;
  final Color surfaceSecondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color divider;
  final Color primary;
  final Color success;
  final Color error;
  final Color warning;
  final Color info;
  final Color disabled;
  final Color overlay;

  static const light = AppColorsExtension(
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFF1F5F9),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textTertiary: Color(0xFF94A3B8),
    border: Color(0xFFE2E8F0),
    divider: Color(0xFFEDF2F7),
    primary: Color(0xFF2563EB),
    success: Color(0xFF10B981),
    error: Color(0xFFF43F5E),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF0284C7),
    disabled: Color(0xFFCBD5E1),
    overlay: Color(0x660F172A),
  );

  static const dark = AppColorsExtension(
    background: Color(0xFF0B0F17),
    surface: Color(0xFF151B26),
    surfaceSecondary: Color(0xFF1E2638),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textTertiary: Color(0xFF64748B),
    border: Color(0xFF263043),
    divider: Color(0xFF1F293D),
    primary: Color(0xFF3B82F6),
    success: Color(0xFF10B981),
    error: Color(0xFFFB7185),
    warning: Color(0xFFFBBF24),
    info: Color(0xFF38BDF8),
    disabled: Color(0xFF334155),
    overlay: Color(0x99000000),
  );

  @override
  AppColorsExtension copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSecondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? divider,
    Color? primary,
    Color? success,
    Color? error,
    Color? warning,
    Color? info,
    Color? disabled,
    Color? overlay,
  }) {
    return AppColorsExtension(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      primary: primary ?? this.primary,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      disabled: disabled ?? this.disabled,
      overlay: overlay ?? this.overlay,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
    );
  }

  /// Modern ambient card shadow
  List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: surface == const Color(0xFFFFFFFF) ? 0.04 : 0.2),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: surface == const Color(0xFFFFFFFF) ? 0.02 : 0.08),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  /// Modern primary gradient
  LinearGradient get primaryGradient => LinearGradient(
        colors: [primary, primary.withValues(alpha: 0.85)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Modern success gradient
  LinearGradient get successGradient => LinearGradient(
        colors: [success, success.withValues(alpha: 0.85)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Modern error gradient
  LinearGradient get errorGradient => LinearGradient(
        colors: [error, error.withValues(alpha: 0.85)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

extension AppColorsContext on BuildContext {
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.light;
}

/// Balans/summa ishorasiga qarab semantik rang: musbat — yashil, manfiy —
/// qizil, nol — neytral (MOBILE_APP_TZ.md 4.8, 8.1).
Color amountColor(BuildContext context, num amount) {
  final c = context.colors;
  if (amount > 0) return c.success;
  if (amount < 0) return c.error;
  return c.textTertiary;
}
