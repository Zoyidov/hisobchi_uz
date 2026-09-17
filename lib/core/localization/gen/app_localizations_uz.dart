// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appName => 'E-Hisob';

  @override
  String get commonSave => 'Saqlash';

  @override
  String get commonCancel => 'Bekor qilish';

  @override
  String get commonDelete => 'O\'chirish';

  @override
  String get commonEdit => 'Tahrirlash';

  @override
  String get commonApply => 'Qo\'llash';

  @override
  String get commonClear => 'Tozalash';

  @override
  String get commonRetry => 'Qayta urinish';

  @override
  String get commonSearch => 'Qidirish...';

  @override
  String get commonFilter => 'Filtr';

  @override
  String get commonSort => 'Saralash';

  @override
  String get commonSeeAll => 'Barchasi';

  @override
  String get commonClose => 'Yopish';

  @override
  String get commonContinue => 'Davom etish';

  @override
  String get commonSkip => 'O\'tkazib yuborish';

  @override
  String get commonYes => 'Ha';

  @override
  String get commonNo => 'Yo\'q';

  @override
  String get commonConfirm => 'Tasdiqlash';

  @override
  String get commonLoading => 'Yuklanmoqda...';

  @override
  String get commonComingSoon => 'Tez orada';

  @override
  String get commonRestore => 'Tiklash';

  @override
  String get commonShare => 'Ulashish';

  @override
  String get commonDownload => 'Yuklab olish';

  @override
  String get commonCall => 'Qo\'ng\'iroq';

  @override
  String get commonSms => 'SMS';

  @override
  String get commonReport => 'Hisobot';

  @override
  String get commonExcel => 'Excel\'ga eksport';

  @override
  String get commonSettings => 'Sozlamalar';

  @override
  String get commonBack => 'Orqaga';

  @override
  String get commonDone => 'Tayyor';

  @override
  String get commonAll => 'Barchasi';

  @override
  String get commonSaved => 'Saqlandi';

  @override
  String get errorSessionExpired => 'Sessiya tugadi, qaytadan kiring';

  @override
  String get errorOtherDevice => 'Hisobingizga boshqa qurilmadan kirildi';

  @override
  String get errorNoPermission => 'Bu amalni bajarish uchun ruxsatingiz yo\'q.';

  @override
  String get errorNoInternet => 'Internet aloqasi yo\'q';

  @override
  String get errorServer => 'Serverda xatolik. Keyinroq urinib ko\'ring';

  @override
  String get errorUnknown => 'Kutilmagan xatolik yuz berdi';

  @override
  String get authPhoneTitle => 'Telefon raqamingiz';

  @override
  String get authPhoneAgreement => 'Foydalanish shartlariga roziman';

  @override
  String get authTermsLink => 'Foydalanish shartlari';

  @override
  String get authOtpTitle => 'SMS orqali yuborilgan 4 xonali kodni kiriting';

  @override
  String get authOtpResend => 'Qayta yuborish';

  @override
  String authOtpResendIn(String seconds) {
    return 'Qayta yuborish $seconds';
  }

  @override
  String get authOtpInvalid => 'OTP noto\'g\'ri';

  @override
  String get authOtpExpired => 'OTP muddati tugagan';

  @override
  String get authRegisterTitle => 'Ro\'yxatdan o\'tish';

  @override
  String get authNameLabel => 'Ism';

  @override
  String get authPasswordLabel => 'Parol';

  @override
  String get authPasswordConfirmLabel => 'Parolni takrorlang';

  @override
  String get authRegisterButton => 'Ro\'yxatdan o\'tish';

  @override
  String get authLoginTitle => 'Kirish';

  @override
  String get authLoginButton => 'Kirish';

  @override
  String get authForgotPassword => 'Parolni unutdingizmi?';

  @override
  String get authResetPasswordTitle => 'Yangi parol';

  @override
  String get authNewPasswordLabel => 'Yangi parol';

  @override
  String get authPincodeTitle => 'Ilovani himoyalang';

  @override
  String get authPincodeSubtitle => '4 xonali PIN yarating';

  @override
  String get authPincodeRepeat => 'PIN kodni takrorlang';

  @override
  String get authPincodeMismatch => 'PIN kodlar mos emas';

  @override
  String get authPincodeSkip => 'Keyinroq';

  @override
  String get authPincodeEnter => 'PIN kodni kiriting';

  @override
  String get authPincodeForgot => 'Parol bilan kirish';

  @override
  String get authAccountSelectionTitle => 'Qaysi hisobda ishlaysiz?';

  @override
  String get authOwnAccount => 'O\'z hisobim';

  @override
  String get authStaffOf => 'Xodim sifatida';

  @override
  String authWorkingAs(String name) {
    return '$name hisobida ishlayapsiz';
  }

  @override
  String get authSwitchAccount => 'Almashtirish';

  @override
  String get authLogout => 'Chiqish';

  @override
  String get authLogoutConfirm => 'Hisobingizdan chiqishni xohlaysizmi?';

  @override
  String get authDeleteAccount => 'Hisobni o\'chirish';

  @override
  String get authDeleteAccountWarning =>
      'Barcha hamkorlar, tranzaksiyalar, loyihalar va hisobotlar o\'chiriladi. Bu amalni qaytarib bo\'lmaydi.';

  @override
  String get authBlockedTitle => 'Kirish huquqi cheklangan';

  @override
  String get authSupport => 'Qo\'llab-quvvatlash';

  @override
  String get authBiometricsReason => 'Ilovaga kirish uchun tasdiqlang';

  @override
  String dashboardGreeting(String name) {
    return 'Assalomu alaykum, $name';
  }

  @override
  String get dashboardPartnersSection => 'Hamkorlar';

  @override
  String get dashboardOverdue => 'Muddati o\'tgan';

  @override
  String get dashboardDueToday => 'Bugun';

  @override
  String get dashboardDue3Days => '3 kun ichida';

  @override
  String get dashboardInstallmentsSection => 'Bo\'lib to\'lash';

  @override
  String get dashboardProjectsSection => 'Loyihalar';

  @override
  String get dashboardInProgress => 'Jarayonda';

  @override
  String get dashboardFrozen => 'Muzlatilgan';

  @override
  String get dashboardCompleted => 'Tugallangan';

  @override
  String get dashboardAddIncome => 'Kirim';

  @override
  String get dashboardAddExpense => 'Chiqim';

  @override
  String get dashboardAddPartner => 'Hamkor';

  @override
  String get dashboardTutorials => 'Qo\'llanmalar';

  @override
  String get dashboardSubscriptionGrace => 'Obunangiz muddati tugash arafasida';

  @override
  String get dashboardSubscriptionReadOnly => 'Faqat ko\'rish rejimi';

  @override
  String get dashboardSubscriptionArchived => 'Obuna talab qilinadi';

  @override
  String get dashboardUpdateSubscription => 'Yangilash';

  @override
  String get dashboardViewPlans => 'Tariflar';

  @override
  String get partnersTitle => 'Hamkorlar';

  @override
  String get partnersSearchHint => 'Ism, telefon bo\'yicha qidirish';

  @override
  String get partnersFilterTitle => 'Filtr';

  @override
  String get partnersSortTitle => 'Saralash';

  @override
  String get partnersStatusAll => 'Barchasi';

  @override
  String get partnersStatusCreditor => 'Xaqdorlar';

  @override
  String get partnersStatusDebtor => 'Qarzdorlar';

  @override
  String get partnersStatusOverdue => 'Muddati o\'tgan qarzdorlar';

  @override
  String get partnersAdd => 'Hamkor qo\'shish';

  @override
  String get partnersEdit => 'Hamkorni tahrirlash';

  @override
  String get partnersNameField => 'Ism';

  @override
  String get partnersPhoneField => 'Telefon';

  @override
  String get partnersAdditionalPhoneField => 'Qo\'shimcha telefon';

  @override
  String get partnersMainCurrency => 'Asosiy valyuta';

  @override
  String get partnersEmptyTitle => 'Hamkorlar topilmadi';

  @override
  String get partnersEmptyDescription =>
      'Hozircha bu bo\'limda ma\'lumot yo\'q.';

  @override
  String get partnersDeletedLabel => 'O\'chirilgan';

  @override
  String get partnersCreditor => 'Xaqdor';

  @override
  String get partnersDebtor => 'Qarzdor';

  @override
  String get partnersClosed => 'Hisob-kitob yopiq';

  @override
  String get partnersInstallmentRemaining => 'Bo\'lib to\'lash';

  @override
  String get partnersConfirmDelete => 'Hamkorni o\'chirmoqchimisiz?';

  @override
  String get partnersSortLastActivity => 'Oxirgi faollik';

  @override
  String get partnersSortDebtorUzs => 'Qarzdor UZS';

  @override
  String get partnersSortDebtorUsd => 'Qarzdor USD';

  @override
  String get partnersSortCreditorUzs => 'Xaqdor UZS';

  @override
  String get partnersSortCreditorUsd => 'Xaqdor USD';

  @override
  String get partnerDetailTransactionsTab => 'Tranzaksiyalar';

  @override
  String get partnerDetailInstallmentsTab => 'Bo\'lib to\'lash';

  @override
  String get partnerDetailSmsTab => 'SMS tarixi';

  @override
  String get partnerDetailIncome => 'Kirim';

  @override
  String get partnerDetailExpense => 'Chiqim';

  @override
  String get partnerDetailBalance => 'Balans';

  @override
  String get partnerDetailSmsSettings => 'SMS sozlamalari';

  @override
  String get partnerDetailEmptyTransactions => 'Hozircha tranzaksiya yo\'q';

  @override
  String get walletIncomeTitle => 'Kirim';

  @override
  String get walletExpenseTitle => 'Chiqim';

  @override
  String get walletAmountLabel => 'Summa';

  @override
  String get walletDescriptionLabel => 'Izoh';

  @override
  String get walletReturnDateLabel => 'Qaytarish sanasi';

  @override
  String get walletWeek1 => '1 hafta';

  @override
  String get walletWeek2 => '2 hafta';

  @override
  String get walletMonth1 => '1 oy';

  @override
  String get walletPickDate => 'Sana tanlash';

  @override
  String get walletAttachFile => 'Fayl biriktirish';

  @override
  String get walletSmsWillBeSent => 'Hamkorga SMS xabar yuboriladi';

  @override
  String get walletSmsLimitReached => 'SMS limiti tugagan — xabar yuborilmaydi';

  @override
  String get walletSaveIncome => 'Kirimni saqlash';

  @override
  String get walletSaveExpense => 'Chiqimni saqlash';

  @override
  String get walletCancelTransaction => 'Tranzaksiyani bekor qilish';

  @override
  String get walletCancelReasonLabel => 'Bekor qilish sababi';

  @override
  String get walletCancelReasonHint => 'Kamida 3 belgi';

  @override
  String get walletCancelledLabel => 'Bekor qilingan';

  @override
  String get walletCancelConfirm => 'Bu amalni keyin qaytarib bo\'lmaydi.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profilePersonalInfo => 'Shaxsiy ma\'lumotlar';

  @override
  String get profileSubscription => 'Obuna va tariflar';

  @override
  String get profileSmsPackages => 'SMS paketlari';

  @override
  String get profileStaff => 'Xodimlar';

  @override
  String get profileDocuments => 'Ma\'lumotnomalar';

  @override
  String get profileActivityLog => 'Faollik jurnali';

  @override
  String get profileNotifications => 'Bildirishnomalar';

  @override
  String get profileCurrencyRates => 'Valyuta kurslari';

  @override
  String get profileGuides => 'Qo\'llanmalar';

  @override
  String get profileSettings => 'Sozlamalar';

  @override
  String get profileHelp => 'Yordam va aloqa';

  @override
  String get profileTerms => 'Foydalanish shartlari';

  @override
  String get profilePrivacy => 'Maxfiylik siyosati';

  @override
  String get profileAppVersion => 'Ilova versiyasi';

  @override
  String get settingsLanguage => 'Til';

  @override
  String get settingsTheme => 'Mavzu';

  @override
  String get settingsThemeLight => 'Yorug\'';

  @override
  String get settingsThemeDark => 'Qorong\'i';

  @override
  String get settingsThemeSystem => 'Tizim';

  @override
  String get settingsPincode => 'Pincode';

  @override
  String get settingsBiometrics => 'Biometrika';

  @override
  String get navHome => 'Bosh sahifa';

  @override
  String get navPartners => 'Hamkorlar';

  @override
  String get navProjects => 'Loyihalar';

  @override
  String get navReports => 'Hisobotlar';

  @override
  String get navProfile => 'Profil';

  @override
  String get emptyGenericTitle => 'Ma\'lumot topilmadi';

  @override
  String get emptyGenericDescription =>
      'Hozircha bu bo\'limda ma\'lumot yo\'q.';

  @override
  String get errorGenericTitle => 'Ma\'lumotni yuklab bo\'lmadi';

  @override
  String get errorGenericDescription =>
      'Internetni tekshiring yoki qayta urinib ko\'ring.';
}
