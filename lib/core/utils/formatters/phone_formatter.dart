/// `+998 (90) 123-45-67` ↔ `901234567` (MOBILE_APP_TZ.md 4.8,
/// E_HISOB_FLUTTER_UI_UX_TZ.md 14-bo'lim).
abstract final class PhoneFormatter {
  static const _countryCode = '+998';

  /// Backendga yuboriladigan xom 9 raqam.
  static String toApi(String display) {
    return display.replaceAll(RegExp(r'[^0-9]'), '').replaceFirst(RegExp(r'^998'), '');
  }

  /// `901234567` → `+998 (90) 123-45-67`.
  static String toDisplay(String digits9) {
    final d = digits9.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.length < 9) return '$_countryCode $d';
    final part1 = d.substring(0, 2);
    final part2 = d.substring(2, 5);
    final part3 = d.substring(5, 7);
    final part4 = d.substring(7, 9);
    return '$_countryCode ($part1) $part2-$part3-$part4';
  }

  static bool isValid(String digits9) {
    final d = digits9.replaceAll(RegExp(r'[^0-9]'), '');
    return d.length == 9;
  }
}
