import 'package:flutter/widgets.dart';

/// Burchak radiusi tokenlari (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md bo'lim 5).
///
/// Feature kodda raqam yozilmaydi: `BorderRadius.circular(AppRadius.md)`
/// yoki tayyor `AppRadius.mdRadius`. Shkala kichikdan kattaga:
///
/// | token    | px  | qayerda                                  |
/// |----------|-----|------------------------------------------|
/// | hairline | 2   | diagramma ustunlari, ingichka indikator  |
/// | xxs      | 4   | badge, progress bar                      |
/// | xs       | 6   | kichik teg, checkbox                     |
/// | sm       | 8   | chip ichidagi element, tooltip           |
/// | small    | 10  | ikonka plitkasi, kichik tugma            |
/// | md       | 12  | ro'yxat elementi, kichik karta           |
/// | medium   | 14  | input, asosiy tugma                      |
/// | lg       | 16  | ichki karta, segment                     |
/// | xl       | 18  | katta plitka                             |
/// | card     | 20  | karta                                    |
/// | large    | 24  | hero karta, dialog                       |
/// | sheet    | 32  | bottom sheet yuqori burchaklari          |
/// | pill     | 999 | to'liq yumaloq (chip, capsule)           |
abstract final class AppRadius {
  static const hairline = 2.0;
  static const xxs = 4.0;
  static const xs = 6.0;
  static const sm = 8.0;
  static const small = 10.0;
  static const md = 12.0;
  static const medium = 14.0;
  static const lg = 16.0;
  static const xl = 18.0;
  static const card = 20.0;
  static const large = 24.0;
  static const sheet = 32.0;
  static const pill = 999.0;

  static BorderRadius get xxsRadius => BorderRadius.circular(xxs);
  static BorderRadius get xsRadius => BorderRadius.circular(xs);
  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get smallRadius => BorderRadius.circular(small);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get mediumRadius => BorderRadius.circular(medium);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get cardRadius => BorderRadius.circular(card);
  static BorderRadius get largeRadius => BorderRadius.circular(large);
  static BorderRadius get pillRadius => BorderRadius.circular(pill);

  static const sheetTop = BorderRadius.only(
    topLeft: Radius.circular(sheet),
    topRight: Radius.circular(sheet),
  );
}
