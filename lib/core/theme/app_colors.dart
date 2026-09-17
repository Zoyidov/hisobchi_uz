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
    required this.surfaceTertiary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textMuted,
    required this.border,
    required this.borderSubtle,
    required this.divider,
    required this.primary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.success,
    required this.successContainer,
    required this.error,
    required this.errorContainer,
    required this.warning,
    required this.warningContainer,
    required this.info,
    required this.infoContainer,
    required this.accentViolet,
    required this.disabled,
    required this.overlay,
  });

  final Color background;
  final Color surface;
  final Color surfaceSecondary;
  final Color surfaceTertiary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textMuted;
  final Color border;
  final Color borderSubtle;
  final Color divider;
  final Color primary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color success;
  final Color successContainer;
  final Color error;
  final Color errorContainer;
  final Color warning;
  final Color warningContainer;
  final Color info;
  final Color infoContainer;
  final Color accentViolet;
  final Color disabled;
  final Color overlay;

  static const light = AppColorsExtension(
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFF1F5F9),
    surfaceTertiary: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textTertiary: Color(0xFF94A3B8),
    textMuted: Color(0xFFCBD5E1),
    border: Color(0xFFE2E8F0),
    borderSubtle: Color(0xFFF1F5F9),
    divider: Color(0xFFEDF2F7),
    primary: Color(0xFF2563EB),
    primaryContainer: Color(0xFFEFF6FF),
    onPrimaryContainer: Color(0xFF1D4ED8),
    success: Color(0xFF10B981),
    successContainer: Color(0xFFECFDF5),
    error: Color(0xFFF43F5E),
    errorContainer: Color(0xFFFFF1F2),
    warning: Color(0xFFF59E0B),
    warningContainer: Color(0xFFFFFBEB),
    info: Color(0xFF0284C7),
    infoContainer: Color(0xFFF0F9FF),
    accentViolet: Color(0xFF8B5CF6),
    disabled: Color(0xFFCBD5E1),
    overlay: Color(0x660F172A),
  );

  static const dark = AppColorsExtension(
    background: Color(0xFF0B0F19),
    surface: Color(0xFF131B2B),
    surfaceSecondary: Color(0xFF1B2438),
    surfaceTertiary: Color(0xFF243048),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textTertiary: Color(0xFF64748B),
    textMuted: Color(0xFF475569),
    border: Color(0xFF243048),
    borderSubtle: Color(0xFF1B2438),
    divider: Color(0xFF1E283D),
    primary: Color(0xFF3B82F6),
    primaryContainer: Color(0xFF1E2F52),
    onPrimaryContainer: Color(0xFF93C5FD),
    success: Color(0xFF34D399),
    successContainer: Color(0xFF064E3B),
    error: Color(0xFFFB7185),
    errorContainer: Color(0xFF4C0519),
    warning: Color(0xFFFBBF24),
    warningContainer: Color(0xFF451A03),
    info: Color(0xFF38BDF8),
    infoContainer: Color(0xFF082F49),
    accentViolet: Color(0xFFA78BFA),
    disabled: Color(0xFF334155),
    overlay: Color(0x99000000),
  );

  @override
  AppColorsExtension copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSecondary,
    Color? surfaceTertiary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textMuted,
    Color? border,
    Color? borderSubtle,
    Color? divider,
    Color? primary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? success,
    Color? successContainer,
    Color? error,
    Color? errorContainer,
    Color? warning,
    Color? warningContainer,
    Color? info,
    Color? infoContainer,
    Color? accentViolet,
    Color? disabled,
    Color? overlay,
  }) {
    return AppColorsExtension(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      surfaceTertiary: surfaceTertiary ?? this.surfaceTertiary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      divider: divider ?? this.divider,
      primary: primary ?? this.primary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      error: error ?? this.error,
      errorContainer: errorContainer ?? this.errorContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      accentViolet: accentViolet ?? this.accentViolet,
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
      surfaceTertiary: Color.lerp(surfaceTertiary, other.surfaceTertiary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      onPrimaryContainer: Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      accentViolet: Color.lerp(accentViolet, other.accentViolet, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
    );
  }

  /// Modern ambient card shadow — subtle and elegant
  List<BoxShadow> get cardShadow {
    final isLight = surface == const Color(0xFFFFFFFF);
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isLight ? 0.03 : 0.22),
        blurRadius: 18,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: isLight ? 0.015 : 0.08),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ];
  }

  /// Elevated shadow for floating bars, modals, dialogs
  List<BoxShadow> get elevatedShadow {
    final isLight = surface == const Color(0xFFFFFFFF);
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isLight ? 0.06 : 0.35),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: isLight ? 0.03 : 0.15),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Bottom sheet shadow
  List<BoxShadow> get sheetShadow {
    final isLight = surface == const Color(0xFFFFFFFF);
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isLight ? 0.08 : 0.45),
        blurRadius: 32,
        offset: const Offset(0, -6),
      ),
    ];
  }

  /// Modern primary gradient with subtle tone shift
  LinearGradient get primaryGradient => LinearGradient(
        colors: [primary, primary.withValues(alpha: 0.88)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Modern success gradient
  LinearGradient get successGradient => LinearGradient(
        colors: [success, success.withValues(alpha: 0.88)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Modern error gradient
  LinearGradient get errorGradient => LinearGradient(
        colors: [error, error.withValues(alpha: 0.88)],
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
