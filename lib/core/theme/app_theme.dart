import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Light/Dark `ThemeData` — Figma design-token asosida
/// (MOBILE_APP_TZ.md 19-bo'lim, E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 7, 11).
abstract final class AppTheme {
  static ThemeData light() => _build(AppColorsExtension.light, Brightness.light);

  static ThemeData dark() => _build(AppColorsExtension.dark, Brightness.dark);

  static ThemeData _build(AppColorsExtension colors, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: Colors.white,
      primaryContainer: colors.primaryContainer,
      onPrimaryContainer: colors.onPrimaryContainer,
      secondary: colors.info,
      onSecondary: Colors.white,
      error: colors.error,
      onError: Colors.white,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      surfaceContainerHighest: colors.surfaceSecondary,
      outline: colors.border,
      outlineVariant: colors.borderSubtle,
    );

    final textTheme = AppTypography.textTheme(colors.textPrimary, colors.textSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      dividerColor: colors.divider,
      splashFactory: InkSparkle.splashFactory,
      textTheme: textTheme,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: colors.background,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: colors.background,
              ),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: BorderSide(color: colors.border.withValues(alpha: 0.8), width: 1),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(color: colors.divider, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceSecondary.withValues(alpha: 0.7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mediumRadius,
          borderSide: BorderSide(color: colors.border.withValues(alpha: 0.9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumRadius,
          borderSide: BorderSide(color: colors.border.withValues(alpha: 0.9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumRadius,
          borderSide: BorderSide(color: colors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumRadius,
          borderSide: BorderSide(color: colors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumRadius,
          borderSide: BorderSide(color: colors.error, width: 1.8),
        ),
        labelStyle: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w500),
        hintStyle: TextStyle(color: colors.textTertiary, fontWeight: FontWeight.w400),
        errorStyle: TextStyle(color: colors.error, fontSize: 12, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: colors.disabled,
          disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
          textStyle: textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          elevation: 0,
          shadowColor: colors.primary.withValues(alpha: 0.35),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: colors.border, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          minimumSize: const Size(44, 44),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      iconTheme: IconThemeData(color: colors.textPrimary, size: 24),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceSecondary,
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
        side: BorderSide.none,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colors.primary,
        unselectedLabelColor: colors.textTertiary,
        labelStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: colors.divider,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: colors.primary, width: 2.5),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
        showDragHandle: false,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.largeRadius),
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.textPrimary,
        contentTextStyle: TextStyle(color: colors.background, fontWeight: FontWeight.w500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
        elevation: 6,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? colors.primary : colors.surface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary.withValues(alpha: 0.4)
              : colors.border,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? colors.primary : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: colors.border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.primary),
      extensions: [colors],
    );
  }
}
