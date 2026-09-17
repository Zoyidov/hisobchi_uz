import 'package:flutter/material.dart';

/// Material 3 asosidagi custom type scale
/// (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md bo'lim 9–10).
abstract final class AppTypography {
  static TextTheme textTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      displayLarge: TextStyle(
          fontSize: 36, fontWeight: FontWeight.w800, color: primaryColor, height: 1.15, letterSpacing: -0.8),
      displayMedium: TextStyle(
          fontSize: 32, fontWeight: FontWeight.w700, color: primaryColor, height: 1.15, letterSpacing: -0.6),
      displaySmall: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w700, color: primaryColor, height: 1.2, letterSpacing: -0.5),
      headlineLarge: TextStyle(
          fontSize: 24, fontWeight: FontWeight.w700, color: primaryColor, height: 1.25, letterSpacing: -0.4),
      headlineMedium: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w700, color: primaryColor, height: 1.25, letterSpacing: -0.3),
      headlineSmall: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, color: primaryColor, height: 1.3, letterSpacing: -0.2),
      titleLarge: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: primaryColor, height: 1.3, letterSpacing: -0.15),
      titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor, height: 1.35, letterSpacing: -0.1),
      titleSmall: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor, height: 1.35),
      bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w400, color: primaryColor, height: 1.45),
      bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, color: primaryColor, height: 1.4),
      bodySmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w400, color: secondaryColor, height: 1.4),
      labelLarge: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor, height: 1.2, letterSpacing: 0.1),
      labelMedium: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, color: secondaryColor, height: 1.2, letterSpacing: 0.2),
      labelSmall: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600, color: secondaryColor, height: 1.2, letterSpacing: 0.3),
    );
  }

  /// Pul qiymatlari uchun — dashboard darajasi (28-36sp, 700).
  static const moneyDisplay = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.6,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Pul qiymatlari — card darajasi (20-24sp, 700).
  static const moneyCard = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.3,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Pul qiymatlari — list darajasi (16-18sp, 700).
  static const moneyList = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Valyuta belgisi (12-14sp).
  static const currencyLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.2,
  );
}
