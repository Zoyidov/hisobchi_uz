import 'formatters/phone_formatter.dart';

/// Forma validatorlari — inline xatolik matnlari (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 43).
abstract final class Validators {
  static String? required(String? value, {String message = 'Bu maydon to\'ldirilishi shart'}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? phone(String? digits9) {
    if (digits9 == null || digits9.isEmpty) return 'Telefon raqami kiritilishi shart';
    if (!PhoneFormatter.isValid(digits9)) return 'Telefon raqami 9 ta raqamdan iborat bo\'lishi kerak';
    return null;
  }

  static String? minLength(String? value, int min, {String? message}) {
    if (value == null || value.length < min) {
      return message ?? 'Kamida $min ta belgi kiritilishi kerak';
    }
    return null;
  }

  static String? password(String? value) => minLength(value, 6, message: 'Parol kamida 6 belgidan iborat bo\'lishi kerak');

  static String? passwordConfirm(String? value, String password) {
    if (value != password) return 'Parollar mos kelmadi';
    return null;
  }

  static String? amount(String? rawDigits) {
    if (rawDigits == null || rawDigits.isEmpty) return 'Summa kiritilishi shart';
    final value = num.tryParse(rawDigits);
    if (value == null || value <= 0) return 'Summa 0 dan katta bo\'lishi kerak';
    return null;
  }
}
