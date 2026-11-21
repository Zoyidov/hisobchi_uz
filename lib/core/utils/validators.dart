import 'formatters/phone_formatter.dart';
import '../localization/app_localization_extension.dart';

/// Forma validatorlari — inline xatolik matnlari (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 43).
///
/// Validator `build` paytida chaqiriladi, shuning uchun [AppL10n.current]
/// har doim joriy tilni beradi.
abstract final class Validators {
  static String? required(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? AppL10n.current.validationRequired;
    }
    return null;
  }

  static String? phone(String? digits9) {
    if (digits9 == null || digits9.isEmpty) {
      return AppL10n.current.validationPhoneRequired;
    }
    if (!PhoneFormatter.isValid(digits9)) {
      return AppL10n.current.validationPhoneInvalid;
    }
    return null;
  }

  static String? minLength(String? value, int min, {String? message}) {
    if (value == null || value.length < min) {
      return message ?? AppL10n.current.validationMinLength(min);
    }
    return null;
  }

  static String? password(String? value) =>
      minLength(value, 6, message: AppL10n.current.validationPasswordMinLength);

  static String? passwordConfirm(String? value, String password) {
    if (value != password) return AppL10n.current.validationPasswordsMismatch;
    return null;
  }

  static String? amount(String? rawDigits) {
    if (rawDigits == null || rawDigits.isEmpty) {
      return AppL10n.current.validationAmountRequired;
    }
    final value = num.tryParse(rawDigits);
    if (value == null || value <= 0) {
      return AppL10n.current.validationAmountPositive;
    }
    return null;
  }
}
