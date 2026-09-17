import 'package:decimal/decimal.dart';

/// `1 500 000 UZS` ko'rinishidagi format — uch xonali guruh, ajratgich
/// bo'shliq, `1.5M` kabi qisqartirish TAQIQLANADI
/// (MOBILE_APP_TZ.md 4.8, E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 10, 115).
abstract final class MoneyFormatter {
  static const _currencyCodes = {1: 'UZS', 2: 'USD'};

  static String currencyCode(int currencyTypeId) =>
      _currencyCodes[currencyTypeId] ?? 'UZS';

  /// `1 500 000` — faqat guruhlangan raqam, ishorasiz.
  static String groupDigits(Decimal value) {
    final isNegative = value.sign < 0;
    final abs = value.abs();
    final parts = abs.toString().split('.');
    final intPart = parts[0];
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(intPart[i]);
    }
    var result = buffer.toString();
    if (parts.length > 1) {
      final fraction = parts[1].replaceFirst(RegExp(r'0+$'), '');
      if (fraction.isNotEmpty) result += ',$fraction';
    }
    return isNegative ? '−$result' : result;
  }

  /// `1 500 000 UZS`.
  static String format(Decimal value, {int currencyTypeId = 1, String? currencyLabel}) {
    return '${groupDigits(value)} ${currencyLabel ?? currencyCode(currencyTypeId)}';
  }

  /// `+1 500 000 UZS` / `−1 500 000 UZS` — ishora bilan (tranzaksiyalar uchun).
  static String formatSigned(
    Decimal value, {
    int currencyTypeId = 1,
    String? currencyLabel,
  }) {
    final sign = value.sign <= 0 ? '' : '+';
    return '$sign${format(value, currencyTypeId: currencyTypeId, currencyLabel: currencyLabel)}';
  }

  /// Foydalanuvchi kiritayotgan xom matnni tozalab (bo'shliq/vergul), raqamga
  /// aylantirish uchun tayyorlaydi. Backendga xuddi shu qiymat yuboriladi.
  static String sanitizeInput(String raw) {
    return raw.replaceAll(RegExp(r'[^0-9.]'), '');
  }

  /// Input maydonida ko'rsatish uchun guruhlangan matn (klaviaturada yozish paytida).
  static String liveGroup(String rawDigits) {
    final digits = rawDigits.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
