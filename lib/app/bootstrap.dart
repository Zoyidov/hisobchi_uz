import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../core/di/injector.dart';
import 'app.dart';

/// Ilovani ishga tushirish — DI, liquid-glass shaderlarini pre-warm qilish,
/// so'ng `runApp` (MOBILE_APP_TZ.md 5.2, foydalanuvchi so'roviga ko'ra
/// bottom-nav uchun liquid_glass_widgets).
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupInjector();
  await LiquidGlassWidgets.initialize();

  runApp(
    LiquidGlassWidgets.wrap(
      child: const App(),
      adaptiveQuality: true,
      brightnessResolver: Theme.maybeBrightnessOf,
    ),
  );
}
