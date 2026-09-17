import 'package:flutter/widgets.dart';

/// Radius tokenlari (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md bo'lim 5).
abstract final class AppRadius {
  static const small = 10.0;
  static const medium = 14.0;
  static const card = 20.0;
  static const large = 24.0;
  static const sheet = 32.0;
  static const pill = 999.0;

  static BorderRadius get smallRadius => BorderRadius.circular(small);
  static BorderRadius get mediumRadius => BorderRadius.circular(medium);
  static BorderRadius get cardRadius => BorderRadius.circular(card);
  static BorderRadius get largeRadius => BorderRadius.circular(large);
  static BorderRadius get pillRadius => BorderRadius.circular(pill);

  static const sheetTop = BorderRadius.only(
    topLeft: Radius.circular(sheet),
    topRight: Radius.circular(sheet),
  );
}
