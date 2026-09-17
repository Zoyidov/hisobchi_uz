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
  /// **'E-Hisob'**
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

  /// No description provided for @commonApply.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'llash'**
  String get commonApply;

  /// No description provided for @commonClear.
  ///
  /// In uz, this message translates to:
  /// **'Tozalash'**
  String get commonClear;

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

  /// No description provided for @commonSeeAll.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get commonSeeAll;

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

  /// No description provided for @commonSkip.
  ///
  /// In uz, this message translates to:
  /// **'O\'tkazib yuborish'**
  String get commonSkip;

  /// No description provided for @commonYes.
  ///
  /// In uz, this message translates to:
  /// **'Ha'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'q'**
  String get commonNo;

  /// No description provided for @commonConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash'**
  String get commonConfirm;

  /// No description provided for @commonLoading.
  ///
  /// In uz, this message translates to:
  /// **'Yuklanmoqda...'**
  String get commonLoading;

  /// No description provided for @commonComingSoon.
  ///
  /// In uz, this message translates to:
  /// **'Tez orada'**
  String get commonComingSoon;

  /// No description provided for @commonRestore.
  ///
  /// In uz, this message translates to:
  /// **'Tiklash'**
  String get commonRestore;

  /// No description provided for @commonShare.
  ///
  /// In uz, this message translates to:
  /// **'Ulashish'**
  String get commonShare;

  /// No description provided for @commonDownload.
  ///
  /// In uz, this message translates to:
  /// **'Yuklab olish'**
  String get commonDownload;

  /// No description provided for @commonCall.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'ng\'iroq'**
  String get commonCall;

  /// No description provided for @commonSms.
  ///
  /// In uz, this message translates to:
  /// **'SMS'**
  String get commonSms;

  /// No description provided for @commonReport.
  ///
  /// In uz, this message translates to:
  /// **'Hisobot'**
  String get commonReport;

  /// No description provided for @commonExcel.
  ///
  /// In uz, this message translates to:
  /// **'Excel\'ga eksport'**
  String get commonExcel;

  /// No description provided for @commonSettings.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalar'**
  String get commonSettings;

  /// No description provided for @commonBack.
  ///
  /// In uz, this message translates to:
  /// **'Orqaga'**
  String get commonBack;

  /// No description provided for @commonDone.
  ///
  /// In uz, this message translates to:
  /// **'Tayyor'**
  String get commonDone;

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

  /// No description provided for @authPhoneAgreement.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanish shartlariga roziman'**
  String get authPhoneAgreement;

  /// No description provided for @authTermsLink.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanish shartlari'**
  String get authTermsLink;

  /// No description provided for @authOtpTitle.
  ///
  /// In uz, this message translates to:
  /// **'SMS orqali yuborilgan 4 xonali kodni kiriting'**
  String get authOtpTitle;

  /// No description provided for @authOtpResend.
  ///
  /// In uz, this message translates to:
  /// **'Qayta yuborish'**
  String get authOtpResend;

  /// No description provided for @authOtpResendIn.
  ///
  /// In uz, this message translates to:
  /// **'Qayta yuborish {seconds}'**
  String authOtpResendIn(String seconds);

  /// No description provided for @authOtpInvalid.
  ///
  /// In uz, this message translates to:
  /// **'OTP noto\'g\'ri'**
  String get authOtpInvalid;

  /// No description provided for @authOtpExpired.
  ///
  /// In uz, this message translates to:
  /// **'OTP muddati tugagan'**
  String get authOtpExpired;

  /// No description provided for @authRegisterTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ro\'yxatdan o\'tish'**
  String get authRegisterTitle;

  /// No description provided for @authNameLabel.
  ///
  /// In uz, this message translates to:
  /// **'Ism'**
  String get authNameLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In uz, this message translates to:
  /// **'Parol'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordConfirmLabel.
  ///
  /// In uz, this message translates to:
  /// **'Parolni takrorlang'**
  String get authPasswordConfirmLabel;

  /// No description provided for @authRegisterButton.
  ///
  /// In uz, this message translates to:
  /// **'Ro\'yxatdan o\'tish'**
  String get authRegisterButton;

  /// No description provided for @authLoginTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kirish'**
  String get authLoginTitle;

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

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi parol'**
  String get authResetPasswordTitle;

  /// No description provided for @authNewPasswordLabel.
  ///
  /// In uz, this message translates to:
  /// **'Yangi parol'**
  String get authNewPasswordLabel;

  /// No description provided for @authPincodeTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ilovani himoyalang'**
  String get authPincodeTitle;

  /// No description provided for @authPincodeSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'4 xonali PIN yarating'**
  String get authPincodeSubtitle;

  /// No description provided for @authPincodeRepeat.
  ///
  /// In uz, this message translates to:
  /// **'PIN kodni takrorlang'**
  String get authPincodeRepeat;

  /// No description provided for @authPincodeMismatch.
  ///
  /// In uz, this message translates to:
  /// **'PIN kodlar mos emas'**
  String get authPincodeMismatch;

  /// No description provided for @authPincodeSkip.
  ///
  /// In uz, this message translates to:
  /// **'Keyinroq'**
  String get authPincodeSkip;

  /// No description provided for @authPincodeEnter.
  ///
  /// In uz, this message translates to:
  /// **'PIN kodni kiriting'**
  String get authPincodeEnter;

  /// No description provided for @authPincodeForgot.
  ///
  /// In uz, this message translates to:
  /// **'Parol bilan kirish'**
  String get authPincodeForgot;

  /// No description provided for @authAccountSelectionTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qaysi hisobda ishlaysiz?'**
  String get authAccountSelectionTitle;

  /// No description provided for @authOwnAccount.
  ///
  /// In uz, this message translates to:
  /// **'O\'z hisobim'**
  String get authOwnAccount;

  /// No description provided for @authStaffOf.
  ///
  /// In uz, this message translates to:
  /// **'Xodim sifatida'**
  String get authStaffOf;

  /// No description provided for @authWorkingAs.
  ///
  /// In uz, this message translates to:
  /// **'{name} hisobida ishlayapsiz'**
  String authWorkingAs(String name);

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

  /// No description provided for @authDeleteAccountWarning.
  ///
  /// In uz, this message translates to:
  /// **'Barcha hamkorlar, tranzaksiyalar, loyihalar va hisobotlar o\'chiriladi. Bu amalni qaytarib bo\'lmaydi.'**
  String get authDeleteAccountWarning;

  /// No description provided for @authBlockedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kirish huquqi cheklangan'**
  String get authBlockedTitle;

  /// No description provided for @authSupport.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'llab-quvvatlash'**
  String get authSupport;

  /// No description provided for @authBiometricsReason.
  ///
  /// In uz, this message translates to:
  /// **'Ilovaga kirish uchun tasdiqlang'**
  String get authBiometricsReason;

  /// No description provided for @dashboardGreeting.
  ///
  /// In uz, this message translates to:
  /// **'Assalomu alaykum, {name}'**
  String dashboardGreeting(String name);

  /// No description provided for @dashboardPartnersSection.
  ///
  /// In uz, this message translates to:
  /// **'Hamkorlar'**
  String get dashboardPartnersSection;

  /// No description provided for @dashboardOverdue.
  ///
  /// In uz, this message translates to:
  /// **'Muddati o\'tgan'**
  String get dashboardOverdue;

  /// No description provided for @dashboardDueToday.
  ///
  /// In uz, this message translates to:
  /// **'Bugun'**
  String get dashboardDueToday;

  /// No description provided for @dashboardDue3Days.
  ///
  /// In uz, this message translates to:
  /// **'3 kun ichida'**
  String get dashboardDue3Days;

  /// No description provided for @dashboardInstallmentsSection.
  ///
  /// In uz, this message translates to:
  /// **'Bo\'lib to\'lash'**
  String get dashboardInstallmentsSection;

  /// No description provided for @dashboardProjectsSection.
  ///
  /// In uz, this message translates to:
  /// **'Loyihalar'**
  String get dashboardProjectsSection;

  /// No description provided for @dashboardInProgress.
  ///
  /// In uz, this message translates to:
  /// **'Jarayonda'**
  String get dashboardInProgress;

  /// No description provided for @dashboardFrozen.
  ///
  /// In uz, this message translates to:
  /// **'Muzlatilgan'**
  String get dashboardFrozen;

  /// No description provided for @dashboardCompleted.
  ///
  /// In uz, this message translates to:
  /// **'Tugallangan'**
  String get dashboardCompleted;

  /// No description provided for @dashboardAddIncome.
  ///
  /// In uz, this message translates to:
  /// **'Kirim'**
  String get dashboardAddIncome;

  /// No description provided for @dashboardAddExpense.
  ///
  /// In uz, this message translates to:
  /// **'Chiqim'**
  String get dashboardAddExpense;

  /// No description provided for @dashboardAddPartner.
  ///
  /// In uz, this message translates to:
  /// **'Hamkor'**
  String get dashboardAddPartner;

  /// No description provided for @dashboardTutorials.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'llanmalar'**
  String get dashboardTutorials;

  /// No description provided for @dashboardSubscriptionGrace.
  ///
  /// In uz, this message translates to:
  /// **'Obunangiz muddati tugash arafasida'**
  String get dashboardSubscriptionGrace;

  /// No description provided for @dashboardSubscriptionReadOnly.
  ///
  /// In uz, this message translates to:
  /// **'Faqat ko\'rish rejimi'**
  String get dashboardSubscriptionReadOnly;

  /// No description provided for @dashboardSubscriptionArchived.
  ///
  /// In uz, this message translates to:
  /// **'Obuna talab qilinadi'**
  String get dashboardSubscriptionArchived;

  /// No description provided for @dashboardUpdateSubscription.
  ///
  /// In uz, this message translates to:
  /// **'Yangilash'**
  String get dashboardUpdateSubscription;

  /// No description provided for @dashboardViewPlans.
  ///
  /// In uz, this message translates to:
  /// **'Tariflar'**
  String get dashboardViewPlans;

  /// No description provided for @partnersTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hamkorlar'**
  String get partnersTitle;

  /// No description provided for @partnersSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Ism, telefon bo\'yicha qidirish'**
  String get partnersSearchHint;

  /// No description provided for @partnersFilterTitle.
  ///
  /// In uz, this message translates to:
  /// **'Filtr'**
  String get partnersFilterTitle;

  /// No description provided for @partnersSortTitle.
  ///
  /// In uz, this message translates to:
  /// **'Saralash'**
  String get partnersSortTitle;

  /// No description provided for @partnersStatusAll.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get partnersStatusAll;

  /// No description provided for @partnersStatusCreditor.
  ///
  /// In uz, this message translates to:
  /// **'Xaqdorlar'**
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
  /// **'Hamkor qo\'shish'**
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

  /// No description provided for @partnersEmptyDescription.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha bu bo\'limda ma\'lumot yo\'q.'**
  String get partnersEmptyDescription;

  /// No description provided for @partnersDeletedLabel.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirilgan'**
  String get partnersDeletedLabel;

  /// No description provided for @partnersCreditor.
  ///
  /// In uz, this message translates to:
  /// **'Xaqdor'**
  String get partnersCreditor;

  /// No description provided for @partnersDebtor.
  ///
  /// In uz, this message translates to:
  /// **'Qarzdor'**
  String get partnersDebtor;

  /// No description provided for @partnersClosed.
  ///
  /// In uz, this message translates to:
  /// **'Hisob-kitob yopiq'**
  String get partnersClosed;

  /// No description provided for @partnersInstallmentRemaining.
  ///
  /// In uz, this message translates to:
  /// **'Bo\'lib to\'lash'**
  String get partnersInstallmentRemaining;

  /// No description provided for @partnersConfirmDelete.
  ///
  /// In uz, this message translates to:
  /// **'Hamkorni o\'chirmoqchimisiz?'**
  String get partnersConfirmDelete;

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

  /// No description provided for @partnerDetailInstallmentsTab.
  ///
  /// In uz, this message translates to:
  /// **'Bo\'lib to\'lash'**
  String get partnerDetailInstallmentsTab;

  /// No description provided for @partnerDetailSmsTab.
  ///
  /// In uz, this message translates to:
  /// **'SMS tarixi'**
  String get partnerDetailSmsTab;

  /// No description provided for @partnerDetailIncome.
  ///
  /// In uz, this message translates to:
  /// **'Kirim'**
  String get partnerDetailIncome;

  /// No description provided for @partnerDetailExpense.
  ///
  /// In uz, this message translates to:
  /// **'Chiqim'**
  String get partnerDetailExpense;

  /// No description provided for @partnerDetailBalance.
  ///
  /// In uz, this message translates to:
  /// **'Balans'**
  String get partnerDetailBalance;

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

  /// No description provided for @walletIncomeTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kirim'**
  String get walletIncomeTitle;

  /// No description provided for @walletExpenseTitle.
  ///
  /// In uz, this message translates to:
  /// **'Chiqim'**
  String get walletExpenseTitle;

  /// No description provided for @walletAmountLabel.
  ///
  /// In uz, this message translates to:
  /// **'Summa'**
  String get walletAmountLabel;

  /// No description provided for @walletDescriptionLabel.
  ///
  /// In uz, this message translates to:
  /// **'Izoh'**
  String get walletDescriptionLabel;

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

  /// No description provided for @walletAttachFile.
  ///
  /// In uz, this message translates to:
  /// **'Fayl biriktirish'**
  String get walletAttachFile;

  /// No description provided for @walletSmsWillBeSent.
  ///
  /// In uz, this message translates to:
  /// **'Hamkorga SMS xabar yuboriladi'**
  String get walletSmsWillBeSent;

  /// No description provided for @walletSmsLimitReached.
  ///
  /// In uz, this message translates to:
  /// **'SMS limiti tugagan — xabar yuborilmaydi'**
  String get walletSmsLimitReached;

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

  /// No description provided for @walletCancelReasonHint.
  ///
  /// In uz, this message translates to:
  /// **'Kamida 3 belgi'**
  String get walletCancelReasonHint;

  /// No description provided for @walletCancelledLabel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilingan'**
  String get walletCancelledLabel;

  /// No description provided for @walletCancelConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Bu amalni keyin qaytarib bo\'lmaydi.'**
  String get walletCancelConfirm;

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

  /// No description provided for @profileActivityLog.
  ///
  /// In uz, this message translates to:
  /// **'Faollik jurnali'**
  String get profileActivityLog;

  /// No description provided for @profileNotifications.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get profileNotifications;

  /// No description provided for @profileCurrencyRates.
  ///
  /// In uz, this message translates to:
  /// **'Valyuta kurslari'**
  String get profileCurrencyRates;

  /// No description provided for @profileGuides.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'llanmalar'**
  String get profileGuides;

  /// No description provided for @profileSettings.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalar'**
  String get profileSettings;

  /// No description provided for @profileHelp.
  ///
  /// In uz, this message translates to:
  /// **'Yordam va aloqa'**
  String get profileHelp;

  /// No description provided for @profileTerms.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanish shartlari'**
  String get profileTerms;

  /// No description provided for @profilePrivacy.
  ///
  /// In uz, this message translates to:
  /// **'Maxfiylik siyosati'**
  String get profilePrivacy;

  /// No description provided for @profileAppVersion.
  ///
  /// In uz, this message translates to:
  /// **'Ilova versiyasi'**
  String get profileAppVersion;

  /// No description provided for @settingsLanguage.
  ///
  /// In uz, this message translates to:
  /// **'Til'**
  String get settingsLanguage;

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

  /// No description provided for @settingsPincode.
  ///
  /// In uz, this message translates to:
  /// **'Pincode'**
  String get settingsPincode;

  /// No description provided for @settingsBiometrics.
  ///
  /// In uz, this message translates to:
  /// **'Biometrika'**
  String get settingsBiometrics;

  /// No description provided for @navHome.
  ///
  /// In uz, this message translates to:
  /// **'Bosh sahifa'**
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

  /// No description provided for @emptyGenericDescription.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha bu bo\'limda ma\'lumot yo\'q.'**
  String get emptyGenericDescription;

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
