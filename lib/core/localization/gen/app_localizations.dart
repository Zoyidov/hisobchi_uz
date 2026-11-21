import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appName.
  ///
  /// In uz, this message translates to:
  /// **'Hisup'**
  String get appName;

  /// No description provided for @commonSave.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirish'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In uz, this message translates to:
  /// **'Tahrirlash'**
  String get commonEdit;

  /// No description provided for @commonRetry.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish'**
  String get commonRetry;

  /// No description provided for @commonSearch.
  ///
  /// In uz, this message translates to:
  /// **'Qidirish...'**
  String get commonSearch;

  /// No description provided for @commonFilter.
  ///
  /// In uz, this message translates to:
  /// **'Filtr'**
  String get commonFilter;

  /// No description provided for @commonSort.
  ///
  /// In uz, this message translates to:
  /// **'Saralash'**
  String get commonSort;

  /// No description provided for @commonClose.
  ///
  /// In uz, this message translates to:
  /// **'Yopish'**
  String get commonClose;

  /// No description provided for @commonContinue.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish'**
  String get commonContinue;

  /// No description provided for @commonRestore.
  ///
  /// In uz, this message translates to:
  /// **'Tiklash'**
  String get commonRestore;

  /// No description provided for @commonCall.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'ng\'iroq'**
  String get commonCall;

  /// No description provided for @commonReport.
  ///
  /// In uz, this message translates to:
  /// **'Hisobot'**
  String get commonReport;

  /// No description provided for @commonBack.
  ///
  /// In uz, this message translates to:
  /// **'Orqaga'**
  String get commonBack;

  /// No description provided for @commonAll.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get commonAll;

  /// No description provided for @commonSaved.
  ///
  /// In uz, this message translates to:
  /// **'Saqlandi'**
  String get commonSaved;

  /// No description provided for @errorSessionExpired.
  ///
  /// In uz, this message translates to:
  /// **'Sessiya tugadi, qaytadan kiring'**
  String get errorSessionExpired;

  /// No description provided for @errorOtherDevice.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingizga boshqa qurilmadan kirildi'**
  String get errorOtherDevice;

  /// No description provided for @errorNoPermission.
  ///
  /// In uz, this message translates to:
  /// **'Bu amalni bajarish uchun ruxsatingiz yo\'q.'**
  String get errorNoPermission;

  /// No description provided for @errorNoInternet.
  ///
  /// In uz, this message translates to:
  /// **'Internet aloqasi yo\'q'**
  String get errorNoInternet;

  /// No description provided for @errorServer.
  ///
  /// In uz, this message translates to:
  /// **'Serverda xatolik. Keyinroq urinib ko\'ring'**
  String get errorServer;

  /// No description provided for @errorUnknown.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmagan xatolik yuz berdi'**
  String get errorUnknown;

  /// No description provided for @authPhoneTitle.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqamingiz'**
  String get authPhoneTitle;

  /// No description provided for @authTermsLink.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanish shartlari'**
  String get authTermsLink;

  /// No description provided for @authOtpResend.
  ///
  /// In uz, this message translates to:
  /// **'Kodni qayta yuborish'**
  String get authOtpResend;

  /// No description provided for @authPasswordLabel.
  ///
  /// In uz, this message translates to:
  /// **'Parol'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordConfirmLabel.
  ///
  /// In uz, this message translates to:
  /// **'Parolni tasdiqlang'**
  String get authPasswordConfirmLabel;

  /// No description provided for @authRegisterButton.
  ///
  /// In uz, this message translates to:
  /// **'Ro\'yxatdan o\'tish'**
  String get authRegisterButton;

  /// No description provided for @authLoginButton.
  ///
  /// In uz, this message translates to:
  /// **'Kirish'**
  String get authLoginButton;

  /// No description provided for @authForgotPassword.
  ///
  /// In uz, this message translates to:
  /// **'Parolni unutdingizmi?'**
  String get authForgotPassword;

  /// No description provided for @authNewPasswordLabel.
  ///
  /// In uz, this message translates to:
  /// **'Yangi parol'**
  String get authNewPasswordLabel;

  /// No description provided for @authPincodeRepeat.
  ///
  /// In uz, this message translates to:
  /// **'PIN-kodni takrorlang'**
  String get authPincodeRepeat;

  /// No description provided for @authPincodeMismatch.
  ///
  /// In uz, this message translates to:
  /// **'PIN kodlar mos emas. Qaytadan kiriting'**
  String get authPincodeMismatch;

  /// No description provided for @authPincodeSkip.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha o‘tkazib yuborish'**
  String get authPincodeSkip;

  /// No description provided for @authPincodeEnter.
  ///
  /// In uz, this message translates to:
  /// **'PIN-kodingizni kiriting'**
  String get authPincodeEnter;

  /// No description provided for @authPincodeForgot.
  ///
  /// In uz, this message translates to:
  /// **'PIN-kodni unutdingizmi?'**
  String get authPincodeForgot;

  /// No description provided for @authAccountSelectionTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qaysi hisobda ishlaysiz? 👋'**
  String get authAccountSelectionTitle;

  /// No description provided for @authSwitchAccount.
  ///
  /// In uz, this message translates to:
  /// **'Almashtirish'**
  String get authSwitchAccount;

  /// No description provided for @authLogout.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get authLogout;

  /// No description provided for @authLogoutConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingizdan chiqishni xohlaysizmi?'**
  String get authLogoutConfirm;

  /// No description provided for @authDeleteAccount.
  ///
  /// In uz, this message translates to:
  /// **'Hisobni o\'chirish'**
  String get authDeleteAccount;

  /// No description provided for @authBlockedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kirish cheklangan'**
  String get authBlockedTitle;

  /// No description provided for @authBiometricsReason.
  ///
  /// In uz, this message translates to:
  /// **'Ilovaga kirish uchun tasdiqlang'**
  String get authBiometricsReason;

  /// No description provided for @dashboardCompleted.
  ///
  /// In uz, this message translates to:
  /// **'Tugallangan'**
  String get dashboardCompleted;

  /// No description provided for @dashboardAddPartner.
  ///
  /// In uz, this message translates to:
  /// **'Hamkor'**
  String get dashboardAddPartner;

  /// No description provided for @partnersStatusCreditor.
  ///
  /// In uz, this message translates to:
  /// **'Haqdorlar'**
  String get partnersStatusCreditor;

  /// No description provided for @partnersStatusDebtor.
  ///
  /// In uz, this message translates to:
  /// **'Qarzdorlar'**
  String get partnersStatusDebtor;

  /// No description provided for @partnersStatusOverdue.
  ///
  /// In uz, this message translates to:
  /// **'Muddati o\'tgan qarzdorlar'**
  String get partnersStatusOverdue;

  /// No description provided for @partnersAdd.
  ///
  /// In uz, this message translates to:
  /// **'Hamkor qo‘shish'**
  String get partnersAdd;

  /// No description provided for @partnersEdit.
  ///
  /// In uz, this message translates to:
  /// **'Hamkorni tahrirlash'**
  String get partnersEdit;

  /// No description provided for @partnersNameField.
  ///
  /// In uz, this message translates to:
  /// **'Ism'**
  String get partnersNameField;

  /// No description provided for @partnersPhoneField.
  ///
  /// In uz, this message translates to:
  /// **'Telefon'**
  String get partnersPhoneField;

  /// No description provided for @partnersAdditionalPhoneField.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'shimcha telefon'**
  String get partnersAdditionalPhoneField;

  /// No description provided for @partnersMainCurrency.
  ///
  /// In uz, this message translates to:
  /// **'Asosiy valyuta'**
  String get partnersMainCurrency;

  /// No description provided for @partnersEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hamkorlar topilmadi'**
  String get partnersEmptyTitle;

  /// No description provided for @partnersCreditor.
  ///
  /// In uz, this message translates to:
  /// **'Haqdor'**
  String get partnersCreditor;

  /// No description provided for @partnersDebtor.
  ///
  /// In uz, this message translates to:
  /// **'Qarzdor'**
  String get partnersDebtor;

  /// No description provided for @partnersSortLastActivity.
  ///
  /// In uz, this message translates to:
  /// **'Oxirgi faollik'**
  String get partnersSortLastActivity;

  /// No description provided for @partnersSortDebtorUzs.
  ///
  /// In uz, this message translates to:
  /// **'Qarzdor UZS'**
  String get partnersSortDebtorUzs;

  /// No description provided for @partnersSortDebtorUsd.
  ///
  /// In uz, this message translates to:
  /// **'Qarzdor USD'**
  String get partnersSortDebtorUsd;

  /// No description provided for @partnersSortCreditorUzs.
  ///
  /// In uz, this message translates to:
  /// **'Xaqdor UZS'**
  String get partnersSortCreditorUzs;

  /// No description provided for @partnersSortCreditorUsd.
  ///
  /// In uz, this message translates to:
  /// **'Xaqdor USD'**
  String get partnersSortCreditorUsd;

  /// No description provided for @partnerDetailTransactionsTab.
  ///
  /// In uz, this message translates to:
  /// **'Tranzaksiyalar'**
  String get partnerDetailTransactionsTab;

  /// No description provided for @partnerDetailSmsTab.
  ///
  /// In uz, this message translates to:
  /// **'SMS tarixi'**
  String get partnerDetailSmsTab;

  /// No description provided for @partnerDetailSmsSettings.
  ///
  /// In uz, this message translates to:
  /// **'SMS sozlamalari'**
  String get partnerDetailSmsSettings;

  /// No description provided for @partnerDetailEmptyTransactions.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha tranzaksiya yo\'q'**
  String get partnerDetailEmptyTransactions;

  /// No description provided for @walletAmountLabel.
  ///
  /// In uz, this message translates to:
  /// **'Summa'**
  String get walletAmountLabel;

  /// No description provided for @walletReturnDateLabel.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarish sanasi'**
  String get walletReturnDateLabel;

  /// No description provided for @walletWeek1.
  ///
  /// In uz, this message translates to:
  /// **'1 hafta'**
  String get walletWeek1;

  /// No description provided for @walletWeek2.
  ///
  /// In uz, this message translates to:
  /// **'2 hafta'**
  String get walletWeek2;

  /// No description provided for @walletMonth1.
  ///
  /// In uz, this message translates to:
  /// **'1 oy'**
  String get walletMonth1;

  /// No description provided for @walletPickDate.
  ///
  /// In uz, this message translates to:
  /// **'Sana tanlash'**
  String get walletPickDate;

  /// No description provided for @walletSmsWillBeSent.
  ///
  /// In uz, this message translates to:
  /// **'Hamkorga SMS xabar yuboriladi'**
  String get walletSmsWillBeSent;

  /// No description provided for @walletSaveIncome.
  ///
  /// In uz, this message translates to:
  /// **'Kirimni saqlash'**
  String get walletSaveIncome;

  /// No description provided for @walletSaveExpense.
  ///
  /// In uz, this message translates to:
  /// **'Chiqimni saqlash'**
  String get walletSaveExpense;

  /// No description provided for @walletCancelTransaction.
  ///
  /// In uz, this message translates to:
  /// **'Tranzaksiyani bekor qilish'**
  String get walletCancelTransaction;

  /// No description provided for @walletCancelReasonLabel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish sababi'**
  String get walletCancelReasonLabel;

  /// No description provided for @profileTitle.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In uz, this message translates to:
  /// **'Shaxsiy ma\'lumotlar'**
  String get profilePersonalInfo;

  /// No description provided for @profileSubscription.
  ///
  /// In uz, this message translates to:
  /// **'Obuna va tariflar'**
  String get profileSubscription;

  /// No description provided for @profileSmsPackages.
  ///
  /// In uz, this message translates to:
  /// **'SMS paketlari'**
  String get profileSmsPackages;

  /// No description provided for @profileStaff.
  ///
  /// In uz, this message translates to:
  /// **'Xodimlar'**
  String get profileStaff;

  /// No description provided for @profileDocuments.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumotnomalar'**
  String get profileDocuments;

  /// No description provided for @profileNotifications.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get profileNotifications;

  /// No description provided for @profileSettings.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalar'**
  String get profileSettings;

  /// No description provided for @settingsTheme.
  ///
  /// In uz, this message translates to:
  /// **'Mavzu'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In uz, this message translates to:
  /// **'Yorug\''**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In uz, this message translates to:
  /// **'Qorong\'i'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In uz, this message translates to:
  /// **'Tizim'**
  String get settingsThemeSystem;

  /// No description provided for @navHome.
  ///
  /// In uz, this message translates to:
  /// **'Asosiy'**
  String get navHome;

  /// No description provided for @navPartners.
  ///
  /// In uz, this message translates to:
  /// **'Hamkorlar'**
  String get navPartners;

  /// No description provided for @navProjects.
  ///
  /// In uz, this message translates to:
  /// **'Loyihalar'**
  String get navProjects;

  /// No description provided for @navReports.
  ///
  /// In uz, this message translates to:
  /// **'Hisobotlar'**
  String get navReports;

  /// No description provided for @navProfile.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @emptyGenericTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumot topilmadi'**
  String get emptyGenericTitle;

  /// No description provided for @errorGenericTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumotni yuklab bo\'lmadi'**
  String get errorGenericTitle;

  /// No description provided for @errorGenericDescription.
  ///
  /// In uz, this message translates to:
  /// **'Internetni tekshiring yoki qayta urinib ko\'ring.'**
  String get errorGenericDescription;

  /// No description provided for @connectivityOffline.
  ///
  /// In uz, this message translates to:
  /// **'Internet yo‘q — oxirgi ma’lumotlar ko‘rsatilmoqda'**
  String get connectivityOffline;

  /// No description provided for @connectivityRestored.
  ///
  /// In uz, this message translates to:
  /// **'Internet aloqasi tiklandi'**
  String get connectivityRestored;

  /// No description provided for @dashboardOverdueLabel.
  ///
  /// In uz, this message translates to:
  /// **'Muddati o‘tgan'**
  String get dashboardOverdueLabel;

  /// No description provided for @docWorkTypeNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Ish turi topilmadi'**
  String get docWorkTypeNotFound;

  /// No description provided for @docWorkTypeAdd.
  ///
  /// In uz, this message translates to:
  /// **'Ish turi qo‘shish'**
  String get docWorkTypeAdd;

  /// No description provided for @docWorkTypeEdit.
  ///
  /// In uz, this message translates to:
  /// **'Ish turini tahrirlash'**
  String get docWorkTypeEdit;

  /// No description provided for @docWorkTypeDeleteConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Ish turi o‘chirilsinmi?'**
  String get docWorkTypeDeleteConfirm;

  /// No description provided for @docPositionNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Lavozim topilmadi'**
  String get docPositionNotFound;

  /// No description provided for @docPositionAdd.
  ///
  /// In uz, this message translates to:
  /// **'Lavozim qo‘shish'**
  String get docPositionAdd;

  /// No description provided for @docPositionEdit.
  ///
  /// In uz, this message translates to:
  /// **'Lavozimni tahrirlash'**
  String get docPositionEdit;

  /// No description provided for @docPositionDeleteConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Lavozim o‘chirilsinmi?'**
  String get docPositionDeleteConfirm;

  /// No description provided for @installmentStepDetails.
  ///
  /// In uz, this message translates to:
  /// **'Ma’lumotlar'**
  String get installmentStepDetails;

  /// No description provided for @walletExpenseAmount.
  ///
  /// In uz, this message translates to:
  /// **'Chiqim summasi'**
  String get walletExpenseAmount;

  /// No description provided for @walletIncomeAmount.
  ///
  /// In uz, this message translates to:
  /// **'Kirim summasi'**
  String get walletIncomeAmount;

  /// No description provided for @staffStepPhone.
  ///
  /// In uz, this message translates to:
  /// **'Telefon'**
  String get staffStepPhone;

  /// No description provided for @errorValidation.
  ///
  /// In uz, this message translates to:
  /// **'Kiritilgan ma\'lumotlarda xatolik bor'**
  String get errorValidation;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In uz, this message translates to:
  /// **'Juda ko\'p urinish. Biroz kutib qayta urining.'**
  String get errorTooManyRequests;

  /// No description provided for @errorWithDetails.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik: {details}'**
  String errorWithDetails(Object details);

  /// No description provided for @errorRequestCancelled.
  ///
  /// In uz, this message translates to:
  /// **'So\'rov bekor qilindi'**
  String get errorRequestCancelled;

  /// No description provided for @errorGeneric.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik yuz berdi'**
  String get errorGeneric;

  /// No description provided for @dateToday.
  ///
  /// In uz, this message translates to:
  /// **'Bugun'**
  String get dateToday;

  /// No description provided for @dateYesterday.
  ///
  /// In uz, this message translates to:
  /// **'Kecha'**
  String get dateYesterday;

  /// No description provided for @dateDaysAgo.
  ///
  /// In uz, this message translates to:
  /// **'{count} kun oldin'**
  String dateDaysAgo(int count);

  /// No description provided for @validationRequired.
  ///
  /// In uz, this message translates to:
  /// **'Bu maydon to\'ldirilishi shart'**
  String get validationRequired;

  /// No description provided for @validationPhoneRequired.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqami kiritilishi shart'**
  String get validationPhoneRequired;

  /// No description provided for @validationPhoneInvalid.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqami 9 ta raqamdan iborat bo\'lishi kerak'**
  String get validationPhoneInvalid;

  /// No description provided for @validationMinLength.
  ///
  /// In uz, this message translates to:
  /// **'Kamida {min} ta belgi kiritilishi kerak'**
  String validationMinLength(int min);

  /// No description provided for @validationPasswordMinLength.
  ///
  /// In uz, this message translates to:
  /// **'Parol kamida 6 belgidan iborat bo\'lishi kerak'**
  String get validationPasswordMinLength;

  /// No description provided for @validationPasswordsMismatch.
  ///
  /// In uz, this message translates to:
  /// **'Parollar mos kelmadi'**
  String get validationPasswordsMismatch;

  /// No description provided for @validationAmountRequired.
  ///
  /// In uz, this message translates to:
  /// **'Summa kiritilishi shart'**
  String get validationAmountRequired;

  /// No description provided for @validationAmountPositive.
  ///
  /// In uz, this message translates to:
  /// **'Summa 0 dan katta bo\'lishi kerak'**
  String get validationAmountPositive;

  /// No description provided for @balanceNet.
  ///
  /// In uz, this message translates to:
  /// **'Sof balans'**
  String get balanceNet;

  /// No description provided for @commonIncome.
  ///
  /// In uz, this message translates to:
  /// **'Kirim'**
  String get commonIncome;

  /// No description provided for @commonExpense.
  ///
  /// In uz, this message translates to:
  /// **'Chiqim'**
  String get commonExpense;

  /// No description provided for @balanceInstallmentRemaining.
  ///
  /// In uz, this message translates to:
  /// **'Bo\'lib to\'lash qoldig\'i'**
  String get balanceInstallmentRemaining;

  /// No description provided for @subscriptionBannerGrace.
  ///
  /// In uz, this message translates to:
  /// **'Obunangiz muddati tugash arafasida'**
  String get subscriptionBannerGrace;

  /// No description provided for @subscriptionBannerRenew.
  ///
  /// In uz, this message translates to:
  /// **'Yangilash'**
  String get subscriptionBannerRenew;

  /// No description provided for @subscriptionBannerReadOnly.
  ///
  /// In uz, this message translates to:
  /// **'Faqat ko\'rish rejimi'**
  String get subscriptionBannerReadOnly;

  /// No description provided for @subscriptionBannerPlans.
  ///
  /// In uz, this message translates to:
  /// **'Tariflar'**
  String get subscriptionBannerPlans;

  /// No description provided for @subscriptionBannerRequired.
  ///
  /// In uz, this message translates to:
  /// **'Obuna talab qilinadi'**
  String get subscriptionBannerRequired;

  /// No description provided for @fileCameraGalleryError.
  ///
  /// In uz, this message translates to:
  /// **'Kamera yoki galereyani ochib bo‘lmadi. Qurilma ruxsatlarini tekshiring.'**
  String get fileCameraGalleryError;

  /// No description provided for @fileOpenError.
  ///
  /// In uz, this message translates to:
  /// **'Faylni ochib bo‘lmadi. Qayta urinib ko‘ring.'**
  String get fileOpenError;

  /// No description provided for @fileAttach.
  ///
  /// In uz, this message translates to:
  /// **'Fayl biriktirish'**
  String get fileAttach;

  /// No description provided for @fileCamera.
  ///
  /// In uz, this message translates to:
  /// **'Kamera'**
  String get fileCamera;

  /// No description provided for @fileGallery.
  ///
  /// In uz, this message translates to:
  /// **'Galereya'**
  String get fileGallery;

  /// No description provided for @fileFile.
  ///
  /// In uz, this message translates to:
  /// **'Fayl'**
  String get fileFile;

  /// No description provided for @fileTooLarge.
  ///
  /// In uz, this message translates to:
  /// **'Fayl hajmi 5 MB dan katta bo\'lmasligi kerak'**
  String get fileTooLarge;

  /// No description provided for @fileImage.
  ///
  /// In uz, this message translates to:
  /// **'Rasm'**
  String get fileImage;

  /// No description provided for @fileRemoveImage.
  ///
  /// In uz, this message translates to:
  /// **'Rasmni olib tashlash'**
  String get fileRemoveImage;

  /// No description provided for @fileRetryUpload.
  ///
  /// In uz, this message translates to:
  /// **'{name} · Qayta urinish'**
  String fileRetryUpload(Object name);

  /// No description provided for @fileAttachedFiles.
  ///
  /// In uz, this message translates to:
  /// **'Biriktirilgan fayllar ({count})'**
  String fileAttachedFiles(int count);

  /// No description provided for @fileOpenImage.
  ///
  /// In uz, this message translates to:
  /// **'Rasmni ochish'**
  String get fileOpenImage;

  /// No description provided for @fileOpenFile.
  ///
  /// In uz, this message translates to:
  /// **'Faylni ochish'**
  String get fileOpenFile;

  /// No description provided for @fileNumbered.
  ///
  /// In uz, this message translates to:
  /// **'Fayl #{id}'**
  String fileNumbered(Object id);

  /// No description provided for @fileImageLoadRetry.
  ///
  /// In uz, this message translates to:
  /// **'Rasm yuklanmadi. Qayta urinish'**
  String get fileImageLoadRetry;

  /// No description provided for @commonConfirmContinue.
  ///
  /// In uz, this message translates to:
  /// **'Ha, davom etish'**
  String get commonConfirmContinue;

  /// No description provided for @commonSelectedCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta tanlandi'**
  String commonSelectedCount(int count);

  /// No description provided for @commonSelect.
  ///
  /// In uz, this message translates to:
  /// **'Tanlash'**
  String get commonSelect;

  /// No description provided for @activityActionCancelled.
  ///
  /// In uz, this message translates to:
  /// **'bekor qildi'**
  String get activityActionCancelled;

  /// No description provided for @activityActionDeleted.
  ///
  /// In uz, this message translates to:
  /// **'o\'chirdi'**
  String get activityActionDeleted;

  /// No description provided for @activityModelInstallmentPlan.
  ///
  /// In uz, this message translates to:
  /// **'bo\'lib to\'lash rejasini'**
  String get activityModelInstallmentPlan;

  /// No description provided for @activityLogTitle.
  ///
  /// In uz, this message translates to:
  /// **'Faollik jurnali'**
  String get activityLogTitle;

  /// No description provided for @activityLogFilterByAction.
  ///
  /// In uz, this message translates to:
  /// **'Amal bo\'yicha filtr'**
  String get activityLogFilterByAction;

  /// No description provided for @activityLogEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Faoliyat topilmadi'**
  String get activityLogEmpty;

  /// No description provided for @notificationsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnoma yo\'q'**
  String get notificationsEmpty;

  /// No description provided for @authAccountsLoadError.
  ///
  /// In uz, this message translates to:
  /// **'Hisob ma\'lumotlarini yuklab bo\'lmadi. Qayta urinib ko\'ring.'**
  String get authAccountsLoadError;

  /// No description provided for @authAccountSelectionBadge.
  ///
  /// In uz, this message translates to:
  /// **'HISOBNI TANLASH 🏢'**
  String get authAccountSelectionBadge;

  /// No description provided for @authAccountSelectionSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Xodim sifatida ish joyingizni tanlang yoki o‘zingizning biznes hisobingizga kiring.'**
  String get authAccountSelectionSubtitle;

  /// No description provided for @authAccountsLoading.
  ///
  /// In uz, this message translates to:
  /// **'Hisob ma\'lumotlari yuklanmoqda...'**
  String get authAccountsLoading;

  /// No description provided for @commonReload.
  ///
  /// In uz, this message translates to:
  /// **'Qayta yuklash'**
  String get commonReload;

  /// No description provided for @authAccountOpening.
  ///
  /// In uz, this message translates to:
  /// **'Hisob ochilmoqda...'**
  String get authAccountOpening;

  /// No description provided for @authOpenOwnBusiness.
  ///
  /// In uz, this message translates to:
  /// **'O\'z biznes hisobimni ochish'**
  String get authOpenOwnBusiness;

  /// No description provided for @authOwnerBadge.
  ///
  /// In uz, this message translates to:
  /// **'ASOSIY • EGASI'**
  String get authOwnerBadge;

  /// No description provided for @authOwnerDescription.
  ///
  /// In uz, this message translates to:
  /// **'Shaxsiy biznesingiz va to\'liq hisobdorlik'**
  String get authOwnerDescription;

  /// No description provided for @authStaffAccountsHeader.
  ///
  /// In uz, this message translates to:
  /// **'XODIM SIFATIDA BIRIKTIRILGAN HISOBDORLIKLAR'**
  String get authStaffAccountsHeader;

  /// No description provided for @authStaffAccountDescription.
  ///
  /// In uz, this message translates to:
  /// **'Biriktirilgan korxona hisoboti'**
  String get authStaffAccountDescription;

  /// No description provided for @authAccountsIsolated.
  ///
  /// In uz, this message translates to:
  /// **'Har bir hisob xavfsiz ajratilgan holda yuritiladi'**
  String get authAccountsIsolated;

  /// No description provided for @forceUpdateBadge.
  ///
  /// In uz, this message translates to:
  /// **'YANGI TALQIN MAVJUD • UPDATE'**
  String get forceUpdateBadge;

  /// No description provided for @forceUpdateTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ilovani yangilash zarur'**
  String get forceUpdateTitle;

  /// No description provided for @forceUpdateDescription.
  ///
  /// In uz, this message translates to:
  /// **'Hisup yangi moliyaviy imkoniyatlar, takomillashtirilgan xavfsizlik va yuqori tezlikka ega bo\'ldi. Davom ettirish uchun ilovani yangilang.'**
  String get forceUpdateDescription;

  /// No description provided for @forceUpdateFastTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tezkor ishlash'**
  String get forceUpdateFastTitle;

  /// No description provided for @forceUpdateFastDescription.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumotlar almashinuvi sezilarli darajada optimallashdi'**
  String get forceUpdateFastDescription;

  /// No description provided for @forceUpdateSecurityTitle.
  ///
  /// In uz, this message translates to:
  /// **'Xavfsizlik protokollari'**
  String get forceUpdateSecurityTitle;

  /// No description provided for @forceUpdateSecurityDescription.
  ///
  /// In uz, this message translates to:
  /// **'Bank darajasidagi yangilangan shifrlash tizimi'**
  String get forceUpdateSecurityDescription;

  /// No description provided for @forceUpdateButton.
  ///
  /// In uz, this message translates to:
  /// **'Ilovani yangilash'**
  String get forceUpdateButton;

  /// No description provided for @authSecureFooter.
  ///
  /// In uz, this message translates to:
  /// **'256-bit shifrlangan • Ma\'lumotlar to\'liq xavfsiz'**
  String get authSecureFooter;

  /// No description provided for @authSmsSending.
  ///
  /// In uz, this message translates to:
  /// **'SMS kod yuborilmoqda...'**
  String get authSmsSending;

  /// No description provided for @authPleaseWait.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, biroz kuting'**
  String get authPleaseWait;

  /// No description provided for @authCodeNotSent.
  ///
  /// In uz, this message translates to:
  /// **'Kod yuborilmadi'**
  String get authCodeNotSent;

  /// No description provided for @errorUnknownRetry.
  ///
  /// In uz, this message translates to:
  /// **'Noma\'lum xatolik yuz berdi. Qayta urinib ko\'ring.'**
  String get errorUnknownRetry;

  /// No description provided for @authLoginHeading.
  ///
  /// In uz, this message translates to:
  /// **'Hisobga kirish 👋'**
  String get authLoginHeading;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish uchun maxfiy parolingizni kiriting.'**
  String get authLoginSubtitle;

  /// No description provided for @commonChange.
  ///
  /// In uz, this message translates to:
  /// **'O\'zgartirish'**
  String get commonChange;

  /// No description provided for @authPasswordHint.
  ///
  /// In uz, this message translates to:
  /// **'Parolni kiriting'**
  String get authPasswordHint;

  /// No description provided for @authSecureFooterAll.
  ///
  /// In uz, this message translates to:
  /// **'256-bit shifrlangan • Barcha ma\'lumotlar xavfsiz'**
  String get authSecureFooterAll;

  /// No description provided for @authOtpBadge.
  ///
  /// In uz, this message translates to:
  /// **'XAVFSIZLIK QADAMI'**
  String get authOtpBadge;

  /// No description provided for @authOtpHeading.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash kodi 🔐'**
  String get authOtpHeading;

  /// No description provided for @authOtpSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Quyidagi telefon raqamiga yuborilgan 4 xonali SMS kodni kiriting:'**
  String get authOtpSubtitle;

  /// No description provided for @authOtpVerifying.
  ///
  /// In uz, this message translates to:
  /// **'Kod tekshirilmoqda...'**
  String get authOtpVerifying;

  /// No description provided for @authOtpResendInPrefix.
  ///
  /// In uz, this message translates to:
  /// **'Kodni qayta yuborish: '**
  String get authOtpResendInPrefix;

  /// No description provided for @authOtpDoNotShare.
  ///
  /// In uz, this message translates to:
  /// **'SMS kod hech kimga berilmasin'**
  String get authOtpDoNotShare;

  /// No description provided for @authPhoneHeading.
  ///
  /// In uz, this message translates to:
  /// **'Keling, boshlaymiz! 👋'**
  String get authPhoneHeading;

  /// No description provided for @authPhoneSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingizga kirish yoki yangi biznesingizni ulash uchun telefon raqamingizni kiriting.'**
  String get authPhoneSubtitle;

  /// No description provided for @authPhoneLabel.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqami'**
  String get authPhoneLabel;

  /// No description provided for @authPhoneValid.
  ///
  /// In uz, this message translates to:
  /// **'To\'g\'ri format'**
  String get authPhoneValid;

  /// No description provided for @authAgreementPrefix.
  ///
  /// In uz, this message translates to:
  /// **'Men '**
  String get authAgreementPrefix;

  /// No description provided for @authTermsBody.
  ///
  /// In uz, this message translates to:
  /// **'Hisup platformasidan foydalanish orqali siz barcha moliyaviy amaliyotlar shaffofligi, xavfsizlik talablari hamda xizmat ko\'rsatish qoidalariga rozilik bildirasiz.'**
  String get authTermsBody;

  /// No description provided for @authAgreementAnd.
  ///
  /// In uz, this message translates to:
  /// **' va '**
  String get authAgreementAnd;

  /// No description provided for @authPrivacyLink.
  ///
  /// In uz, this message translates to:
  /// **'Maxfiylik siyosati'**
  String get authPrivacyLink;

  /// No description provided for @authPrivacyBody.
  ///
  /// In uz, this message translates to:
  /// **'Sizning shaxsiy ma\'lumotlaringiz va moliyaviy hisobotlaringiz 256-bitli SSL xavfsizlik protokollari bilan qat\'iy himoyalangan bo\'lib, uchinchi shaxslarga berilmaydi.'**
  String get authPrivacyBody;

  /// No description provided for @authAgreementSuffix.
  ///
  /// In uz, this message translates to:
  /// **'ga to\'liq roziman'**
  String get authAgreementSuffix;

  /// No description provided for @commonGotIt.
  ///
  /// In uz, this message translates to:
  /// **'Tushundim'**
  String get commonGotIt;

  /// No description provided for @authHello.
  ///
  /// In uz, this message translates to:
  /// **'Salom, {name}!'**
  String authHello(Object name);

  /// No description provided for @authWelcome.
  ///
  /// In uz, this message translates to:
  /// **'Xush kelibsiz!'**
  String get authWelcome;

  /// No description provided for @authPinWrongAttempts.
  ///
  /// In uz, this message translates to:
  /// **'Noto\'g\'ri PIN. Qolgan urinishlar: {attempts}'**
  String authPinWrongAttempts(Object attempts);

  /// No description provided for @authSecureEntry.
  ///
  /// In uz, this message translates to:
  /// **'Xavfsiz kirish'**
  String get authSecureEntry;

  /// No description provided for @authPincodeCreate.
  ///
  /// In uz, this message translates to:
  /// **'Yangi PIN-kod yarating'**
  String get authPincodeCreate;

  /// No description provided for @authRegisterBadge.
  ///
  /// In uz, this message translates to:
  /// **'YANGI PROFIL'**
  String get authRegisterBadge;

  /// No description provided for @authRegisterHeading.
  ///
  /// In uz, this message translates to:
  /// **'Ro\'yxatdan o\'tish ✨'**
  String get authRegisterHeading;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisup biznes tizimida shaxsiy profilingizni shakllantiring.'**
  String get authRegisterSubtitle;

  /// No description provided for @authFullNameLabel.
  ///
  /// In uz, this message translates to:
  /// **'To\'liq ismingiz'**
  String get authFullNameLabel;

  /// No description provided for @authFullNameHint.
  ///
  /// In uz, this message translates to:
  /// **'Masalan: Alisher Usmonov'**
  String get authFullNameHint;

  /// No description provided for @authPasswordMinHint.
  ///
  /// In uz, this message translates to:
  /// **'Kamida 6 ta belgi'**
  String get authPasswordMinHint;

  /// No description provided for @authPasswordRepeatHint.
  ///
  /// In uz, this message translates to:
  /// **'Parolni qayta kiriting'**
  String get authPasswordRepeatHint;

  /// No description provided for @authResetBadge.
  ///
  /// In uz, this message translates to:
  /// **'PAROLNI TIKLASH'**
  String get authResetBadge;

  /// No description provided for @authResetHeading.
  ///
  /// In uz, this message translates to:
  /// **'Yangi parol o\'rnatish 🔑'**
  String get authResetHeading;

  /// No description provided for @authResetSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingiz xavfsizligi uchun yangi ishonchli parol kiriting.'**
  String get authResetSubtitle;

  /// No description provided for @authSaveAndLogin.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash va kirish'**
  String get authSaveAndLogin;

  /// No description provided for @splashTagline.
  ///
  /// In uz, this message translates to:
  /// **'Biznes va moliya boshqaruvi'**
  String get splashTagline;

  /// No description provided for @splashSecure.
  ///
  /// In uz, this message translates to:
  /// **'Xavfsiz va himoyalangan tizim'**
  String get splashSecure;

  /// No description provided for @dueQarzExpired.
  ///
  /// In uz, this message translates to:
  /// **'Muddati o\'tgan qarzlar'**
  String get dueQarzExpired;

  /// No description provided for @dueQarzToday.
  ///
  /// In uz, this message translates to:
  /// **'Bugun muddati'**
  String get dueQarzToday;

  /// No description provided for @dueIn3Days.
  ///
  /// In uz, this message translates to:
  /// **'3 kun ichida'**
  String get dueIn3Days;

  /// No description provided for @dueInstallmentExpired.
  ///
  /// In uz, this message translates to:
  /// **'Muddati o\'tgan (bo\'lib to\'lash)'**
  String get dueInstallmentExpired;

  /// No description provided for @dueInstallmentToday.
  ///
  /// In uz, this message translates to:
  /// **'Bugun (bo\'lib to\'lash)'**
  String get dueInstallmentToday;

  /// No description provided for @dueInstallment3Days.
  ///
  /// In uz, this message translates to:
  /// **'3 kun ichida (bo\'lib to\'lash)'**
  String get dueInstallment3Days;

  /// No description provided for @dueEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Bu bo\'limda ma\'lumot yo\'q'**
  String get dueEmpty;

  /// No description provided for @dashboardAddProject.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha'**
  String get dashboardAddProject;

  /// No description provided for @greetingMorning.
  ///
  /// In uz, this message translates to:
  /// **'Xayrli tong,'**
  String get greetingMorning;

  /// No description provided for @greetingDay.
  ///
  /// In uz, this message translates to:
  /// **'Xayrli kun,'**
  String get greetingDay;

  /// No description provided for @greetingEvening.
  ///
  /// In uz, this message translates to:
  /// **'Xayrli kech,'**
  String get greetingEvening;

  /// No description provided for @greetingNight.
  ///
  /// In uz, this message translates to:
  /// **'Xayrli tun,'**
  String get greetingNight;

  /// No description provided for @dashboardOpenProfile.
  ///
  /// In uz, this message translates to:
  /// **'Profilni ochish'**
  String get dashboardOpenProfile;

  /// No description provided for @hisupLogoLabel.
  ///
  /// In uz, this message translates to:
  /// **'Hisup logosi'**
  String get hisupLogoLabel;

  /// No description provided for @dashboardTitle.
  ///
  /// In uz, this message translates to:
  /// **'Boshqaruv paneli'**
  String get dashboardTitle;

  /// No description provided for @notificationsUnreadCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta o‘qilmagan bildirishnoma'**
  String notificationsUnreadCount(int count);

  /// No description provided for @dashboardHeroTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisob-kitoblar nazoratda'**
  String get dashboardHeroTitle;

  /// No description provided for @dashboardOverduePayments.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta muddati o‘tgan to‘lov'**
  String dashboardOverduePayments(int count);

  /// No description provided for @dashboardHeroSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha va to‘lovlarni bir joyda boshqaring'**
  String get dashboardHeroSubtitle;

  /// No description provided for @dashboardTodayDebts.
  ///
  /// In uz, this message translates to:
  /// **'Bugungi qarzlar'**
  String get dashboardTodayDebts;

  /// No description provided for @dashboardPartnersDebt.
  ///
  /// In uz, this message translates to:
  /// **'Hamkorlar qarzi'**
  String get dashboardPartnersDebt;

  /// No description provided for @commonInstallment.
  ///
  /// In uz, this message translates to:
  /// **'Bo‘lib to‘lash'**
  String get commonInstallment;

  /// No description provided for @dueToday.
  ///
  /// In uz, this message translates to:
  /// **'Bugun'**
  String get dueToday;

  /// No description provided for @dashboardPaymentsControl.
  ///
  /// In uz, this message translates to:
  /// **'To‘lovlar nazorati'**
  String get dashboardPaymentsControl;

  /// No description provided for @projectStatusInProgress.
  ///
  /// In uz, this message translates to:
  /// **'Jarayonda'**
  String get projectStatusInProgress;

  /// No description provided for @projectStatusFrozen.
  ///
  /// In uz, this message translates to:
  /// **'Muzlatilgan'**
  String get projectStatusFrozen;

  /// No description provided for @projectStatusCompleted.
  ///
  /// In uz, this message translates to:
  /// **'Yakunlangan'**
  String get projectStatusCompleted;

  /// No description provided for @dashboardProjectsCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta loyiha'**
  String dashboardProjectsCount(int count);

  /// No description provided for @dashboardProjectsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Birinchi loyihangizni qo‘shib, ishlarni shu yerda kuzating.'**
  String get dashboardProjectsEmpty;

  /// No description provided for @tutorialOpenError.
  ///
  /// In uz, this message translates to:
  /// **'Qo‘llanmani ochib bo‘lmadi. Keyinroq qayta urinib ko‘ring.'**
  String get tutorialOpenError;

  /// No description provided for @tutorialsCount.
  ///
  /// In uz, this message translates to:
  /// **'Qo‘llanmalar ({count})'**
  String tutorialsCount(int count);

  /// No description provided for @currencySelectTitle.
  ///
  /// In uz, this message translates to:
  /// **'Valyutani tanlang'**
  String get currencySelectTitle;

  /// No description provided for @docCostTypes.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat turlari'**
  String get docCostTypes;

  /// No description provided for @commonAdd.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'shish'**
  String get commonAdd;

  /// No description provided for @docCostTypeNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat turi topilmadi'**
  String get docCostTypeNotFound;

  /// No description provided for @docCostTypeAdd.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat turi qo\'shish'**
  String get docCostTypeAdd;

  /// No description provided for @docWorkerAssigned.
  ///
  /// In uz, this message translates to:
  /// **'Ishchi biriktiriladi'**
  String get docWorkerAssigned;

  /// No description provided for @docSystem.
  ///
  /// In uz, this message translates to:
  /// **'Tizim'**
  String get docSystem;

  /// No description provided for @commonDeleted.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirilgan'**
  String get commonDeleted;

  /// No description provided for @docCostTypeDeleteConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat turi o\'chirilsinmi?'**
  String get docCostTypeDeleteConfirm;

  /// No description provided for @commonIrreversible.
  ///
  /// In uz, this message translates to:
  /// **'Bu amalni keyin qaytarib bo\'lmaydi.'**
  String get commonIrreversible;

  /// No description provided for @docCostTypeEdit.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat turini tahrirlash'**
  String get docCostTypeEdit;

  /// No description provided for @commonName.
  ///
  /// In uz, this message translates to:
  /// **'Nomi'**
  String get commonName;

  /// No description provided for @commonDescriptionOptional.
  ///
  /// In uz, this message translates to:
  /// **'Tavsif (ixtiyoriy)'**
  String get commonDescriptionOptional;

  /// No description provided for @docCurrencyRates.
  ///
  /// In uz, this message translates to:
  /// **'Valyuta kurslari'**
  String get docCurrencyRates;

  /// No description provided for @docRatesLoadError.
  ///
  /// In uz, this message translates to:
  /// **'Kurslarni yuklab bo\'lmadi'**
  String get docRatesLoadError;

  /// No description provided for @docRatesEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Kurslar topilmadi'**
  String get docRatesEmpty;

  /// No description provided for @docConverter.
  ///
  /// In uz, this message translates to:
  /// **'Konvertor'**
  String get docConverter;

  /// No description provided for @docReferenceBooks.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumotnomalar'**
  String get docReferenceBooks;

  /// No description provided for @docWorkTypes.
  ///
  /// In uz, this message translates to:
  /// **'Ish turlari'**
  String get docWorkTypes;

  /// No description provided for @docWorkType.
  ///
  /// In uz, this message translates to:
  /// **'Ish turi'**
  String get docWorkType;

  /// No description provided for @docPositions.
  ///
  /// In uz, this message translates to:
  /// **'Lavozimlar'**
  String get docPositions;

  /// No description provided for @docPosition.
  ///
  /// In uz, this message translates to:
  /// **'Lavozim'**
  String get docPosition;

  /// No description provided for @docWorkers.
  ///
  /// In uz, this message translates to:
  /// **'Ishchilar'**
  String get docWorkers;

  /// No description provided for @docWorkerNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Ishchi topilmadi'**
  String get docWorkerNotFound;

  /// No description provided for @docWorkerAdd.
  ///
  /// In uz, this message translates to:
  /// **'Ishchi qo\'shish'**
  String get docWorkerAdd;

  /// No description provided for @docWorkerDeleteConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Ishchi o\'chirilsinmi?'**
  String get docWorkerDeleteConfirm;

  /// No description provided for @docWorkerEdit.
  ///
  /// In uz, this message translates to:
  /// **'Ishchini tahrirlash'**
  String get docWorkerEdit;

  /// No description provided for @docSelectPosition.
  ///
  /// In uz, this message translates to:
  /// **'Lavozimni tanlang'**
  String get docSelectPosition;

  /// No description provided for @commonNotSelected.
  ///
  /// In uz, this message translates to:
  /// **'Tanlanmagan'**
  String get commonNotSelected;

  /// No description provided for @installmentClosesPartFully.
  ///
  /// In uz, this message translates to:
  /// **'{number}-qismni to\'liq yopadi'**
  String installmentClosesPartFully(Object number);

  /// No description provided for @installmentClosesPartPartially.
  ///
  /// In uz, this message translates to:
  /// **'{number}-qismni qisman yopadi'**
  String installmentClosesPartPartially(Object number);

  /// No description provided for @installmentValidationTotalPositive.
  ///
  /// In uz, this message translates to:
  /// **'Jami summa 0 dan katta bo\'lishi kerak.'**
  String get installmentValidationTotalPositive;

  /// No description provided for @installmentValidationAdvanceLess.
  ///
  /// In uz, this message translates to:
  /// **'Avans summasi jami summadan kichik bo\'lishi kerak.'**
  String get installmentValidationAdvanceLess;

  /// No description provided for @installmentValidationMinPartsWithAdvance.
  ///
  /// In uz, this message translates to:
  /// **'Avans bilan kamida 1 ta qism bo\'lishi kerak.'**
  String get installmentValidationMinPartsWithAdvance;

  /// No description provided for @installmentValidationMinPartsNoAdvance.
  ///
  /// In uz, this message translates to:
  /// **'Avanssiz kamida 2 ta qism bo\'lishi kerak.'**
  String get installmentValidationMinPartsNoAdvance;

  /// No description provided for @installmentValidationStartDatePast.
  ///
  /// In uz, this message translates to:
  /// **'Boshlanish sanasi bugundan kichik bo\'lishi mumkin emas.'**
  String get installmentValidationStartDatePast;

  /// No description provided for @installmentValidationPartPositive.
  ///
  /// In uz, this message translates to:
  /// **'Har bir qism summasi 0 dan katta bo‘lishi kerak.'**
  String get installmentValidationPartPositive;

  /// No description provided for @installmentValidationEnterMinPartsWithAdvance.
  ///
  /// In uz, this message translates to:
  /// **'Avans bilan kamida 1 ta qism kiritilishi kerak.'**
  String get installmentValidationEnterMinPartsWithAdvance;

  /// No description provided for @installmentValidationEnterMinParts.
  ///
  /// In uz, this message translates to:
  /// **'Kamida 2 ta qism kiritilishi kerak.'**
  String get installmentValidationEnterMinParts;

  /// No description provided for @installmentValidationPartsSum.
  ///
  /// In uz, this message translates to:
  /// **'Qismlar yig\'indisi jami summaga teng bo\'lishi kerak.'**
  String get installmentValidationPartsSum;

  /// No description provided for @installmentValidationPaymentDatePast.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov sanasi bugundan kichik bo\'lishi mumkin emas.'**
  String get installmentValidationPaymentDatePast;

  /// No description provided for @fileWaitForUploads.
  ///
  /// In uz, this message translates to:
  /// **'Fayllar yuklanishini kuting.'**
  String get fileWaitForUploads;

  /// No description provided for @installmentCancelPlan.
  ///
  /// In uz, this message translates to:
  /// **'Rejani bekor qilish'**
  String get installmentCancelPlan;

  /// No description provided for @commonPaid.
  ///
  /// In uz, this message translates to:
  /// **'To\'langan'**
  String get commonPaid;

  /// No description provided for @commonRemaining.
  ///
  /// In uz, this message translates to:
  /// **'Qolgan'**
  String get commonRemaining;

  /// No description provided for @installmentSchedule.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov grafigi'**
  String get installmentSchedule;

  /// No description provided for @installmentStagesCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta bosqich'**
  String installmentStagesCount(int count);

  /// No description provided for @installmentReceivePayment.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov qabul qilish'**
  String get installmentReceivePayment;

  /// No description provided for @installmentPaymentHistory.
  ///
  /// In uz, this message translates to:
  /// **'To\'lovlar tarixi'**
  String get installmentPaymentHistory;

  /// No description provided for @installmentCancelPayment.
  ///
  /// In uz, this message translates to:
  /// **'To\'lovni bekor qilish'**
  String get installmentCancelPayment;

  /// No description provided for @errorLoadShort.
  ///
  /// In uz, this message translates to:
  /// **'Yuklab bo\'lmadi'**
  String get errorLoadShort;

  /// No description provided for @installmentNoPayments.
  ///
  /// In uz, this message translates to:
  /// **'To\'lovlar yo\'q'**
  String get installmentNoPayments;

  /// No description provided for @installmentReceivedBy.
  ///
  /// In uz, this message translates to:
  /// **'{name} qabul qildi'**
  String installmentReceivedBy(Object name);

  /// No description provided for @commonCancelled.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilingan'**
  String get commonCancelled;

  /// No description provided for @installmentRemainingColon.
  ///
  /// In uz, this message translates to:
  /// **'Qolgan:'**
  String get installmentRemainingColon;

  /// No description provided for @installmentNextPart.
  ///
  /// In uz, this message translates to:
  /// **'Keyingi qism'**
  String get installmentNextPart;

  /// No description provided for @installmentAllRemaining.
  ///
  /// In uz, this message translates to:
  /// **'Barcha qolgan qarz'**
  String get installmentAllRemaining;

  /// No description provided for @commonNote.
  ///
  /// In uz, this message translates to:
  /// **'Izoh'**
  String get commonNote;

  /// No description provided for @installmentCashHint.
  ///
  /// In uz, this message translates to:
  /// **'Naqd'**
  String get installmentCashHint;

  /// No description provided for @commonDate.
  ///
  /// In uz, this message translates to:
  /// **'Sana'**
  String get commonDate;

  /// No description provided for @installmentThisPayment.
  ///
  /// In uz, this message translates to:
  /// **'Ushbu to\'lov:'**
  String get installmentThisPayment;

  /// No description provided for @installmentAcceptPayment.
  ///
  /// In uz, this message translates to:
  /// **'To\'lovni qabul qilish'**
  String get installmentAcceptPayment;

  /// No description provided for @installmentPaymentExceeds.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov summasi qolgan qarzdan oshib ketmasligi kerak.'**
  String get installmentPaymentExceeds;

  /// No description provided for @installmentPlanCreated.
  ///
  /// In uz, this message translates to:
  /// **'Reja yaratildi'**
  String get installmentPlanCreated;

  /// No description provided for @installmentTitle.
  ///
  /// In uz, this message translates to:
  /// **'Muddatli to‘lov'**
  String get installmentTitle;

  /// No description provided for @installmentStepOf3.
  ///
  /// In uz, this message translates to:
  /// **'{step}-bosqich, jami 3 bosqich'**
  String installmentStepOf3(Object step);

  /// No description provided for @installmentStepSchedule.
  ///
  /// In uz, this message translates to:
  /// **'Grafik turi'**
  String get installmentStepSchedule;

  /// No description provided for @installmentStepDistribution.
  ///
  /// In uz, this message translates to:
  /// **'Taqsimot'**
  String get installmentStepDistribution;

  /// No description provided for @installmentEnterAmount.
  ///
  /// In uz, this message translates to:
  /// **'Summani kiriting'**
  String get installmentEnterAmount;

  /// No description provided for @installmentStep1Title.
  ///
  /// In uz, this message translates to:
  /// **'1-bosqich • Asosiy ma’lumotlar'**
  String get installmentStep1Title;

  /// No description provided for @installmentClient.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz'**
  String get installmentClient;

  /// No description provided for @installmentAmountAndCurrency.
  ///
  /// In uz, this message translates to:
  /// **'Miqdor va valyuta'**
  String get installmentAmountAndCurrency;

  /// No description provided for @installmentCurrencyType.
  ///
  /// In uz, this message translates to:
  /// **'Valyuta turi'**
  String get installmentCurrencyType;

  /// No description provided for @currencyUzs.
  ///
  /// In uz, this message translates to:
  /// **'O‘zbek so‘mi'**
  String get currencyUzs;

  /// No description provided for @currencyUsd.
  ///
  /// In uz, this message translates to:
  /// **'AQSH dollari'**
  String get currencyUsd;

  /// No description provided for @commonNoteOptional.
  ///
  /// In uz, this message translates to:
  /// **'Izoh (ixtiyoriy)'**
  String get commonNoteOptional;

  /// No description provided for @installmentNoteHint.
  ///
  /// In uz, this message translates to:
  /// **'Tafsilotlarni yozishingiz mumkin...'**
  String get installmentNoteHint;

  /// No description provided for @installmentDocumentsOptional.
  ///
  /// In uz, this message translates to:
  /// **'Hujjatlar (ixtiyoriy)'**
  String get installmentDocumentsOptional;

  /// No description provided for @installmentStep2Title.
  ///
  /// In uz, this message translates to:
  /// **'2-bosqich • Grafik turi'**
  String get installmentStep2Title;

  /// No description provided for @installmentEqualSchedule.
  ///
  /// In uz, this message translates to:
  /// **'Teng bo‘lib to‘lash'**
  String get installmentEqualSchedule;

  /// No description provided for @installmentFreeSchedule.
  ///
  /// In uz, this message translates to:
  /// **'Erkin grafik'**
  String get installmentFreeSchedule;

  /// No description provided for @installmentEqualDescription.
  ///
  /// In uz, this message translates to:
  /// **'Boshlanish sanasi va qismlar sonini belgilang. Tizim har bir qism uchun teng summani avtomatik hisoblaydi.'**
  String get installmentEqualDescription;

  /// No description provided for @installmentFreeDescription.
  ///
  /// In uz, this message translates to:
  /// **'Har bir qism uchun summa va sanani alohida belgilang. To‘liq moslashuvchanlik va nazorat.'**
  String get installmentFreeDescription;

  /// No description provided for @installmentStep3Equal.
  ///
  /// In uz, this message translates to:
  /// **'3-bosqich • Teng bo‘lib to‘lash'**
  String get installmentStep3Equal;

  /// No description provided for @installmentStep3Free.
  ///
  /// In uz, this message translates to:
  /// **'3-bosqich • Erkin grafik'**
  String get installmentStep3Free;

  /// No description provided for @installmentDistributionCalc.
  ///
  /// In uz, this message translates to:
  /// **'Taqsimot hisob-kitobi'**
  String get installmentDistributionCalc;

  /// No description provided for @installmentPaymentTable.
  ///
  /// In uz, this message translates to:
  /// **'To‘lov jadvali'**
  String get installmentPaymentTable;

  /// No description provided for @installmentReviewPlan.
  ///
  /// In uz, this message translates to:
  /// **'Rejani tekshiring'**
  String get installmentReviewPlan;

  /// No description provided for @installmentTotalLine.
  ///
  /// In uz, this message translates to:
  /// **'Jami: {amount} {currency}\n'**
  String installmentTotalLine(Object amount, Object currency);

  /// No description provided for @installmentPerPartFormula.
  ///
  /// In uz, this message translates to:
  /// **'{amount} {currency} ÷ {count} qism'**
  String installmentPerPartFormula(
    Object amount,
    Object currency,
    Object count,
  );

  /// No description provided for @installmentAdvance.
  ///
  /// In uz, this message translates to:
  /// **'Boshlang‘ich to‘lov'**
  String get installmentAdvance;

  /// No description provided for @installmentSetAdvance.
  ///
  /// In uz, this message translates to:
  /// **'Avans miqdorini belgilash'**
  String get installmentSetAdvance;

  /// No description provided for @installmentFirstPartDate.
  ///
  /// In uz, this message translates to:
  /// **'Birinchi qism sanasi'**
  String get installmentFirstPartDate;

  /// No description provided for @installmentFirstPaymentDate.
  ///
  /// In uz, this message translates to:
  /// **'Birinchi to‘lov sanasi'**
  String get installmentFirstPaymentDate;

  /// No description provided for @installmentRemainingParts.
  ///
  /// In uz, this message translates to:
  /// **'Qolgan qismlar'**
  String get installmentRemainingParts;

  /// No description provided for @installmentPartsCount.
  ///
  /// In uz, this message translates to:
  /// **'Qismlar soni'**
  String get installmentPartsCount;

  /// No description provided for @commonCountShort.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta'**
  String commonCountShort(Object count);

  /// No description provided for @installmentFullyDistributed.
  ///
  /// In uz, this message translates to:
  /// **'To‘liq taqsimlandi'**
  String get installmentFullyDistributed;

  /// No description provided for @installmentAmountExceeded.
  ///
  /// In uz, this message translates to:
  /// **'Summa oshib ketdi'**
  String get installmentAmountExceeded;

  /// No description provided for @installmentDistributionLeft.
  ///
  /// In uz, this message translates to:
  /// **'Taqsimot qoldi'**
  String get installmentDistributionLeft;

  /// No description provided for @installmentPlannedTotal.
  ///
  /// In uz, this message translates to:
  /// **'Jami {amount} {currency} rejalashtirildi.'**
  String installmentPlannedTotal(Object amount, Object currency);

  /// No description provided for @installmentReduceBy.
  ///
  /// In uz, this message translates to:
  /// **'{amount} {currency} ga kamaytiring.'**
  String installmentReduceBy(Object amount, Object currency);

  /// No description provided for @installmentRemainingDistribute.
  ///
  /// In uz, this message translates to:
  /// **'Qolgan: {amount} {currency}. Barcha summani taqsimlang.'**
  String installmentRemainingDistribute(Object amount, Object currency);

  /// No description provided for @installmentAddPart.
  ///
  /// In uz, this message translates to:
  /// **'Yangi qism qo‘shish'**
  String get installmentAddPart;

  /// No description provided for @installmentStatusActive.
  ///
  /// In uz, this message translates to:
  /// **'Faol'**
  String get installmentStatusActive;

  /// No description provided for @installmentStatusClosed.
  ///
  /// In uz, this message translates to:
  /// **'Yopilgan'**
  String get installmentStatusClosed;

  /// No description provided for @installmentPartsCountShort.
  ///
  /// In uz, this message translates to:
  /// **'{count} qism'**
  String installmentPartsCountShort(int count);

  /// No description provided for @installmentAdvanceAmount.
  ///
  /// In uz, this message translates to:
  /// **'Avans summasi'**
  String get installmentAdvanceAmount;

  /// No description provided for @installmentPartAmount.
  ///
  /// In uz, this message translates to:
  /// **'{number}-qism summasi'**
  String installmentPartAmount(Object number);

  /// No description provided for @installmentPaymentDate.
  ///
  /// In uz, this message translates to:
  /// **'To‘lov sanasi'**
  String get installmentPaymentDate;

  /// No description provided for @installmentRemovePart.
  ///
  /// In uz, this message translates to:
  /// **'Qismni olib tashlash'**
  String get installmentRemovePart;

  /// No description provided for @installmentNoPlans.
  ///
  /// In uz, this message translates to:
  /// **'Bo\'lib to\'lash rejasi yo\'q'**
  String get installmentNoPlans;

  /// No description provided for @installmentNoPlansDescription.
  ///
  /// In uz, this message translates to:
  /// **'Katta summani qismlarga bo\'lib to\'lash uchun reja yarating.'**
  String get installmentNoPlansDescription;

  /// No description provided for @installmentCreatePlan.
  ///
  /// In uz, this message translates to:
  /// **'Reja yaratish'**
  String get installmentCreatePlan;

  /// No description provided for @installmentCreatePlanPlus.
  ///
  /// In uz, this message translates to:
  /// **'+ Reja yaratish'**
  String get installmentCreatePlanPlus;

  /// No description provided for @commonExcelShort.
  ///
  /// In uz, this message translates to:
  /// **'Excel'**
  String get commonExcelShort;

  /// No description provided for @partnerSmsSettingShort.
  ///
  /// In uz, this message translates to:
  /// **'SMS sozlama'**
  String get partnerSmsSettingShort;

  /// No description provided for @partnerAccountUzs.
  ///
  /// In uz, this message translates to:
  /// **'O‘zbek so‘mi hisobi'**
  String get partnerAccountUzs;

  /// No description provided for @partnerAccountUsd.
  ///
  /// In uz, this message translates to:
  /// **'AQSH dollari hisobi'**
  String get partnerAccountUsd;

  /// No description provided for @commonFilterByDate.
  ///
  /// In uz, this message translates to:
  /// **'Sana bo‘yicha filtr'**
  String get commonFilterByDate;

  /// No description provided for @commonDeletedToast.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirildi'**
  String get commonDeletedToast;

  /// No description provided for @partnerNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi hamkor'**
  String get partnerNew;

  /// No description provided for @partnerUpdateData.
  ///
  /// In uz, this message translates to:
  /// **'Ma’lumotlarni yangilash'**
  String get partnerUpdateData;

  /// No description provided for @partnerEnterData.
  ///
  /// In uz, this message translates to:
  /// **'Hamkor ma’lumotlarini kiriting'**
  String get partnerEnterData;

  /// No description provided for @partnerNameHint.
  ///
  /// In uz, this message translates to:
  /// **'Hamkorning ismi yoki tashkilot nomi'**
  String get partnerNameHint;

  /// No description provided for @commonOptional.
  ///
  /// In uz, this message translates to:
  /// **'Ixtiyoriy'**
  String get commonOptional;

  /// No description provided for @commonSaveChanges.
  ///
  /// In uz, this message translates to:
  /// **'O‘zgarishlarni saqlash'**
  String get commonSaveChanges;

  /// No description provided for @partnersAddButton.
  ///
  /// In uz, this message translates to:
  /// **'Hamkorni qo‘shish'**
  String get partnersAddButton;

  /// No description provided for @fileWaitThenSave.
  ///
  /// In uz, this message translates to:
  /// **'Fayl yuklanishini kuting, keyin saqlang.'**
  String get fileWaitThenSave;

  /// No description provided for @partnerLimitReached.
  ///
  /// In uz, this message translates to:
  /// **'Limit tugagan'**
  String get partnerLimitReached;

  /// No description provided for @commonViewPlans.
  ///
  /// In uz, this message translates to:
  /// **'Tariflarni ko\'rish'**
  String get commonViewPlans;

  /// No description provided for @partnerSmsSettingsLoadError.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalarni yuklab bo\'lmadi'**
  String get partnerSmsSettingsLoadError;

  /// No description provided for @partnerSmsService.
  ///
  /// In uz, this message translates to:
  /// **'SMS xizmati'**
  String get partnerSmsService;

  /// No description provided for @partnerSmsOnIncome.
  ///
  /// In uz, this message translates to:
  /// **'Kirim qilinganda SMS'**
  String get partnerSmsOnIncome;

  /// No description provided for @partnerSmsOnExpense.
  ///
  /// In uz, this message translates to:
  /// **'Chiqim qilinganda SMS'**
  String get partnerSmsOnExpense;

  /// No description provided for @partnerSmsRemindBefore.
  ///
  /// In uz, this message translates to:
  /// **'Muddatdan oldin eslatish'**
  String get partnerSmsRemindBefore;

  /// No description provided for @commonDaysCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} kun'**
  String commonDaysCount(int count);

  /// No description provided for @partnerSmsRemindOnDue.
  ///
  /// In uz, this message translates to:
  /// **'Muddat kunida eslatish'**
  String get partnerSmsRemindOnDue;

  /// No description provided for @partnerSmsAfterDue.
  ///
  /// In uz, this message translates to:
  /// **'Muddatdan keyin'**
  String get partnerSmsAfterDue;

  /// No description provided for @partnerSmsSendTime.
  ///
  /// In uz, this message translates to:
  /// **'SMS yuborish vaqti'**
  String get partnerSmsSendTime;

  /// No description provided for @partnersClientsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mijozlar'**
  String get partnersClientsTitle;

  /// No description provided for @partnersClientsSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Mijozlaringiz va hisob-kitoblar'**
  String get partnersClientsSubtitle;

  /// No description provided for @partnersAddClient.
  ///
  /// In uz, this message translates to:
  /// **'Yangi mijoz qo‘shish'**
  String get partnersAddClient;

  /// No description provided for @partnersSearchNamePhone.
  ///
  /// In uz, this message translates to:
  /// **'Ism yoki telefon'**
  String get partnersSearchNamePhone;

  /// No description provided for @partnersExportExcel.
  ///
  /// In uz, this message translates to:
  /// **'Excel hisobotni yuklab olish'**
  String get partnersExportExcel;

  /// No description provided for @partnersSortTooltip.
  ///
  /// In uz, this message translates to:
  /// **'Saralash: {sort}'**
  String partnersSortTooltip(Object sort);

  /// No description provided for @partnersClientsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Mijozlar topilmadi'**
  String get partnersClientsEmpty;

  /// No description provided for @partnersEmptyFiltered.
  ///
  /// In uz, this message translates to:
  /// **'Qidiruvni yoki tanlangan filtrni o‘zgartirib ko‘ring.'**
  String get partnersEmptyFiltered;

  /// No description provided for @partnersEmptyStart.
  ///
  /// In uz, this message translates to:
  /// **'Hamkor qo‘shib, hisob-kitoblarni yuritishni boshlang.'**
  String get partnersEmptyStart;

  /// No description provided for @partnersSortDebtorUzsDot.
  ///
  /// In uz, this message translates to:
  /// **'Qarzdor · UZS'**
  String get partnersSortDebtorUzsDot;

  /// No description provided for @partnersSortDebtorUsdDot.
  ///
  /// In uz, this message translates to:
  /// **'Qarzdor · USD'**
  String get partnersSortDebtorUsdDot;

  /// No description provided for @partnersSortCreditorUzsDot.
  ///
  /// In uz, this message translates to:
  /// **'Haqdor · UZS'**
  String get partnersSortCreditorUzsDot;

  /// No description provided for @partnersSortCreditorUsdDot.
  ///
  /// In uz, this message translates to:
  /// **'Haqdor · USD'**
  String get partnersSortCreditorUsdDot;

  /// No description provided for @walletEditExpense.
  ///
  /// In uz, this message translates to:
  /// **'Chiqimni tahrirlash'**
  String get walletEditExpense;

  /// No description provided for @walletAdditionalInfo.
  ///
  /// In uz, this message translates to:
  /// **'Qo‘shimcha ma’lumot'**
  String get walletAdditionalInfo;

  /// No description provided for @walletNoteHint.
  ///
  /// In uz, this message translates to:
  /// **'To‘lov haqida qisqacha'**
  String get walletNoteHint;

  /// No description provided for @walletRemoveDate.
  ///
  /// In uz, this message translates to:
  /// **'Sanani olib tashlash'**
  String get walletRemoveDate;

  /// No description provided for @commonSaving.
  ///
  /// In uz, this message translates to:
  /// **'Saqlanmoqda…'**
  String get commonSaving;

  /// No description provided for @exportPreparing.
  ///
  /// In uz, this message translates to:
  /// **'Fayl tayyorlanmoqda...'**
  String get exportPreparing;

  /// No description provided for @exportPleaseWait.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, kuting'**
  String get exportPleaseWait;

  /// No description provided for @exportShareError.
  ///
  /// In uz, this message translates to:
  /// **'Faylni ulashishda xatolik yuz berdi'**
  String get exportShareError;

  /// No description provided for @exportDownloadError.
  ///
  /// In uz, this message translates to:
  /// **'Yuklab olishda xatolik yuz berdi'**
  String get exportDownloadError;

  /// No description provided for @partnersClosedShort.
  ///
  /// In uz, this message translates to:
  /// **'Yopiq'**
  String get partnersClosedShort;

  /// No description provided for @partnerInstallmentPrefix.
  ///
  /// In uz, this message translates to:
  /// **'Bo\'lib to\'lash: '**
  String get partnerInstallmentPrefix;

  /// No description provided for @partnersClientActions.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz amallari'**
  String get partnersClientActions;

  /// No description provided for @commonCallAction.
  ///
  /// In uz, this message translates to:
  /// **'Qo‘ng‘iroq qilish'**
  String get commonCallAction;

  /// No description provided for @commonWriteSms.
  ///
  /// In uz, this message translates to:
  /// **'SMS yozish'**
  String get commonWriteSms;

  /// No description provided for @commonOpenDetails.
  ///
  /// In uz, this message translates to:
  /// **'Tafsilotlarni ochish'**
  String get commonOpenDetails;

  /// No description provided for @commonPhoneAppError.
  ///
  /// In uz, this message translates to:
  /// **'Telefon ilovasini ochib bo‘lmadi'**
  String get commonPhoneAppError;

  /// No description provided for @partnersClientsLoading.
  ///
  /// In uz, this message translates to:
  /// **'Mijozlar yuklanmoqda'**
  String get partnersClientsLoading;

  /// No description provided for @partnersSelect.
  ///
  /// In uz, this message translates to:
  /// **'Hamkorni tanlang'**
  String get partnersSelect;

  /// No description provided for @partnersSearchByNamePhone.
  ///
  /// In uz, this message translates to:
  /// **'Ism yoki telefon orqali qidirish'**
  String get partnersSearchByNamePhone;

  /// No description provided for @partnersSearchChange.
  ///
  /// In uz, this message translates to:
  /// **'Ism yoki telefonni o‘zgartirib qidiring.'**
  String get partnersSearchChange;

  /// No description provided for @partnersLoading.
  ///
  /// In uz, this message translates to:
  /// **'Hamkorlar yuklanmoqda'**
  String get partnersLoading;

  /// No description provided for @partnerSmsHistoryEmpty.
  ///
  /// In uz, this message translates to:
  /// **'SMS tarixi bo\'sh'**
  String get partnerSmsHistoryEmpty;

  /// No description provided for @walletReasonClientRejected.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz to\'lovni rad etdi'**
  String get walletReasonClientRejected;

  /// No description provided for @walletReasonWrongAmount.
  ///
  /// In uz, this message translates to:
  /// **'Summa noto\'g\'ri ko\'rsatilgan'**
  String get walletReasonWrongAmount;

  /// No description provided for @walletReasonDuplicate.
  ///
  /// In uz, this message translates to:
  /// **'Takroriy (dublikat) yozuv'**
  String get walletReasonDuplicate;

  /// No description provided for @walletCancelRecalc.
  ///
  /// In uz, this message translates to:
  /// **'Ushbu amal hamkor balansini qayta hisoblaydi'**
  String get walletCancelRecalc;

  /// No description provided for @walletQuickReason.
  ///
  /// In uz, this message translates to:
  /// **'Tezkor sababni tanlang:'**
  String get walletQuickReason;

  /// No description provided for @walletReasonOrNote.
  ///
  /// In uz, this message translates to:
  /// **'Izoh yoki aniq sabab:'**
  String get walletReasonOrNote;

  /// No description provided for @walletCancelReasonHintLong.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish sababini yozing (kamida 3 belgi)...'**
  String get walletCancelReasonHintLong;

  /// No description provided for @walletReasonMin3.
  ///
  /// In uz, this message translates to:
  /// **'Kamida 3 ta belgi talab qilinadi'**
  String get walletReasonMin3;

  /// No description provided for @walletReasonMoreChars.
  ///
  /// In uz, this message translates to:
  /// **'Yana {count} ta belgi kiriting'**
  String walletReasonMoreChars(int count);

  /// No description provided for @walletReasonEnough.
  ///
  /// In uz, this message translates to:
  /// **'✓ Sabab yetarli'**
  String get walletReasonEnough;

  /// No description provided for @walletDeleteTransaction.
  ///
  /// In uz, this message translates to:
  /// **'Tranzaksiyani o\'chirish'**
  String get walletDeleteTransaction;

  /// No description provided for @walletDeleteConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Rostdan ham ushbu tranzaksiyani butunlay o\'chirib tashlamoqchimisiz?'**
  String get walletDeleteConfirm;

  /// No description provided for @walletDeleteWarning.
  ///
  /// In uz, this message translates to:
  /// **'Bu amal hisob-kitob balansini o\'zgartiradi va uni ortga qaytarib bo\'lmaydi.'**
  String get walletDeleteWarning;

  /// No description provided for @walletDeleteYes.
  ///
  /// In uz, this message translates to:
  /// **'Ha, o\'chirilsin'**
  String get walletDeleteYes;

  /// No description provided for @walletDeleteNo.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'q, bekor qilish'**
  String get walletDeleteNo;

  /// No description provided for @dateFilterTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sana bo\'yicha saralash'**
  String get dateFilterTitle;

  /// No description provided for @dateFilterSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Tranzaksiyalar vaqt oralig\'ini tanlang'**
  String get dateFilterSubtitle;

  /// No description provided for @dateFilterAll.
  ///
  /// In uz, this message translates to:
  /// **'Barcha vaqt (filterni tozalash)'**
  String get dateFilterAll;

  /// No description provided for @dateFilterAllSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Cheklovlarsiz barcha tranzaksiyalar'**
  String get dateFilterAllSubtitle;

  /// No description provided for @dateFilterThisMonth.
  ///
  /// In uz, this message translates to:
  /// **'Bu oy'**
  String get dateFilterThisMonth;

  /// No description provided for @dateFilterLast7.
  ///
  /// In uz, this message translates to:
  /// **'Oxirgi 7 kun'**
  String get dateFilterLast7;

  /// No description provided for @dateFilterLastMonth.
  ///
  /// In uz, this message translates to:
  /// **'O\'tgan oy'**
  String get dateFilterLastMonth;

  /// No description provided for @dateFilterLast30.
  ///
  /// In uz, this message translates to:
  /// **'Oxirgi 30 kun'**
  String get dateFilterLast30;

  /// No description provided for @dateFilterCustom.
  ///
  /// In uz, this message translates to:
  /// **'Ixtiyoriy sana oralig\'i...'**
  String get dateFilterCustom;

  /// No description provided for @dateFilterCustomSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Kalendardan kerakli oraliqni tanlash'**
  String get dateFilterCustomSubtitle;

  /// No description provided for @receiptShareTitle.
  ///
  /// In uz, this message translates to:
  /// **'🧾 ELEKTRON TO\'LOV KVITANSIYASI — Hisup'**
  String get receiptShareTitle;

  /// No description provided for @receiptShareAmount.
  ///
  /// In uz, this message translates to:
  /// **'Summa: {sign}{amount}'**
  String receiptShareAmount(Object sign, Object amount);

  /// No description provided for @receiptCommission.
  ///
  /// In uz, this message translates to:
  /// **'Komissiya: 0 {currency} (0%)'**
  String receiptCommission(Object currency);

  /// No description provided for @receiptSharePartner.
  ///
  /// In uz, this message translates to:
  /// **'Hamkor: {name}'**
  String receiptSharePartner(Object name);

  /// No description provided for @receiptSharePhone.
  ///
  /// In uz, this message translates to:
  /// **'Telefon: {phone}'**
  String receiptSharePhone(Object phone);

  /// No description provided for @receiptShareDateTime.
  ///
  /// In uz, this message translates to:
  /// **'Sana va vaqt: {date}'**
  String receiptShareDateTime(Object date);

  /// No description provided for @receiptShareCashier.
  ///
  /// In uz, this message translates to:
  /// **'Kassir / Mas\'ul xodim: {name}'**
  String receiptShareCashier(Object name);

  /// No description provided for @receiptSharePurpose.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov maqsadi: {text}'**
  String receiptSharePurpose(Object text);

  /// No description provided for @receiptShareReturnDate.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarish muddati: {date}'**
  String receiptShareReturnDate(Object date);

  /// No description provided for @receiptShareCancelReason.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish sababi: {text}'**
  String receiptShareCancelReason(Object text);

  /// No description provided for @receiptShareFooter.
  ///
  /// In uz, this message translates to:
  /// **'Hisup rasmiy bank standarti to\'lov hujjati'**
  String get receiptShareFooter;

  /// No description provided for @receiptShareError.
  ///
  /// In uz, this message translates to:
  /// **'Chekni ulashib bo‘lmadi. Qayta urinib ko‘ring.'**
  String get receiptShareError;

  /// No description provided for @receiptCopied.
  ///
  /// In uz, this message translates to:
  /// **'Chek ma\'lumotlari to\'liq nusxalandi'**
  String get receiptCopied;

  /// No description provided for @receiptTitle.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov cheki'**
  String get receiptTitle;

  /// No description provided for @receiptBadge.
  ///
  /// In uz, this message translates to:
  /// **'ELEKTRON KVITANSIYA'**
  String get receiptBadge;

  /// No description provided for @receiptCancelled.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov bekor qilingan'**
  String get receiptCancelled;

  /// No description provided for @receiptPaidOut.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov muvaffaqiyatli o\'tkazildi'**
  String get receiptPaidOut;

  /// No description provided for @receiptReceived.
  ///
  /// In uz, this message translates to:
  /// **'Mablag\' muvaffaqiyatli qabul qilindi'**
  String get receiptReceived;

  /// No description provided for @receiptRecipient.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qiluvchi (Hamkor)'**
  String get receiptRecipient;

  /// No description provided for @receiptOperationType.
  ///
  /// In uz, this message translates to:
  /// **'Operatsiya turi'**
  String get receiptOperationType;

  /// No description provided for @receiptExpenseType.
  ///
  /// In uz, this message translates to:
  /// **'Chiqim (To\'lov)'**
  String get receiptExpenseType;

  /// No description provided for @receiptIncomeType.
  ///
  /// In uz, this message translates to:
  /// **'Kirim (Tushum)'**
  String get receiptIncomeType;

  /// No description provided for @receiptDateTime.
  ///
  /// In uz, this message translates to:
  /// **'Sana va vaqt'**
  String get receiptDateTime;

  /// No description provided for @receiptTransactionId.
  ///
  /// In uz, this message translates to:
  /// **'Tranzaksiya ID (RRN)'**
  String get receiptTransactionId;

  /// No description provided for @receiptIdCopied.
  ///
  /// In uz, this message translates to:
  /// **'ID nusxalandi'**
  String get receiptIdCopied;

  /// No description provided for @receiptAccountCurrency.
  ///
  /// In uz, this message translates to:
  /// **'Hisob valyutasi'**
  String get receiptAccountCurrency;

  /// No description provided for @currencyUsdFull.
  ///
  /// In uz, this message translates to:
  /// **'AQSH Dollari (USD)'**
  String get currencyUsdFull;

  /// No description provided for @currencyUzsFull.
  ///
  /// In uz, this message translates to:
  /// **'O\'zbek so\'mi (UZS)'**
  String get currencyUzsFull;

  /// No description provided for @receiptCashier.
  ///
  /// In uz, this message translates to:
  /// **'Kassir / Mas\'ul xodim'**
  String get receiptCashier;

  /// No description provided for @receiptReturnDate.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarish muddati'**
  String get receiptReturnDate;

  /// No description provided for @receiptPurpose.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov maqsadi (Izoh)'**
  String get receiptPurpose;

  /// No description provided for @receiptCancelledPayment.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilingan to\'lov'**
  String get receiptCancelledPayment;

  /// No description provided for @receiptConfirmed.
  ///
  /// In uz, this message translates to:
  /// **'Muvaffaqiyatli tasdiqlangan'**
  String get receiptConfirmed;

  /// No description provided for @receiptRegistered.
  ///
  /// In uz, this message translates to:
  /// **'Hisup moliyaviy hisobot tizimida qayd etilgan'**
  String get receiptRegistered;

  /// No description provided for @receiptShare.
  ///
  /// In uz, this message translates to:
  /// **'Chekni ulashish'**
  String get receiptShare;

  /// No description provided for @walletReturnShort.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarish: {date}'**
  String walletReturnShort(Object date);

  /// No description provided for @walletEnteredBy.
  ///
  /// In uz, this message translates to:
  /// **'{name} kiritdi'**
  String walletEnteredBy(Object name);

  /// No description provided for @profileSaveName.
  ///
  /// In uz, this message translates to:
  /// **'Ismni saqlash'**
  String get profileSaveName;

  /// No description provided for @profileChangePassword.
  ///
  /// In uz, this message translates to:
  /// **'Parolni o\'zgartirish'**
  String get profileChangePassword;

  /// No description provided for @profileChangePhone.
  ///
  /// In uz, this message translates to:
  /// **'Telefonni o\'zgartirish'**
  String get profileChangePhone;

  /// No description provided for @profileOldPassword.
  ///
  /// In uz, this message translates to:
  /// **'Eski parol'**
  String get profileOldPassword;

  /// No description provided for @profileNewPhoneTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi telefon raqam'**
  String get profileNewPhoneTitle;

  /// No description provided for @profileNewPhone.
  ///
  /// In uz, this message translates to:
  /// **'Yangi telefon'**
  String get profileNewPhone;

  /// No description provided for @profilePhoneUpdated.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqam yangilandi'**
  String get profilePhoneUpdated;

  /// No description provided for @profileVerificationCode.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash kodi'**
  String get profileVerificationCode;

  /// No description provided for @profileOpenOwnAccount.
  ///
  /// In uz, this message translates to:
  /// **'O\'z hisobimni ochish'**
  String get profileOpenOwnAccount;

  /// No description provided for @profileSecurityPin.
  ///
  /// In uz, this message translates to:
  /// **'Xavfsizlik va PIN-kod'**
  String get profileSecurityPin;

  /// No description provided for @profileSecurityPinSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'PIN-kodni yoqish yoki o\'chirish'**
  String get profileSecurityPinSubtitle;

  /// No description provided for @profileOpenOwnAccountConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Sizga FREE tarif bilan o\'z biznes hisobingiz ochiladi. Davom etasizmi?'**
  String get profileOpenOwnAccountConfirm;

  /// No description provided for @profileOpenOwnAccountYes.
  ///
  /// In uz, this message translates to:
  /// **'Ha, ochish'**
  String get profileOpenOwnAccountYes;

  /// No description provided for @profileOwnAccountOpened.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingiz ochildi'**
  String get profileOwnAccountOpened;

  /// No description provided for @authLogoutYes.
  ///
  /// In uz, this message translates to:
  /// **'Ha, chiqish'**
  String get authLogoutYes;

  /// No description provided for @profileRoleOwner.
  ///
  /// In uz, this message translates to:
  /// **'Egasi'**
  String get profileRoleOwner;

  /// No description provided for @profileRoleStaff.
  ///
  /// In uz, this message translates to:
  /// **'Xodim'**
  String get profileRoleStaff;

  /// No description provided for @profileVersion.
  ///
  /// In uz, this message translates to:
  /// **'Versiya {version}'**
  String profileVersion(Object version);

  /// No description provided for @settingsPinEnabled.
  ///
  /// In uz, this message translates to:
  /// **'PIN-kod muvaffaqiyatli yoqildi'**
  String get settingsPinEnabled;

  /// No description provided for @settingsPinDisabled.
  ///
  /// In uz, this message translates to:
  /// **'PIN-kod o\'chirildi'**
  String get settingsPinDisabled;

  /// No description provided for @settingsPinUpdated.
  ///
  /// In uz, this message translates to:
  /// **'PIN-kod muvaffaqiyatli yangilandi'**
  String get settingsPinUpdated;

  /// No description provided for @settingsPinDisableTitle.
  ///
  /// In uz, this message translates to:
  /// **'PIN-kodni o\'chirish'**
  String get settingsPinDisableTitle;

  /// No description provided for @settingsPinDisableBody.
  ///
  /// In uz, this message translates to:
  /// **'Ilovaga kirishda PIN-kod va biometriya so\'ralmaydi. Hisobingiz xavfsizligi kamayishi mumkin.\n\nRostdan ham o\'chirmoqchimisiz?'**
  String get settingsPinDisableBody;

  /// No description provided for @settingsPinDisableYes.
  ///
  /// In uz, this message translates to:
  /// **'Ha, o\'chirilsin'**
  String get settingsPinDisableYes;

  /// No description provided for @settingsPinProtect.
  ///
  /// In uz, this message translates to:
  /// **'PIN-kod bilan himoyalash'**
  String get settingsPinProtect;

  /// No description provided for @settingsPinOnSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Ilovaga kirishda PIN-kod va biometriya so\'raladi'**
  String get settingsPinOnSubtitle;

  /// No description provided for @settingsPinOffSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Ilovaga kirishda PIN-kod so\'ralmaydi'**
  String get settingsPinOffSubtitle;

  /// No description provided for @settingsPinChange.
  ///
  /// In uz, this message translates to:
  /// **'PIN-kodni o\'zgartirish'**
  String get settingsPinChange;

  /// No description provided for @settingsPinChangeSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi 4 xonali kod o\'rnatish'**
  String get settingsPinChangeSubtitle;

  /// No description provided for @settingsDangerZone.
  ///
  /// In uz, this message translates to:
  /// **'XAVFLI HUDUD'**
  String get settingsDangerZone;

  /// No description provided for @authDeleteAccountConfirmBody.
  ///
  /// In uz, this message translates to:
  /// **'Barcha hamkorlar, tranzaksiyalar, loyihalar va hisobotlar butunlay o\'chiriladi. Bu amalni qaytarib bo\'lmaydi. Rostdan ham hisobingizni o\'chirmoqchimisiz?'**
  String get authDeleteAccountConfirmBody;

  /// No description provided for @commonYesDelete.
  ///
  /// In uz, this message translates to:
  /// **'Ha, o\'chirish'**
  String get commonYesDelete;

  /// No description provided for @authAccountDeleted.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingiz muvaffaqiyatli o\'chirildi'**
  String get authAccountDeleted;

  /// No description provided for @subscriptionLoadError.
  ///
  /// In uz, this message translates to:
  /// **'Tarif ma’lumotlarini yuklab bo‘lmadi'**
  String get subscriptionLoadError;

  /// No description provided for @subscriptionCurrentBadge.
  ///
  /// In uz, this message translates to:
  /// **'JORIY TARIF'**
  String get subscriptionCurrentBadge;

  /// No description provided for @subscriptionTitle.
  ///
  /// In uz, this message translates to:
  /// **'Obuna'**
  String get subscriptionTitle;

  /// No description provided for @subscriptionNone.
  ///
  /// In uz, this message translates to:
  /// **'Obuna mavjud emas'**
  String get subscriptionNone;

  /// No description provided for @subscriptionOverdue.
  ///
  /// In uz, this message translates to:
  /// **'To‘lov muddati o‘tgan'**
  String get subscriptionOverdue;

  /// No description provided for @subscriptionDaysLeft.
  ///
  /// In uz, this message translates to:
  /// **'{count} kun qoldi'**
  String subscriptionDaysLeft(int count);

  /// No description provided for @subscriptionValidUntil.
  ///
  /// In uz, this message translates to:
  /// **'Amal qilish muddati: {date}'**
  String subscriptionValidUntil(Object date);

  /// No description provided for @subscriptionLimitsUsage.
  ///
  /// In uz, this message translates to:
  /// **'Limitlar va foydalanish'**
  String get subscriptionLimitsUsage;

  /// No description provided for @staffMinOnePermission.
  ///
  /// In uz, this message translates to:
  /// **'Kamida 1 ta ruxsat tanlanishi kerak'**
  String get staffMinOnePermission;

  /// No description provided for @staffAdd.
  ///
  /// In uz, this message translates to:
  /// **'Xodim qo\'shish'**
  String get staffAdd;

  /// No description provided for @staffAdded.
  ///
  /// In uz, this message translates to:
  /// **'Xodim qo\'shildi'**
  String get staffAdded;

  /// No description provided for @staffStepSms.
  ///
  /// In uz, this message translates to:
  /// **'SMS Kod'**
  String get staffStepSms;

  /// No description provided for @staffPhone.
  ///
  /// In uz, this message translates to:
  /// **'Xodim telefoni'**
  String get staffPhone;

  /// No description provided for @staffPermissions.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsatlar'**
  String get staffPermissions;

  /// No description provided for @staffUpdatePermissions.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsatlarni yangilash'**
  String get staffUpdatePermissions;

  /// No description provided for @staffUpdatePermissionsWarning.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsat o\'zgartirilganda xodimning barcha tokenlari o\'chiriladi va u qayta login qilishi kerak bo\'ladi.'**
  String get staffUpdatePermissionsWarning;

  /// No description provided for @staffEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Xodimlar yo\'q'**
  String get staffEmpty;

  /// No description provided for @staffPermissionsCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta ruxsat'**
  String staffPermissionsCount(int count);

  /// No description provided for @staffDeleteConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Xodim o\'chirilsinmi?'**
  String get staffDeleteConfirm;

  /// No description provided for @commonSelectAll.
  ///
  /// In uz, this message translates to:
  /// **'Barchasini tanlash'**
  String get commonSelectAll;

  /// No description provided for @staffPermissionsLoading.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsatlar ro\'yxati yuklanmoqda...'**
  String get staffPermissionsLoading;

  /// No description provided for @commonUnlimited.
  ///
  /// In uz, this message translates to:
  /// **'Cheksiz'**
  String get commonUnlimited;

  /// No description provided for @billingMonthly.
  ///
  /// In uz, this message translates to:
  /// **'Oylik'**
  String get billingMonthly;

  /// No description provided for @billingSemiAnnual.
  ///
  /// In uz, this message translates to:
  /// **'6 oylik'**
  String get billingSemiAnnual;

  /// No description provided for @billingAnnual.
  ///
  /// In uz, this message translates to:
  /// **'Yillik'**
  String get billingAnnual;

  /// No description provided for @subscriptionNoActive.
  ///
  /// In uz, this message translates to:
  /// **'Faol obuna topilmadi'**
  String get subscriptionNoActive;

  /// No description provided for @subscriptionCurrentPlan.
  ///
  /// In uz, this message translates to:
  /// **'Joriy tarif'**
  String get subscriptionCurrentPlan;

  /// No description provided for @subscriptionNoExpiry.
  ///
  /// In uz, this message translates to:
  /// **'Muddati belgilanmagan'**
  String get subscriptionNoExpiry;

  /// No description provided for @subscriptionSmsNotifications.
  ///
  /// In uz, this message translates to:
  /// **'SMS xabarnomalar'**
  String get subscriptionSmsNotifications;

  /// No description provided for @subscriptionYourCurrentPlan.
  ///
  /// In uz, this message translates to:
  /// **'Joriy tarifingiz'**
  String get subscriptionYourCurrentPlan;

  /// No description provided for @planFeaturePartners.
  ///
  /// In uz, this message translates to:
  /// **'{value} Hamkor'**
  String planFeaturePartners(Object value);

  /// No description provided for @planFeatureProjects.
  ///
  /// In uz, this message translates to:
  /// **'{value} Loyiha'**
  String planFeatureProjects(Object value);

  /// No description provided for @planFeatureStaff.
  ///
  /// In uz, this message translates to:
  /// **'{value} Xodim'**
  String planFeatureStaff(Object value);

  /// No description provided for @planFeatureSms.
  ///
  /// In uz, this message translates to:
  /// **'{value} SMS'**
  String planFeatureSms(Object value);

  /// No description provided for @billingMonthlySubscription.
  ///
  /// In uz, this message translates to:
  /// **'Oylik obuna'**
  String get billingMonthlySubscription;

  /// No description provided for @billingSemiAnnualSubscription.
  ///
  /// In uz, this message translates to:
  /// **'6 oylik obuna'**
  String get billingSemiAnnualSubscription;

  /// No description provided for @billingAnnualSubscription.
  ///
  /// In uz, this message translates to:
  /// **'Yillik obuna'**
  String get billingAnnualSubscription;

  /// No description provided for @planNamed.
  ///
  /// In uz, this message translates to:
  /// **'{name} tarifi'**
  String planNamed(Object name);

  /// No description provided for @subscriptionActivated.
  ///
  /// In uz, this message translates to:
  /// **'Obuna faollashtirildi'**
  String get subscriptionActivated;

  /// No description provided for @smsPackagesDescription.
  ///
  /// In uz, this message translates to:
  /// **'Mijozlaringizga hisob-kitoblar, qarz va to\'lovlar haqida SMS orqali tezkor eslatmalar yuboring.'**
  String get smsPackagesDescription;

  /// No description provided for @smsPackageSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta SMS xabarnoma to\'plami'**
  String smsPackageSubtitle(Object count);

  /// No description provided for @smsPackageAdded.
  ///
  /// In uz, this message translates to:
  /// **'SMS paketi muvaffaqiyatli qo\'shildi'**
  String get smsPackageAdded;

  /// No description provided for @smsMostPopular.
  ///
  /// In uz, this message translates to:
  /// **'ENG OMMABOP PAKET'**
  String get smsMostPopular;

  /// No description provided for @smsPerPrice.
  ///
  /// In uz, this message translates to:
  /// **'1 ta SMS ≈ {price} so\'m'**
  String smsPerPrice(Object price);

  /// No description provided for @commonBuy.
  ///
  /// In uz, this message translates to:
  /// **'Sotib olish'**
  String get commonBuy;

  /// No description provided for @paymentCreatingOrder.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma shakllantirilmoqda'**
  String get paymentCreatingOrder;

  /// No description provided for @paymentConnecting.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov tizimiga xavfsiz ulanish o\'rnatilmoqda...'**
  String get paymentConnecting;

  /// No description provided for @paymentVerifying.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov tekshirilmoqda'**
  String get paymentVerifying;

  /// No description provided for @paymentConfirmInApp.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov ilovasida to\'lovni tasdiqlang. Tekshiruv avtomatik davom etmoqda...'**
  String get paymentConfirmInApp;

  /// No description provided for @paymentCancel.
  ///
  /// In uz, this message translates to:
  /// **'To\'lovni bekor qilish'**
  String get paymentCancel;

  /// No description provided for @paymentWaiting.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov kutilmoqda'**
  String get paymentWaiting;

  /// No description provided for @paymentCheckHint.
  ///
  /// In uz, this message translates to:
  /// **'Agar to\'lov ilovasi orqali to\'lovni amalga oshirgan bo\'lsangiz, \"Tekshirish\" tugmasini bosing'**
  String get paymentCheckHint;

  /// No description provided for @paymentCheck.
  ///
  /// In uz, this message translates to:
  /// **'Tekshirish'**
  String get paymentCheck;

  /// No description provided for @paymentSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Muvaffaqiyatli to\'landi!'**
  String get paymentSuccess;

  /// No description provided for @paymentSuccessSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov qabul qilindi va xizmatlar yangilandi'**
  String get paymentSuccessSubtitle;

  /// No description provided for @paymentFailed.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov amalga oshmadi'**
  String get paymentFailed;

  /// No description provided for @paymentFailedDefault.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov bekor qilindi yoki xatolik yuz berdi'**
  String get paymentFailedDefault;

  /// No description provided for @paymentMethod.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov usuli'**
  String get paymentMethod;

  /// No description provided for @paymentMethodSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'O\'zingizga qulay to\'lov tizimini tanlang'**
  String get paymentMethodSubtitle;

  /// No description provided for @commonTotal.
  ///
  /// In uz, this message translates to:
  /// **'Jami'**
  String get commonTotal;

  /// No description provided for @paymentClickSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Click hamyon va bank kartalari'**
  String get paymentClickSubtitle;

  /// No description provided for @paymentSecure.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov xavfsizligi kafolatlangan (256-bit SSL)'**
  String get paymentSecure;

  /// No description provided for @paymentFast.
  ///
  /// In uz, this message translates to:
  /// **'Tezkor'**
  String get paymentFast;

  /// No description provided for @projectChangeStatus.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha holatini o‘zgartirish'**
  String get projectChangeStatus;

  /// No description provided for @projectTabCosts.
  ///
  /// In uz, this message translates to:
  /// **'Xarajatlar'**
  String get projectTabCosts;

  /// No description provided for @projectTabIncomes.
  ///
  /// In uz, this message translates to:
  /// **'Daromadlar'**
  String get projectTabIncomes;

  /// No description provided for @projectTabContracts.
  ///
  /// In uz, this message translates to:
  /// **'Shartnomalar'**
  String get projectTabContracts;

  /// No description provided for @projectFilesCount.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha fayllari ({count})'**
  String projectFilesCount(int count);

  /// No description provided for @projectFiles.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha fayllari'**
  String get projectFiles;

  /// No description provided for @projectStatusUpdated.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha holati yangilandi'**
  String get projectStatusUpdated;

  /// No description provided for @projectEdit.
  ///
  /// In uz, this message translates to:
  /// **'Loyihani tahrirlash'**
  String get projectEdit;

  /// No description provided for @projectAdd.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha qo‘shish'**
  String get projectAdd;

  /// No description provided for @projectNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi loyiha'**
  String get projectNew;

  /// No description provided for @projectUpdateData.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha ma’lumotlarini yangilang'**
  String get projectUpdateData;

  /// No description provided for @projectAndClientData.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha va buyurtmachi ma’lumotlari'**
  String get projectAndClientData;

  /// No description provided for @projectNameRequired.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha nomi *'**
  String get projectNameRequired;

  /// No description provided for @projectNameHint.
  ///
  /// In uz, this message translates to:
  /// **'Masalan, yangi ofis qurilishi'**
  String get projectNameHint;

  /// No description provided for @projectClientRequired.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmachi *'**
  String get projectClientRequired;

  /// No description provided for @projectClientHint.
  ///
  /// In uz, this message translates to:
  /// **'Ism yoki tashkilot nomi'**
  String get projectClientHint;

  /// No description provided for @commonPhoneRequired.
  ///
  /// In uz, this message translates to:
  /// **'Telefon *'**
  String get commonPhoneRequired;

  /// No description provided for @projectAddressOptional.
  ///
  /// In uz, this message translates to:
  /// **'Manzil (ixtiyoriy)'**
  String get projectAddressOptional;

  /// No description provided for @projectAddressHint.
  ///
  /// In uz, this message translates to:
  /// **'Shahar, ko‘cha yoki loyiha manzili'**
  String get projectAddressHint;

  /// No description provided for @projectFilesAndImages.
  ///
  /// In uz, this message translates to:
  /// **'Fayllar va rasmlar'**
  String get projectFilesAndImages;

  /// No description provided for @fileUploading.
  ///
  /// In uz, this message translates to:
  /// **'Fayl yuklanmoqda…'**
  String get fileUploading;

  /// No description provided for @projectCreate.
  ///
  /// In uz, this message translates to:
  /// **'Loyihani yaratish'**
  String get projectCreate;

  /// No description provided for @projectSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha nomi bo\'yicha qidirish'**
  String get projectSearchHint;

  /// No description provided for @projectsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Loyihalar topilmadi'**
  String get projectsEmpty;

  /// No description provided for @costTypeSelect.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat turini tanlang'**
  String get costTypeSelect;

  /// No description provided for @costTypeSearch.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat turini qidirish'**
  String get costTypeSearch;

  /// No description provided for @costTypeCreateNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi xarajat turi yaratish'**
  String get costTypeCreateNew;

  /// No description provided for @costTypeNoneYet.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat turlari hali mavjud emas'**
  String get costTypeNoneYet;

  /// No description provided for @costTypeEnterName.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat turi nomini kiriting'**
  String get costTypeEnterName;

  /// No description provided for @costTypeNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi xarajat turi'**
  String get costTypeNew;

  /// No description provided for @costTypeName.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat turi nomi'**
  String get costTypeName;

  /// No description provided for @costTypeNameHint.
  ///
  /// In uz, this message translates to:
  /// **'Masalan, asbob-uskunalar'**
  String get costTypeNameHint;

  /// No description provided for @costTypeLinkWorker.
  ///
  /// In uz, this message translates to:
  /// **'Ishchiga bog‘lash'**
  String get costTypeLinkWorker;

  /// No description provided for @costTypeLinkWorkerHint.
  ///
  /// In uz, this message translates to:
  /// **'Yoqilsa, xarajat kiritishda ishchi tanlanadi'**
  String get costTypeLinkWorkerHint;

  /// No description provided for @commonCreateAndSelect.
  ///
  /// In uz, this message translates to:
  /// **'Yaratish va tanlash'**
  String get commonCreateAndSelect;

  /// No description provided for @positionSearch.
  ///
  /// In uz, this message translates to:
  /// **'Lavozimni qidirish'**
  String get positionSearch;

  /// No description provided for @positionCreateNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi lavozim yaratish'**
  String get positionCreateNew;

  /// No description provided for @positionNoneYet.
  ///
  /// In uz, this message translates to:
  /// **'Lavozimlar hali mavjud emas'**
  String get positionNoneYet;

  /// No description provided for @positionEnterName.
  ///
  /// In uz, this message translates to:
  /// **'Lavozim nomini kiriting'**
  String get positionEnterName;

  /// No description provided for @positionNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi lavozim'**
  String get positionNew;

  /// No description provided for @positionName.
  ///
  /// In uz, this message translates to:
  /// **'Lavozim nomi'**
  String get positionName;

  /// No description provided for @positionNameHint.
  ///
  /// In uz, this message translates to:
  /// **'Masalan, elektrik'**
  String get positionNameHint;

  /// No description provided for @contractsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Shartnomalar yo\'q'**
  String get contractsEmpty;

  /// No description provided for @contractAdd.
  ///
  /// In uz, this message translates to:
  /// **'Shartnoma qo\'shish'**
  String get contractAdd;

  /// No description provided for @workTypeSelect.
  ///
  /// In uz, this message translates to:
  /// **'Ish turini tanlang'**
  String get workTypeSelect;

  /// No description provided for @commonDescriptionRequired.
  ///
  /// In uz, this message translates to:
  /// **'Tavsif *'**
  String get commonDescriptionRequired;

  /// No description provided for @contractDescriptionHint.
  ///
  /// In uz, this message translates to:
  /// **'Bajariladigan ishni qisqacha yozing'**
  String get contractDescriptionHint;

  /// No description provided for @contractDescriptionRequired.
  ///
  /// In uz, this message translates to:
  /// **'Tavsif majburiy. Bajariladigan ishni yozing.'**
  String get contractDescriptionRequired;

  /// No description provided for @contractEnterWorkTypeAmount.
  ///
  /// In uz, this message translates to:
  /// **'Ish turi va summani kiriting'**
  String get contractEnterWorkTypeAmount;

  /// No description provided for @costsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Xarajatlar yo‘q'**
  String get costsEmpty;

  /// No description provided for @costWorker.
  ///
  /// In uz, this message translates to:
  /// **'Ishchi: {name}'**
  String costWorker(Object name);

  /// No description provided for @costAdd.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat qo\'shish'**
  String get costAdd;

  /// No description provided for @costType.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat turi'**
  String get costType;

  /// No description provided for @costWorkerLabel.
  ///
  /// In uz, this message translates to:
  /// **'Ishchi'**
  String get costWorkerLabel;

  /// No description provided for @costEnterTypeAmount.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat turi va summani kiriting'**
  String get costEnterTypeAmount;

  /// No description provided for @costSelectWorker.
  ///
  /// In uz, this message translates to:
  /// **'Ishchini tanlang'**
  String get costSelectWorker;

  /// No description provided for @entryCostDetails.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat tafsilotlari'**
  String get entryCostDetails;

  /// No description provided for @entryIncomeDetails.
  ///
  /// In uz, this message translates to:
  /// **'Daromad tafsilotlari'**
  String get entryIncomeDetails;

  /// No description provided for @entryProjectCost.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha xarajati'**
  String get entryProjectCost;

  /// No description provided for @entryProjectIncome.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha daromadi'**
  String get entryProjectIncome;

  /// No description provided for @entryOperation.
  ///
  /// In uz, this message translates to:
  /// **'Operatsiya'**
  String get entryOperation;

  /// No description provided for @entryNoNote.
  ///
  /// In uz, this message translates to:
  /// **'Izoh kiritilmagan'**
  String get entryNoNote;

  /// No description provided for @incomesEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Daromadlar yo‘q'**
  String get incomesEmpty;

  /// No description provided for @incomeAdd.
  ///
  /// In uz, this message translates to:
  /// **'Daromad qo\'shish'**
  String get incomeAdd;

  /// No description provided for @projectStatusTitle.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha holati'**
  String get projectStatusTitle;

  /// No description provided for @projectCurrentStatus.
  ///
  /// In uz, this message translates to:
  /// **'Joriy holat: {status}'**
  String projectCurrentStatus(Object status);

  /// No description provided for @commonUpdating.
  ///
  /// In uz, this message translates to:
  /// **'Yangilanmoqda…'**
  String get commonUpdating;

  /// No description provided for @projectSaveStatus.
  ///
  /// In uz, this message translates to:
  /// **'Holatni saqlash'**
  String get projectSaveStatus;

  /// No description provided for @projectStatusInProgressHint.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha bo‘yicha ishlar davom etmoqda'**
  String get projectStatusInProgressHint;

  /// No description provided for @projectStatusFrozenHint.
  ///
  /// In uz, this message translates to:
  /// **'Ishlar vaqtincha to‘xtatilgan'**
  String get projectStatusFrozenHint;

  /// No description provided for @projectStatusCompletedHint.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha bo‘yicha ishlar yakunlangan'**
  String get projectStatusCompletedHint;

  /// No description provided for @projectStatusCurrent.
  ///
  /// In uz, this message translates to:
  /// **'Joriy'**
  String get projectStatusCurrent;

  /// No description provided for @projectAssignStaff.
  ///
  /// In uz, this message translates to:
  /// **'Loyihaga xodim biriktirish'**
  String get projectAssignStaff;

  /// No description provided for @projectUnassignedWorkers.
  ///
  /// In uz, this message translates to:
  /// **'Ushbu loyihaga biriktirilmagan ishchilar'**
  String get projectUnassignedWorkers;

  /// No description provided for @workerSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Ism, telefon yoki lavozim'**
  String get workerSearchHint;

  /// No description provided for @workerCreateNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi ishchi yaratish'**
  String get workerCreateNew;

  /// No description provided for @workerNoneFree.
  ///
  /// In uz, this message translates to:
  /// **'Biriktirish uchun bo‘sh ishchi yo‘q. Yangi ishchi yaratish uchun + tugmasini bosing.'**
  String get workerNoneFree;

  /// No description provided for @workersNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Ishchilar topilmadi'**
  String get workersNotFound;

  /// No description provided for @workerAssigning.
  ///
  /// In uz, this message translates to:
  /// **'Biriktirilmoqda…'**
  String get workerAssigning;

  /// No description provided for @workerSelectStaff.
  ///
  /// In uz, this message translates to:
  /// **'Xodimlarni tanlang'**
  String get workerSelectStaff;

  /// No description provided for @workerAssignCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta xodimni biriktirish'**
  String workerAssignCount(int count);

  /// No description provided for @workerAssign.
  ///
  /// In uz, this message translates to:
  /// **'Ishchi biriktirish'**
  String get workerAssign;

  /// No description provided for @workersNoneAssigned.
  ///
  /// In uz, this message translates to:
  /// **'Ishchilar biriktirilmagan'**
  String get workersNoneAssigned;

  /// No description provided for @workTypeSearch.
  ///
  /// In uz, this message translates to:
  /// **'Ish turini qidirish'**
  String get workTypeSearch;

  /// No description provided for @workTypeCreateNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi ish turi yaratish'**
  String get workTypeCreateNew;

  /// No description provided for @workTypeNoneYet.
  ///
  /// In uz, this message translates to:
  /// **'Ish turlari hali mavjud emas'**
  String get workTypeNoneYet;

  /// No description provided for @workTypeEnterName.
  ///
  /// In uz, this message translates to:
  /// **'Ish turi nomini kiriting'**
  String get workTypeEnterName;

  /// No description provided for @workTypeNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi ish turi'**
  String get workTypeNew;

  /// No description provided for @workTypeName.
  ///
  /// In uz, this message translates to:
  /// **'Ish turi nomi'**
  String get workTypeName;

  /// No description provided for @workTypeNameHint.
  ///
  /// In uz, this message translates to:
  /// **'Masalan, elektr montaj'**
  String get workTypeNameHint;

  /// No description provided for @workerSelect.
  ///
  /// In uz, this message translates to:
  /// **'Ishchini tanlang'**
  String get workerSelect;

  /// No description provided for @workerNoneYet.
  ///
  /// In uz, this message translates to:
  /// **'Ishchilar hali mavjud emas'**
  String get workerNoneYet;

  /// No description provided for @workerEnterName.
  ///
  /// In uz, this message translates to:
  /// **'Ishchi ismini kiriting'**
  String get workerEnterName;

  /// No description provided for @errorAlreadyRegistered.
  ///
  /// In uz, this message translates to:
  /// **'Bu ma’lumot allaqachon ro‘yxatdan o‘tgan'**
  String get errorAlreadyRegistered;

  /// No description provided for @errorFillField.
  ///
  /// In uz, this message translates to:
  /// **'Bu maydonni to‘ldiring'**
  String get errorFillField;

  /// No description provided for @errorInvalidData.
  ///
  /// In uz, this message translates to:
  /// **'Kiritilgan ma’lumot noto‘g‘ri'**
  String get errorInvalidData;

  /// No description provided for @workerNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi ishchi'**
  String get workerNew;

  /// No description provided for @commonNameRequired.
  ///
  /// In uz, this message translates to:
  /// **'Ism *'**
  String get commonNameRequired;

  /// No description provided for @workerNameHint.
  ///
  /// In uz, this message translates to:
  /// **'Ishchining ismi'**
  String get workerNameHint;

  /// No description provided for @commonAdditionalPhoneOptional.
  ///
  /// In uz, this message translates to:
  /// **'Qo‘shimcha telefon (ixtiyoriy)'**
  String get commonAdditionalPhoneOptional;

  /// No description provided for @positionRequired.
  ///
  /// In uz, this message translates to:
  /// **'Lavozim *'**
  String get positionRequired;

  /// No description provided for @commonAdditionalInfoHint.
  ///
  /// In uz, this message translates to:
  /// **'Qo‘shimcha ma’lumot'**
  String get commonAdditionalInfoHint;

  /// No description provided for @reportInstallmentTitle.
  ///
  /// In uz, this message translates to:
  /// **'Muddatli to‘lov hisoboti'**
  String get reportInstallmentTitle;

  /// No description provided for @reportInstallmentNoData.
  ///
  /// In uz, this message translates to:
  /// **'Bo‘lib to‘lash ma’lumoti yo‘q'**
  String get reportInstallmentNoData;

  /// No description provided for @reportSections.
  ///
  /// In uz, this message translates to:
  /// **'Hisobot bo‘limlari'**
  String get reportSections;

  /// No description provided for @reportCollectionEfficiency.
  ///
  /// In uz, this message translates to:
  /// **'Undirish samaradorligi'**
  String get reportCollectionEfficiency;

  /// No description provided for @reportCollectionEfficiencySubtitle.
  ///
  /// In uz, this message translates to:
  /// **'To‘lov samaradorligi va undirilgan summalar'**
  String get reportCollectionEfficiencySubtitle;

  /// No description provided for @reportExpectedPayments.
  ///
  /// In uz, this message translates to:
  /// **'Kutilayotgan to‘lovlar'**
  String get reportExpectedPayments;

  /// No description provided for @reportExpectedPaymentsSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'30/60/90 kunlik prognoz'**
  String get reportExpectedPaymentsSubtitle;

  /// No description provided for @reportMonthlyDynamics.
  ///
  /// In uz, this message translates to:
  /// **'Oylik dinamika'**
  String get reportMonthlyDynamics;

  /// No description provided for @reportMonthlyDynamicsSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Oylar bo‘yicha to‘lov grafigi'**
  String get reportMonthlyDynamicsSubtitle;

  /// No description provided for @reportProblemClients.
  ///
  /// In uz, this message translates to:
  /// **'Muammoli mijozlar'**
  String get reportProblemClients;

  /// No description provided for @reportProblemClientsSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Kechiktirilgan va xavfli mijozlar ro‘yxati'**
  String get reportProblemClientsSubtitle;

  /// No description provided for @reportByClients.
  ///
  /// In uz, this message translates to:
  /// **'Mijozlar bo‘yicha'**
  String get reportByClients;

  /// No description provided for @reportByClientsSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz bo‘yicha muddatli to‘lov hisoboti'**
  String get reportByClientsSubtitle;

  /// No description provided for @reportActivePlans.
  ///
  /// In uz, this message translates to:
  /// **'Faol rejalar'**
  String get reportActivePlans;

  /// No description provided for @reportGiven.
  ///
  /// In uz, this message translates to:
  /// **'Berilgan'**
  String get reportGiven;

  /// No description provided for @reportCollected.
  ///
  /// In uz, this message translates to:
  /// **'Undirilgan'**
  String get reportCollected;

  /// No description provided for @reportOverdueRate.
  ///
  /// In uz, this message translates to:
  /// **'Kechikish darajasi: {rate}%'**
  String reportOverdueRate(Object rate);

  /// No description provided for @reportPaymentStatuses.
  ///
  /// In uz, this message translates to:
  /// **'To‘lov holatlari'**
  String get reportPaymentStatuses;

  /// No description provided for @reportPaymentsCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta to‘lov'**
  String reportPaymentsCount(int count);

  /// No description provided for @reportPartiallyPaid.
  ///
  /// In uz, this message translates to:
  /// **'Qisman to‘langan'**
  String get reportPartiallyPaid;

  /// No description provided for @reportPending.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmoqda'**
  String get reportPending;

  /// No description provided for @reportDays30.
  ///
  /// In uz, this message translates to:
  /// **'30 kun'**
  String get reportDays30;

  /// No description provided for @reportDays60.
  ///
  /// In uz, this message translates to:
  /// **'60 kun'**
  String get reportDays60;

  /// No description provided for @reportDays90.
  ///
  /// In uz, this message translates to:
  /// **'90 kun'**
  String get reportDays90;

  /// No description provided for @reportExpectedAmount.
  ///
  /// In uz, this message translates to:
  /// **'Kutilayotgan summa'**
  String get reportExpectedAmount;

  /// No description provided for @reportPayments.
  ///
  /// In uz, this message translates to:
  /// **'To‘lovlar'**
  String get reportPayments;

  /// No description provided for @reportPrevYear.
  ///
  /// In uz, this message translates to:
  /// **'Oldingi yil'**
  String get reportPrevYear;

  /// No description provided for @reportNextYear.
  ///
  /// In uz, this message translates to:
  /// **'Keyingi yil'**
  String get reportNextYear;

  /// No description provided for @reportTotalPayments.
  ///
  /// In uz, this message translates to:
  /// **'Jami to‘lovlar'**
  String get reportTotalPayments;

  /// No description provided for @reportNoData.
  ///
  /// In uz, this message translates to:
  /// **'Ma’lumot yo‘q'**
  String get reportNoData;

  /// No description provided for @reportNoProblemClients.
  ///
  /// In uz, this message translates to:
  /// **'Muammoli mijozlar yo‘q'**
  String get reportNoProblemClients;

  /// No description provided for @reportRiskHigh.
  ///
  /// In uz, this message translates to:
  /// **'Yuqori xavf'**
  String get reportRiskHigh;

  /// No description provided for @reportRiskMedium.
  ///
  /// In uz, this message translates to:
  /// **'O‘rta xavf'**
  String get reportRiskMedium;

  /// No description provided for @reportRiskLow.
  ///
  /// In uz, this message translates to:
  /// **'Past xavf'**
  String get reportRiskLow;

  /// No description provided for @reportOverdueSummary.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta kechikkan to‘lov · O‘rtacha {days} kun'**
  String reportOverdueSummary(Object count, Object days);

  /// No description provided for @reportRiskScore.
  ///
  /// In uz, this message translates to:
  /// **'Xavf balli: {score}'**
  String reportRiskScore(Object score);

  /// No description provided for @reportActivePlansCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta faol reja'**
  String reportActivePlansCount(int count);

  /// No description provided for @reportLastPayment.
  ///
  /// In uz, this message translates to:
  /// **'Oxirgi to‘lov: {date}'**
  String reportLastPayment(Object date);

  /// No description provided for @commonLoadMore.
  ///
  /// In uz, this message translates to:
  /// **'Yana yuklash'**
  String get commonLoadMore;

  /// No description provided for @reportNoTransactions.
  ///
  /// In uz, this message translates to:
  /// **'Tranzaksiyalar mavjud emas'**
  String get reportNoTransactions;

  /// No description provided for @reportDueDate.
  ///
  /// In uz, this message translates to:
  /// **'Muddat: {date}'**
  String reportDueDate(Object date);

  /// No description provided for @reportPartnerTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hamkor hisoboti'**
  String get reportPartnerTitle;

  /// No description provided for @reportExcel.
  ///
  /// In uz, this message translates to:
  /// **'Excel hisobot'**
  String get reportExcel;

  /// No description provided for @reportTabSettlements.
  ///
  /// In uz, this message translates to:
  /// **'Hisob kitob'**
  String get reportTabSettlements;

  /// No description provided for @reportTabInstallment.
  ///
  /// In uz, this message translates to:
  /// **'Muddatli to\'lov'**
  String get reportTabInstallment;

  /// No description provided for @reportAccountUzs.
  ///
  /// In uz, this message translates to:
  /// **'UZS Hisob'**
  String get reportAccountUzs;

  /// No description provided for @reportAccountUsd.
  ///
  /// In uz, this message translates to:
  /// **'USD Hisob'**
  String get reportAccountUsd;

  /// No description provided for @reportIncomesList.
  ///
  /// In uz, this message translates to:
  /// **'Kirimlar ro\'yxati'**
  String get reportIncomesList;

  /// No description provided for @reportExpensesList.
  ///
  /// In uz, this message translates to:
  /// **'Chiqimlar ro\'yxati'**
  String get reportExpensesList;

  /// No description provided for @reportOperationsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Operatsiyalar topilmadi'**
  String get reportOperationsEmpty;

  /// No description provided for @receiptShareAmountPlain.
  ///
  /// In uz, this message translates to:
  /// **'Summa: {amount}'**
  String receiptShareAmountPlain(Object amount);

  /// No description provided for @reportPaidAmount.
  ///
  /// In uz, this message translates to:
  /// **'To‘langan: {amount}'**
  String reportPaidAmount(Object amount);

  /// No description provided for @reportPartnersTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hamkorlar hisoboti'**
  String get reportPartnersTitle;

  /// No description provided for @reportActions.
  ///
  /// In uz, this message translates to:
  /// **'Hisobot amallari'**
  String get reportActions;

  /// No description provided for @reportOperations.
  ///
  /// In uz, this message translates to:
  /// **'Operatsiyalar'**
  String get reportOperations;

  /// No description provided for @reportTypes.
  ///
  /// In uz, this message translates to:
  /// **'Hisobot turlari'**
  String get reportTypes;

  /// No description provided for @reportDebtTerms.
  ///
  /// In uz, this message translates to:
  /// **'Qarz muddatlari hisoboti'**
  String get reportDebtTerms;

  /// No description provided for @reportDebtTermsSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Muddati o‘tgan, bugun va kelgusi qarzlar'**
  String get reportDebtTermsSubtitle;

  /// No description provided for @reportStaff.
  ///
  /// In uz, this message translates to:
  /// **'Xodimlar hisoboti'**
  String get reportStaff;

  /// No description provided for @reportStaffSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Xodimlar bo‘yicha barcha hisobotlar'**
  String get reportStaffSubtitle;

  /// No description provided for @reportPeriod.
  ///
  /// In uz, this message translates to:
  /// **'Muddat hisoboti'**
  String get reportPeriod;

  /// No description provided for @reportPeriodSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Davr bo‘yicha kirim va chiqim'**
  String get reportPeriodSubtitle;

  /// No description provided for @reportInstallmentShortSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Rejalar, undirish, oylik dinamika va muammoli mijozlar'**
  String get reportInstallmentShortSubtitle;

  /// No description provided for @reportSelectPeriod.
  ///
  /// In uz, this message translates to:
  /// **'Hisobot davrini tanlang'**
  String get reportSelectPeriod;

  /// No description provided for @dateThisWeek.
  ///
  /// In uz, this message translates to:
  /// **'Bu hafta'**
  String get dateThisWeek;

  /// No description provided for @reportTotalIncome.
  ///
  /// In uz, this message translates to:
  /// **'Jami kirim'**
  String get reportTotalIncome;

  /// No description provided for @reportTotalExpense.
  ///
  /// In uz, this message translates to:
  /// **'Jami chiqim'**
  String get reportTotalExpense;

  /// No description provided for @reportStaffLoadError.
  ///
  /// In uz, this message translates to:
  /// **'Xodimlar hisobotini yuklab bo‘lmadi'**
  String get reportStaffLoadError;

  /// No description provided for @reportNoOperationsPeriod.
  ///
  /// In uz, this message translates to:
  /// **'Bu davrda operatsiyalar yo‘q'**
  String get reportNoOperationsPeriod;

  /// No description provided for @reportStaffCount.
  ///
  /// In uz, this message translates to:
  /// **'Xodimlar · {count}'**
  String reportStaffCount(Object count);

  /// No description provided for @reportYourDebt.
  ///
  /// In uz, this message translates to:
  /// **'Sizning qarzingiz'**
  String get reportYourDebt;

  /// No description provided for @reportClientsDebt.
  ///
  /// In uz, this message translates to:
  /// **'Mijozlar qarzi'**
  String get reportClientsDebt;

  /// No description provided for @reportBalanceRest.
  ///
  /// In uz, this message translates to:
  /// **'Qoldiq'**
  String get reportBalanceRest;

  /// No description provided for @projectSelect.
  ///
  /// In uz, this message translates to:
  /// **'Loyihani tanlang'**
  String get projectSelect;

  /// No description provided for @reportFinance.
  ///
  /// In uz, this message translates to:
  /// **'Moliya hisoboti'**
  String get reportFinance;

  /// No description provided for @projectNotSelected.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha tanlanmagan'**
  String get projectNotSelected;

  /// No description provided for @projectSelectForFinance.
  ///
  /// In uz, this message translates to:
  /// **'Moliya hisobotini ko‘rish uchun loyihani tanlang'**
  String get projectSelectForFinance;

  /// No description provided for @reportByCategories.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriyalar bo‘yicha'**
  String get reportByCategories;

  /// No description provided for @reportNoExpenses.
  ///
  /// In uz, this message translates to:
  /// **'Xarajatlar mavjud emas'**
  String get reportNoExpenses;

  /// No description provided for @projectSearch.
  ///
  /// In uz, this message translates to:
  /// **'Loyihani qidirish'**
  String get projectSearch;

  /// No description provided for @reportPartnersHomeSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Umumiy balans, davr bo\'yicha, qarz muddatlari, xodimlar'**
  String get reportPartnersHomeSubtitle;

  /// No description provided for @reportInstallmentHomeSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Umumiy tahlil, kutilayotgan to‘lovlar va undirish dinamikasi'**
  String get reportInstallmentHomeSubtitle;

  /// No description provided for @reportProjectsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Loyihalar hisoboti'**
  String get reportProjectsTitle;

  /// No description provided for @reportProjectsSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha balansi, xarajatlar va daromadlar tahlili'**
  String get reportProjectsSubtitle;

  /// No description provided for @reportClientDebt.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz qarzi'**
  String get reportClientDebt;

  /// No description provided for @reportClientCredit.
  ///
  /// In uz, this message translates to:
  /// **'Mijoz haqqi'**
  String get reportClientCredit;

  /// No description provided for @reportAccountClosed.
  ///
  /// In uz, this message translates to:
  /// **'Hisob yopilgan'**
  String get reportAccountClosed;

  /// No description provided for @reportCurrentBalance.
  ///
  /// In uz, this message translates to:
  /// **'Joriy balans'**
  String get reportCurrentBalance;

  /// No description provided for @reportOperationsCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta operatsiya'**
  String reportOperationsCount(int count);

  /// No description provided for @reportBalanceDynamics.
  ///
  /// In uz, this message translates to:
  /// **'Balans dinamikasi'**
  String get reportBalanceDynamics;

  /// No description provided for @reportNoDataYet.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha ma’lumot yo‘q'**
  String get reportNoDataYet;

  /// No description provided for @reportLastOperations.
  ///
  /// In uz, this message translates to:
  /// **'Oxirgi operatsiyalar ({currency})'**
  String reportLastOperations(Object currency);

  /// No description provided for @reportDebtsList.
  ///
  /// In uz, this message translates to:
  /// **'Qarzlar ro\'yxati'**
  String get reportDebtsList;

  /// No description provided for @reportUpcoming.
  ///
  /// In uz, this message translates to:
  /// **'Yaqinlashmoqda'**
  String get reportUpcoming;

  /// No description provided for @reportIn3DaysParen.
  ///
  /// In uz, this message translates to:
  /// **'(3 kun)'**
  String get reportIn3DaysParen;

  /// No description provided for @reportMonthlyStats.
  ///
  /// In uz, this message translates to:
  /// **'Oylik statistika'**
  String get reportMonthlyStats;

  /// No description provided for @reportLastMonths.
  ///
  /// In uz, this message translates to:
  /// **'So\'nggi {count} oy ({currency})'**
  String reportLastMonths(Object count, Object currency);

  /// No description provided for @reportOverallStats.
  ///
  /// In uz, this message translates to:
  /// **'Umumiy statistika'**
  String get reportOverallStats;

  /// No description provided for @reportCancelledShort.
  ///
  /// In uz, this message translates to:
  /// **'Bekor'**
  String get reportCancelledShort;

  /// No description provided for @reportOverdueAmount.
  ///
  /// In uz, this message translates to:
  /// **'Muddati o\'tgan: {amount} {currency}'**
  String reportOverdueAmount(Object amount, Object currency);

  /// No description provided for @reportInstallmentPlans.
  ///
  /// In uz, this message translates to:
  /// **'Muddatli to‘lov rejalari'**
  String get reportInstallmentPlans;

  /// No description provided for @reportNoPlans.
  ///
  /// In uz, this message translates to:
  /// **'Rejalar mavjud emas'**
  String get reportNoPlans;

  /// No description provided for @reportDate.
  ///
  /// In uz, this message translates to:
  /// **'Sana: {date}'**
  String reportDate(Object date);

  /// No description provided for @reportTotalAmount.
  ///
  /// In uz, this message translates to:
  /// **'Jami summa'**
  String get reportTotalAmount;

  /// No description provided for @reportParts.
  ///
  /// In uz, this message translates to:
  /// **'Qismlar'**
  String get reportParts;

  /// No description provided for @reportPaidWithCurrency.
  ///
  /// In uz, this message translates to:
  /// **'To\'langan: {amount} {currency}'**
  String reportPaidWithCurrency(Object amount, Object currency);

  /// No description provided for @reportRemainingWithCurrency.
  ///
  /// In uz, this message translates to:
  /// **'Qolgan: {amount} {currency}'**
  String reportRemainingWithCurrency(Object amount, Object currency);

  /// No description provided for @reportPartsSchedule.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov qismlari grafigi'**
  String get reportPartsSchedule;

  /// No description provided for @reportMonthlyPaymentDynamics.
  ///
  /// In uz, this message translates to:
  /// **'Oylik to\'lov dinamikasi'**
  String get reportMonthlyPaymentDynamics;

  /// No description provided for @reportPlanCollected.
  ///
  /// In uz, this message translates to:
  /// **'Reja: {planned} | Yig\'ildi: {collected}'**
  String reportPlanCollected(Object planned, Object collected);

  /// No description provided for @receiptShareNumber.
  ///
  /// In uz, this message translates to:
  /// **'Chek raqami: № {number}'**
  String receiptShareNumber(Object number);

  /// No description provided for @receiptShareStatus.
  ///
  /// In uz, this message translates to:
  /// **'Holati: {status}'**
  String receiptShareStatus(Object status);

  /// No description provided for @receiptShareStatusCancelled.
  ///
  /// In uz, this message translates to:
  /// **'BEKOR QILINGAN'**
  String get receiptShareStatusCancelled;

  /// No description provided for @receiptShareStatusSuccess.
  ///
  /// In uz, this message translates to:
  /// **'MUVAFFAQIYATLI O‘TKAZILDI'**
  String get receiptShareStatusSuccess;

  /// No description provided for @receiptShareOperation.
  ///
  /// In uz, this message translates to:
  /// **'Operatsiya: {type}'**
  String receiptShareOperation(Object type);

  /// No description provided for @receiptIncomeTypeShare.
  ///
  /// In uz, this message translates to:
  /// **'Kirim (Mablag‘ tushumi)'**
  String get receiptIncomeTypeShare;

  /// No description provided for @installmentAdvanceLine.
  ///
  /// In uz, this message translates to:
  /// **'Boshlang‘ich to‘lov: {amount} {currency}'**
  String installmentAdvanceLine(Object amount, Object currency);

  /// No description provided for @installmentRemainingPrefix.
  ///
  /// In uz, this message translates to:
  /// **'Qolgan:'**
  String get installmentRemainingPrefix;

  /// No description provided for @installmentPerPartResult.
  ///
  /// In uz, this message translates to:
  /// **'= {amount} {currency}/qism'**
  String installmentPerPartResult(Object amount, Object currency);

  /// No description provided for @walletReasonEnteredByMistake.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik bilan kiritildi'**
  String get walletReasonEnteredByMistake;

  /// No description provided for @activityActionCreated.
  ///
  /// In uz, this message translates to:
  /// **'yaratdi'**
  String get activityActionCreated;

  /// No description provided for @activityActionUpdated.
  ///
  /// In uz, this message translates to:
  /// **'tahrirladi'**
  String get activityActionUpdated;

  /// No description provided for @activityActionRestored.
  ///
  /// In uz, this message translates to:
  /// **'tikladi'**
  String get activityActionRestored;

  /// No description provided for @activityModelWallet.
  ///
  /// In uz, this message translates to:
  /// **'tranzaksiyani'**
  String get activityModelWallet;

  /// No description provided for @activityModelPartner.
  ///
  /// In uz, this message translates to:
  /// **'hamkorni'**
  String get activityModelPartner;

  /// No description provided for @activityModelProject.
  ///
  /// In uz, this message translates to:
  /// **'loyihani'**
  String get activityModelProject;

  /// No description provided for @activitySummary.
  ///
  /// In uz, this message translates to:
  /// **'{name} {object} {action}'**
  String activitySummary(Object name, Object object, Object action);

  /// No description provided for @monthsShort.
  ///
  /// In uz, this message translates to:
  /// **'Yan,Fev,Mar,Apr,May,Iyun,Iyul,Avg,Sen,Okt,Noy,Dek'**
  String get monthsShort;

  /// No description provided for @receiptShareSubject.
  ///
  /// In uz, this message translates to:
  /// **'To‘lov cheki № {number}'**
  String receiptShareSubject(Object number);

  /// No description provided for @installmentAdvanceBadge.
  ///
  /// In uz, this message translates to:
  /// **'AVANS'**
  String get installmentAdvanceBadge;

  /// No description provided for @authStaffBadge.
  ///
  /// In uz, this message translates to:
  /// **'XODIM'**
  String get authStaffBadge;

  /// No description provided for @authLoginBadge.
  ///
  /// In uz, this message translates to:
  /// **'AUTENTIFIKATSIYA'**
  String get authLoginBadge;

  /// No description provided for @settingsGeneral.
  ///
  /// In uz, this message translates to:
  /// **'UMUMIY'**
  String get settingsGeneral;

  /// No description provided for @settingsSecurity.
  ///
  /// In uz, this message translates to:
  /// **'XAVFSIZLIK'**
  String get settingsSecurity;

  /// No description provided for @settingsLanguage.
  ///
  /// In uz, this message translates to:
  /// **'Til'**
  String get settingsLanguage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
