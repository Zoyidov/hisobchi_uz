// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'E-Hisob';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonEdit => 'Редактировать';

  @override
  String get commonApply => 'Применить';

  @override
  String get commonClear => 'Очистить';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonSearch => 'Поиск...';

  @override
  String get commonFilter => 'Фильтр';

  @override
  String get commonSort => 'Сортировка';

  @override
  String get commonSeeAll => 'Все';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonContinue => 'Продолжить';

  @override
  String get commonSkip => 'Пропустить';

  @override
  String get commonYes => 'Да';

  @override
  String get commonNo => 'Нет';

  @override
  String get commonConfirm => 'Подтвердить';

  @override
  String get commonLoading => 'Загрузка...';

  @override
  String get commonComingSoon => 'Скоро';

  @override
  String get commonRestore => 'Восстановить';

  @override
  String get commonShare => 'Поделиться';

  @override
  String get commonDownload => 'Скачать';

  @override
  String get commonCall => 'Позвонить';

  @override
  String get commonSms => 'SMS';

  @override
  String get commonReport => 'Отчёт';

  @override
  String get commonExcel => 'Экспорт в Excel';

  @override
  String get commonSettings => 'Настройки';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonDone => 'Готово';

  @override
  String get commonAll => 'Все';

  @override
  String get commonSaved => 'Сохранено';

  @override
  String get errorSessionExpired => 'Сессия истекла, войдите снова';

  @override
  String get errorOtherDevice => 'Вход выполнен с другого устройства';

  @override
  String get errorNoPermission => 'У вас нет прав для этого действия.';

  @override
  String get errorNoInternet => 'Нет подключения к интернету';

  @override
  String get errorServer => 'Ошибка сервера. Попробуйте позже';

  @override
  String get errorUnknown => 'Произошла непредвиденная ошибка';

  @override
  String get authPhoneTitle => 'Ваш номер телефона';

  @override
  String get authPhoneAgreement => 'Я согласен с условиями использования';

  @override
  String get authTermsLink => 'Условия использования';

  @override
  String get authOtpTitle => 'Введите 4-значный код, отправленный по SMS';

  @override
  String get authOtpResend => 'Отправить снова';

  @override
  String authOtpResendIn(String seconds) {
    return 'Повторно через $seconds';
  }

  @override
  String get authOtpInvalid => 'Неверный код';

  @override
  String get authOtpExpired => 'Срок действия кода истёк';

  @override
  String get authRegisterTitle => 'Регистрация';

  @override
  String get authNameLabel => 'Имя';

  @override
  String get authPasswordLabel => 'Пароль';

  @override
  String get authPasswordConfirmLabel => 'Повторите пароль';

  @override
  String get authRegisterButton => 'Зарегистрироваться';

  @override
  String get authLoginTitle => 'Вход';

  @override
  String get authLoginButton => 'Войти';

  @override
  String get authForgotPassword => 'Забыли пароль?';

  @override
  String get authResetPasswordTitle => 'Новый пароль';

  @override
  String get authNewPasswordLabel => 'Новый пароль';

  @override
  String get authPincodeTitle => 'Защитите приложение';

  @override
  String get authPincodeSubtitle => 'Создайте 4-значный PIN-код';

  @override
  String get authPincodeRepeat => 'Повторите PIN-код';

  @override
  String get authPincodeMismatch => 'PIN-коды не совпадают';

  @override
  String get authPincodeSkip => 'Позже';

  @override
  String get authPincodeEnter => 'Введите PIN-код';

  @override
  String get authPincodeForgot => 'Войти по паролю';

  @override
  String get authAccountSelectionTitle => 'В каком аккаунте вы работаете?';

  @override
  String get authOwnAccount => 'Мой аккаунт';

  @override
  String get authStaffOf => 'Как сотрудник';

  @override
  String authWorkingAs(String name) {
    return 'Вы работаете в аккаунте $name';
  }

  @override
  String get authSwitchAccount => 'Сменить';

  @override
  String get authLogout => 'Выйти';

  @override
  String get authLogoutConfirm => 'Вы хотите выйти из аккаунта?';

  @override
  String get authDeleteAccount => 'Удалить аккаунт';

  @override
  String get authDeleteAccountWarning =>
      'Все партнёры, транзакции, проекты и отчёты будут удалены. Это действие необратимо.';

  @override
  String get authBlockedTitle => 'Доступ ограничен';

  @override
  String get authSupport => 'Поддержка';

  @override
  String get authBiometricsReason => 'Подтвердите вход в приложение';

  @override
  String dashboardGreeting(String name) {
    return 'Здравствуйте, $name';
  }

  @override
  String get dashboardPartnersSection => 'Партнёры';

  @override
  String get dashboardOverdue => 'Просрочено';

  @override
  String get dashboardDueToday => 'Сегодня';

  @override
  String get dashboardDue3Days => 'В течение 3 дней';

  @override
  String get dashboardInstallmentsSection => 'Рассрочка';

  @override
  String get dashboardProjectsSection => 'Проекты';

  @override
  String get dashboardInProgress => 'В процессе';

  @override
  String get dashboardFrozen => 'Заморожено';

  @override
  String get dashboardCompleted => 'Завершено';

  @override
  String get dashboardAddIncome => 'Приход';

  @override
  String get dashboardAddExpense => 'Расход';

  @override
  String get dashboardAddPartner => 'Партнёр';

  @override
  String get dashboardTutorials => 'Обучение';

  @override
  String get dashboardSubscriptionGrace => 'Срок подписки истекает';

  @override
  String get dashboardSubscriptionReadOnly => 'Режим только просмотра';

  @override
  String get dashboardSubscriptionArchived => 'Требуется подписка';

  @override
  String get dashboardUpdateSubscription => 'Обновить';

  @override
  String get dashboardViewPlans => 'Тарифы';

  @override
  String get partnersTitle => 'Партнёры';

  @override
  String get partnersSearchHint => 'Поиск по имени, телефону';

  @override
  String get partnersFilterTitle => 'Фильтр';

  @override
  String get partnersSortTitle => 'Сортировка';

  @override
  String get partnersStatusAll => 'Все';

  @override
  String get partnersStatusCreditor => 'Должны нам';

  @override
  String get partnersStatusDebtor => 'Мы должны';

  @override
  String get partnersStatusOverdue => 'Просроченные должники';

  @override
  String get partnersAdd => 'Добавить партнёра';

  @override
  String get partnersEdit => 'Редактировать партнёра';

  @override
  String get partnersNameField => 'Имя';

  @override
  String get partnersPhoneField => 'Телефон';

  @override
  String get partnersAdditionalPhoneField => 'Доп. телефон';

  @override
  String get partnersMainCurrency => 'Основная валюта';

  @override
  String get partnersEmptyTitle => 'Партнёры не найдены';

  @override
  String get partnersEmptyDescription => 'Здесь пока нет данных.';

  @override
  String get partnersDeletedLabel => 'Удалён';

  @override
  String get partnersCreditor => 'Должен нам';

  @override
  String get partnersDebtor => 'Мы должны';

  @override
  String get partnersClosed => 'Расчёт закрыт';

  @override
  String get partnersInstallmentRemaining => 'Рассрочка';

  @override
  String get partnersConfirmDelete => 'Удалить этого партнёра?';

  @override
  String get partnersSortLastActivity => 'Последняя активность';

  @override
  String get partnersSortDebtorUzs => 'Должники UZS';

  @override
  String get partnersSortDebtorUsd => 'Должники USD';

  @override
  String get partnersSortCreditorUzs => 'Кредиторы UZS';

  @override
  String get partnersSortCreditorUsd => 'Кредиторы USD';

  @override
  String get partnerDetailTransactionsTab => 'Транзакции';

  @override
  String get partnerDetailInstallmentsTab => 'Рассрочка';

  @override
  String get partnerDetailSmsTab => 'История SMS';

  @override
  String get partnerDetailIncome => 'Приход';

  @override
  String get partnerDetailExpense => 'Расход';

  @override
  String get partnerDetailBalance => 'Баланс';

  @override
  String get partnerDetailSmsSettings => 'Настройки SMS';

  @override
  String get partnerDetailEmptyTransactions => 'Пока нет транзакций';

  @override
  String get walletIncomeTitle => 'Приход';

  @override
  String get walletExpenseTitle => 'Расход';

  @override
  String get walletAmountLabel => 'Сумма';

  @override
  String get walletDescriptionLabel => 'Описание';

  @override
  String get walletReturnDateLabel => 'Дата возврата';

  @override
  String get walletWeek1 => '1 неделя';

  @override
  String get walletWeek2 => '2 недели';

  @override
  String get walletMonth1 => '1 месяц';

  @override
  String get walletPickDate => 'Выбрать дату';

  @override
  String get walletAttachFile => 'Прикрепить файл';

  @override
  String get walletSmsWillBeSent => 'Партнёру будет отправлено SMS';

  @override
  String get walletSmsLimitReached =>
      'Лимит SMS исчерпан — сообщение не будет отправлено';

  @override
  String get walletSaveIncome => 'Сохранить приход';

  @override
  String get walletSaveExpense => 'Сохранить расход';

  @override
  String get walletCancelTransaction => 'Отменить транзакцию';

  @override
  String get walletCancelReasonLabel => 'Причина отмены';

  @override
  String get walletCancelReasonHint => 'Минимум 3 символа';

  @override
  String get walletCancelledLabel => 'Отменено';

  @override
  String get walletCancelConfirm => 'Это действие нельзя отменить.';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profilePersonalInfo => 'Личные данные';

  @override
  String get profileSubscription => 'Подписка и тарифы';

  @override
  String get profileSmsPackages => 'Пакеты SMS';

  @override
  String get profileStaff => 'Сотрудники';

  @override
  String get profileDocuments => 'Справочники';

  @override
  String get profileActivityLog => 'Журнал активности';

  @override
  String get profileNotifications => 'Уведомления';

  @override
  String get profileCurrencyRates => 'Курсы валют';

  @override
  String get profileGuides => 'Инструкции';

  @override
  String get profileSettings => 'Настройки';

  @override
  String get profileHelp => 'Помощь и поддержка';

  @override
  String get profileTerms => 'Условия использования';

  @override
  String get profilePrivacy => 'Политика конфиденциальности';

  @override
  String get profileAppVersion => 'Версия приложения';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsPincode => 'PIN-код';

  @override
  String get settingsBiometrics => 'Биометрия';

  @override
  String get navHome => 'Главная';

  @override
  String get navPartners => 'Партнёры';

  @override
  String get navProjects => 'Проекты';

  @override
  String get navReports => 'Отчёты';

  @override
  String get navProfile => 'Профиль';

  @override
  String get emptyGenericTitle => 'Данные не найдены';

  @override
  String get emptyGenericDescription => 'Здесь пока нет данных.';

  @override
  String get errorGenericTitle => 'Не удалось загрузить данные';

  @override
  String get errorGenericDescription =>
      'Проверьте интернет-соединение или повторите попытку.';
}
