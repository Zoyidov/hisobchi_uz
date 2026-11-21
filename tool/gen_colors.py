# Usage: python3 tool/gen_colors.py lib/core/theme/app_colors.dart
# Generates lib/core/theme/app_colors.dart (boilerplate-heavy ThemeExtension).
F = [
 # name, light, dark, doc
 ("background","F8FAFC","0B0F19","Ekran foni."),
 ("surface","FFFFFF","131B2B","Karta, sheet, dialog foni."),
 ("surfaceSecondary","F1F5F9","1B2438","Input, ikkilamchi blok foni."),
 ("surfaceTertiary","E2E8F0","243048","Uchinchi darajali fon (skeleton, track)."),
 ("textPrimary","0F172A","F8FAFC","Asosiy matn."),
 ("textSecondary","475569","94A3B8","Ikkilamchi matn."),
 ("textTertiary","94A3B8","64748B","Yordamchi matn, ikonka."),
 ("textMuted","CBD5E1","475569","O'chiq matn, placeholder."),
 ("border","E2E8F0","243048","Standart chegara."),
 ("borderSubtle","F1F5F9","1B2438","Nozik chegara."),
 ("divider","EDF2F7","1E283D","Ajratgich chiziq."),
 ("primary","0751CC","2F7BF0","Brend rangi — Hisup logotipi (#0751CC)."),
 ("onPrimary","FFFFFF","FFFFFF","Primary ustidagi matn/ikonka."),
 ("primaryStrong","0342B5","1D62D8","Primary'ning to'q tusi (bosilgan holat, gradient oxiri)."),
 ("primaryContainer","EAF1FF","112A55","Primary'ning yumshoq foni (chip, badge)."),
 ("onPrimaryContainer","0342B5","A9C9FF","primaryContainer ustidagi matn."),
 ("brandAccent","079FFF","38B2FF","Logotipning och ko'k qismi (#079FFF)."),
 ("heroGradientStart","137CEB","1F5FD6","Asosiy balans kartasi gradienti — boshi."),
 ("heroGradientEnd","0546BF","0A3A9E","Asosiy balans kartasi gradienti — oxiri."),
 ("success","10B981","34D399","Ijobiy holat, kirim."),
 ("successContainer","ECFDF5","064E3B","Ijobiy holat foni."),
 ("error","F43F5E","FB7185","Xato, chiqim, qarz."),
 ("errorContainer","FFF1F2","4C0519","Xato foni."),
 ("warning","F59E0B","FBBF24","Ogohlantirish, muddati yaqin."),
 ("warningContainer","FFFBEB","451A03","Ogohlantirish foni."),
 ("onWarningContainer","92400E","FCD34D","warningContainer ustidagi matn."),
 ("info","0284C7","38BDF8","Ma'lumot."),
 ("infoContainer","F0F9FF","082F49","Ma'lumot foni."),
 ("accentViolet","8B5CF6","A78BFA","Kategoriya rangi: binafsha."),
 ("accentIndigo","6366F1","818CF8","Kategoriya rangi: indigo."),
 ("accentCyan","06B6D4","22D3EE","Kategoriya rangi: moviy."),
 ("accentOrange","F97316","FB923C","Kategoriya rangi: to'q sariq."),
 ("accentPink","EC4899","F472B6","Kategoriya rangi: pushti."),
 ("inverseSurface","1E293B","E2E8F0","Teskari fon (tooltip, snackbar)."),
 ("onInverseSurface","F8FAFC","0F172A","inverseSurface ustidagi matn."),
 ("disabled","CBD5E1","334155","Faol bo'lmagan element."),
 ("overlay","660F172A","99000000","Modal orqa qatlami (scrim)."),
]
def hexc(v): return "Color(0x" + (v if len(v)==8 else "FF"+v) + ")"
o=[]
w=o.append
w("""import 'package:flutter/material.dart';

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
    required this.brightness,""")
for n,*_ in F: w(f"    required this.{n},")
w("  });\n")
w("  final Brightness brightness;\n")
for n,l,d,doc in F:
    w(f"  /// {doc}\n  final Color {n};\n")
w("  bool get isDark => brightness == Brightness.dark;\n")
for mode,idx in (("light",1),("dark",2)):
    w(f"  static const {mode} = AppColorsExtension(\n    brightness: Brightness.{mode},")
    for f in F: w(f"    {f[0]}: {hexc(f[idx])},")
    w("  );\n")
w("  @override\n  AppColorsExtension copyWith({\n    Brightness? brightness,")
for n,*_ in F: w(f"    Color? {n},")
w("  }) {\n    return AppColorsExtension(\n      brightness: brightness ?? this.brightness,")
for n,*_ in F: w(f"      {n}: {n} ?? this.{n},")
w("    );\n  }\n")
w("  @override\n  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {\n    if (other is! AppColorsExtension) return this;\n    return AppColorsExtension(\n      brightness: t < 0.5 ? brightness : other.brightness,")
for n,*_ in F: w(f"      {n}: Color.lerp({n}, other.{n}, t)!,")
w("    );\n  }\n")
w("""  /// Kategoriya ranglari ketma-ketligi — avatar, diagramma seriyalari,
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
      Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.light;
}

/// Balans/summa ishorasiga qarab semantik rang: musbat — yashil, manfiy —
/// qizil, nol — neytral (MOBILE_APP_TZ.md 4.8, 8.1).
Color amountColor(BuildContext context, num amount) {
  final c = context.colors;
  if (amount > 0) return c.success;
  if (amount < 0) return c.error;
  return c.textTertiary;
}""")
import sys
open(sys.argv[1],'w').write("\n".join(o)+"\n")
