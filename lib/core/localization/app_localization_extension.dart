import 'package:flutter/widgets.dart';

import 'gen/app_localizations.dart';

export 'gen/app_localizations.dart';

/// `context.l10n.commonSave` kabi ishlatish uchun (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 131).
extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// `BuildContext` mavjud bo'lmagan qatlamlar (cubit, model, formatter) uchun
/// joriy til matnlari.
///
/// UI'da **har doim** `context.l10n` ishlating — u til o'zgarganda widgetni
/// qayta quradi. [AppL10n.current] esa faqat foydalanuvchiga ko'rsatiladigan
/// matn context'dan tashqarida hosil bo'ladigan joylar uchun (masalan cubit
/// validatsiya xabari). Qiymatni [LocaleCubit] avtomatik yangilab turadi.
abstract final class AppL10n {
  static AppLocalizations _current = lookupAppLocalizations(const Locale('uz'));

  static AppLocalizations get current => _current;

  static void update(Locale locale) {
    _current = lookupAppLocalizations(locale);
  }
}
