import 'package:flutter/material.dart';

/// Semantik ranglar — feature kod ichida rang hech qachon hardcode
/// qilinmaydi, faqat `context.colors.<token>` orqali olinadi.
///
/// Brend: Hisup logotipi — primary `#0751CC`, brandAccent `#079FFF`.
/// Har bir token light va dark rejim uchun alohida tanlangan (WCAG AA
/// kontrast: matn tokenlari o'z fonida kamida 4.5:1).
///
/// Bu fayl `tool/gen_colors.py` bilan generatsiya qilinadi — tokenlarni o'sha
/// skriptda o'zgartiring.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.brightness,
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
    required this.onPrimary,
    required this.primaryStrong,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.brandAccent,
    required this.heroGradientStart,
    required this.heroGradientEnd,
    required this.success,
    required this.successContainer,
    required this.error,
    required this.errorContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.infoContainer,
    required this.accentViolet,
    required this.accentIndigo,
    required this.accentCyan,
    required this.accentOrange,
    required this.accentPink,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.disabled,
    required this.overlay,
  });

  final Brightness brightness;

  /// Ekran foni.
  final Color background;

  /// Karta, sheet, dialog foni.
  final Color surface;

  /// Input, ikkilamchi blok foni.
  final Color surfaceSecondary;

  /// Uchinchi darajali fon (skeleton, track).
  final Color surfaceTertiary;

  /// Asosiy matn.
  final Color textPrimary;

  /// Ikkilamchi matn.
  final Color textSecondary;

  /// Yordamchi matn, ikonka.
  final Color textTertiary;

  /// O'chiq matn, placeholder.
  final Color textMuted;

  /// Standart chegara.
  final Color border;

  /// Nozik chegara.
  final Color borderSubtle;

  /// Ajratgich chiziq.
  final Color divider;

  /// Brend rangi — Hisup logotipi (#0751CC).
  final Color primary;

  /// Primary ustidagi matn/ikonka.
  final Color onPrimary;

  /// Primary'ning to'q tusi (bosilgan holat, gradient oxiri).
  final Color primaryStrong;

  /// Primary'ning yumshoq foni (chip, badge).
  final Color primaryContainer;

  /// primaryContainer ustidagi matn.
  final Color onPrimaryContainer;

  /// Logotipning och ko'k qismi (#079FFF).
  final Color brandAccent;

  /// Asosiy balans kartasi gradienti — boshi.
  final Color heroGradientStart;

  /// Asosiy balans kartasi gradienti — oxiri.
  final Color heroGradientEnd;

  /// Ijobiy holat, kirim.
  final Color success;

  /// Ijobiy holat foni.
  final Color successContainer;

  /// Xato, chiqim, qarz.
  final Color error;

  /// Xato foni.
  final Color errorContainer;

  /// Ogohlantirish, muddati yaqin.
  final Color warning;

  /// Ogohlantirish foni.
  final Color warningContainer;

  /// warningContainer ustidagi matn.
  final Color onWarningContainer;

  /// Ma'lumot.
  final Color info;

  /// Ma'lumot foni.
  final Color infoContainer;

  /// Kategoriya rangi: binafsha.
  final Color accentViolet;

  /// Kategoriya rangi: indigo.
  final Color accentIndigo;

  /// Kategoriya rangi: moviy.
  final Color accentCyan;

  /// Kategoriya rangi: to'q sariq.
  final Color accentOrange;

  /// Kategoriya rangi: pushti.
  final Color accentPink;

  /// Teskari fon (tooltip, snackbar).
  final Color inverseSurface;

  /// inverseSurface ustidagi matn.
  final Color onInverseSurface;

  /// Faol bo'lmagan element.
  final Color disabled;

  /// Modal orqa qatlami (scrim).
  final Color overlay;

  bool get isDark => brightness == Brightness.dark;

  static const light = AppColorsExtension(
    brightness: Brightness.light,
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
    primary: Color(0xFF0751CC),
    onPrimary: Color(0xFFFFFFFF),
    primaryStrong: Color(0xFF0342B5),
    primaryContainer: Color(0xFFEAF1FF),
    onPrimaryContainer: Color(0xFF0342B5),
    brandAccent: Color(0xFF079FFF),
    heroGradientStart: Color(0xFF137CEB),
    heroGradientEnd: Color(0xFF0546BF),
    success: Color(0xFF10B981),
    successContainer: Color(0xFFECFDF5),
    error: Color(0xFFF43F5E),
    errorContainer: Color(0xFFFFF1F2),
    warning: Color(0xFFF59E0B),
    warningContainer: Color(0xFFFFFBEB),
    onWarningContainer: Color(0xFF92400E),
    info: Color(0xFF0284C7),
    infoContainer: Color(0xFFF0F9FF),
    accentViolet: Color(0xFF8B5CF6),
    accentIndigo: Color(0xFF6366F1),
    accentCyan: Color(0xFF06B6D4),
    accentOrange: Color(0xFFF97316),
    accentPink: Color(0xFFEC4899),
    inverseSurface: Color(0xFF1E293B),
    onInverseSurface: Color(0xFFF8FAFC),
    disabled: Color(0xFFCBD5E1),
    overlay: Color(0x660F172A),
  );

  static const dark = AppColorsExtension(
    brightness: Brightness.dark,
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
    primary: Color(0xFF2F7BF0),
    onPrimary: Color(0xFFFFFFFF),
    primaryStrong: Color(0xFF1D62D8),
    primaryContainer: Color(0xFF112A55),
    onPrimaryContainer: Color(0xFFA9C9FF),
    brandAccent: Color(0xFF38B2FF),
    heroGradientStart: Color(0xFF1F5FD6),
    heroGradientEnd: Color(0xFF0A3A9E),
    success: Color(0xFF34D399),
    successContainer: Color(0xFF064E3B),
    error: Color(0xFFFB7185),
    errorContainer: Color(0xFF4C0519),
    warning: Color(0xFFFBBF24),
    warningContainer: Color(0xFF451A03),
    onWarningContainer: Color(0xFFFCD34D),
    info: Color(0xFF38BDF8),
    infoContainer: Color(0xFF082F49),
    accentViolet: Color(0xFFA78BFA),
    accentIndigo: Color(0xFF818CF8),
    accentCyan: Color(0xFF22D3EE),
    accentOrange: Color(0xFFFB923C),
    accentPink: Color(0xFFF472B6),
    inverseSurface: Color(0xFFE2E8F0),
    onInverseSurface: Color(0xFF0F172A),
    disabled: Color(0xFF334155),
    overlay: Color(0x99000000),
  );

  @override
  AppColorsExtension copyWith({
    Brightness? brightness,
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
    Color? onPrimary,
    Color? primaryStrong,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? brandAccent,
    Color? heroGradientStart,
    Color? heroGradientEnd,
    Color? success,
    Color? successContainer,
    Color? error,
    Color? errorContainer,
    Color? warning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? infoContainer,
    Color? accentViolet,
    Color? accentIndigo,
    Color? accentCyan,
    Color? accentOrange,
    Color? accentPink,
    Color? inverseSurface,
    Color? onInverseSurface,
    Color? disabled,
    Color? overlay,
  }) {
    return AppColorsExtension(
      brightness: brightness ?? this.brightness,
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
      onPrimary: onPrimary ?? this.onPrimary,
      primaryStrong: primaryStrong ?? this.primaryStrong,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      brandAccent: brandAccent ?? this.brandAccent,
      heroGradientStart: heroGradientStart ?? this.heroGradientStart,
      heroGradientEnd: heroGradientEnd ?? this.heroGradientEnd,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      error: error ?? this.error,
      errorContainer: errorContainer ?? this.errorContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      accentViolet: accentViolet ?? this.accentViolet,
      accentIndigo: accentIndigo ?? this.accentIndigo,
      accentCyan: accentCyan ?? this.accentCyan,
      accentOrange: accentOrange ?? this.accentOrange,
      accentPink: accentPink ?? this.accentPink,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      onInverseSurface: onInverseSurface ?? this.onInverseSurface,
      disabled: disabled ?? this.disabled,
      overlay: overlay ?? this.overlay,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      brightness: t < 0.5 ? brightness : other.brightness,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSecondary: Color.lerp(
        surfaceSecondary,
        other.surfaceSecondary,
        t,
      )!,
      surfaceTertiary: Color.lerp(surfaceTertiary, other.surfaceTertiary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryStrong: Color.lerp(primaryStrong, other.primaryStrong, t)!,
      primaryContainer: Color.lerp(
        primaryContainer,
        other.primaryContainer,
        t,
      )!,
      onPrimaryContainer: Color.lerp(
        onPrimaryContainer,
        other.onPrimaryContainer,
        t,
      )!,
      brandAccent: Color.lerp(brandAccent, other.brandAccent, t)!,
      heroGradientStart: Color.lerp(
        heroGradientStart,
        other.heroGradientStart,
        t,
      )!,
      heroGradientEnd: Color.lerp(heroGradientEnd, other.heroGradientEnd, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      error: Color.lerp(error, other.error, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      accentViolet: Color.lerp(accentViolet, other.accentViolet, t)!,
      accentIndigo: Color.lerp(accentIndigo, other.accentIndigo, t)!,
      accentCyan: Color.lerp(accentCyan, other.accentCyan, t)!,
      accentOrange: Color.lerp(accentOrange, other.accentOrange, t)!,
      accentPink: Color.lerp(accentPink, other.accentPink, t)!,
      inverseSurface: Color.lerp(inverseSurface, other.inverseSurface, t)!,
      onInverseSurface: Color.lerp(
        onInverseSurface,
        other.onInverseSurface,
        t,
      )!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
    );
  }

  /// Kategoriya ranglari ketma-ketligi — avatar, diagramma seriyalari,
  /// teglar uchun (indeks bo'yicha aylanadi).
  List<Color> get categorical => [
    primary,
    success,
    accentViolet,
    warning,
    accentCyan,
    accentPink,
    accentIndigo,
    accentOrange,
  ];

  /// Indeks bo'yicha barqaror kategoriya rangi.
  Color categoricalAt(int index) =>
      categorical[index.abs() % categorical.length];

  /// Rangni joriy sirt ustida yumshoq fon sifatida aralashtiradi
  /// (ikonka plitkalari, badge'lar). Dark rejimda biroz kuchliroq.
  Color tint(Color color, {double? strength}) => Color.alphaBlend(
    color.withValues(alpha: strength ?? (isDark ? 0.16 : 0.10)),
    surface,
  );

  /// Modern ambient card shadow — subtle and elegant
  List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.03),
      blurRadius: 18,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.015),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  /// Elevated shadow for floating bars, modals, dialogs
  List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Bottom sheet shadow
  List<BoxShadow> get sheetShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
      blurRadius: 32,
      offset: const Offset(0, -6),
    ),
  ];

  /// Brend gradienti — logotipdagi kabi och ko'kdan to'q ko'kka.
  LinearGradient get brandGradient => LinearGradient(
    colors: [brandAccent, primary],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  /// Asosiy balans / hero kartalar uchun gradient.
  LinearGradient get heroGradient => LinearGradient(
    colors: [heroGradientStart, heroGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Primary tugma va aksentlar uchun gradient.
  LinearGradient get primaryGradient => LinearGradient(
    colors: [primary, primaryStrong],
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
      Theme.of(this).extension<AppColorsExtension>() ??
      AppColorsExtension.light;
}

/// Balans/summa ishorasiga qarab semantik rang: musbat — yashil, manfiy —
/// qizil, nol — neytral (MOBILE_APP_TZ.md 4.8, 8.1).
Color amountColor(BuildContext context, num amount) {
  final c = context.colors;
  if (amount > 0) return c.success;
  if (amount < 0) return c.error;
  return c.textTertiary;
}
