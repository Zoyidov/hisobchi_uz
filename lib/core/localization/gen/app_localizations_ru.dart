// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Hisup';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonEdit => 'Редактировать';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonSearch => 'Поиск...';

  @override
  String get commonFilter => 'Фильтр';

  @override
  String get commonSort => 'Сортировка';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonContinue => 'Продолжить';

  @override
  String get commonRestore => 'Восстановить';

  @override
  String get commonCall => 'Позвонить';

  @override
  String get commonReport => 'Отчёт';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonAll => 'Все';

  @override
  String get commonSaved => 'Сохранено';

  @override
  String get errorSessionExpired => 'Сессия истекла, войдите снова';

  @override
  String get errorOtherDevice =>
      'В ваш аккаунт выполнен вход с другого устройства';

  @override
  String get errorNoPermission =>
      'У вас нет прав для выполнения этого действия.';

  @override
  String get errorNoInternet => 'Нет подключения к интернету';

  @override
  String get errorServer => 'Ошибка сервера. Попробуйте позже';

  @override
  String get errorUnknown => 'Произошла непредвиденная ошибка';

  @override
  String get authPhoneTitle => 'Ваш номер телефона';

  @override
  String get authTermsLink => 'Условия использования';

  @override
  String get authOtpResend => 'Отправить код повторно';

  @override
  String get authPasswordLabel => 'Пароль';

  @override
  String get authPasswordConfirmLabel => 'Подтвердите пароль';

  @override
  String get authRegisterButton => 'Зарегистрироваться';

  @override
  String get authLoginButton => 'Войти';

  @override
  String get authForgotPassword => 'Забыли пароль?';

  @override
  String get authNewPasswordLabel => 'Новый пароль';

  @override
  String get authPincodeRepeat => 'Повторите PIN-код';

  @override
  String get authPincodeMismatch => 'PIN-коды не совпадают. Введите снова';

  @override
  String get authPincodeSkip => 'Пропустить пока';

  @override
  String get authPincodeEnter => 'Введите PIN-код';

  @override
  String get authPincodeForgot => 'Забыли PIN-код?';

  @override
  String get authAccountSelectionTitle => 'В каком аккаунте работаете? 👋';

  @override
  String get authSwitchAccount => 'Сменить';

  @override
  String get authLogout => 'Выйти';

  @override
  String get authLogoutConfirm => 'Вы хотите выйти из аккаунта?';

  @override
  String get authDeleteAccount => 'Удалить аккаунт';

  @override
  String get authBlockedTitle => 'Доступ ограничен';

  @override
  String get authBiometricsReason => 'Подтвердите вход в приложение';

  @override
  String get dashboardCompleted => 'Завершён';

  @override
  String get dashboardAddPartner => 'Партнёр';

  @override
  String get partnersStatusCreditor => 'Кредиторы';

  @override
  String get partnersStatusDebtor => 'Должники';

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
  String get partnersAdditionalPhoneField => 'Дополнительный телефон';

  @override
  String get partnersMainCurrency => 'Основная валюта';

  @override
  String get partnersEmptyTitle => 'Партнёры не найдены';

  @override
  String get partnersCreditor => 'Кредитор';

  @override
  String get partnersDebtor => 'Должник';

  @override
  String get partnersSortLastActivity => 'Последняя активность';

  @override
  String get partnersSortDebtorUzs => 'Должник UZS';

  @override
  String get partnersSortDebtorUsd => 'Должник USD';

  @override
  String get partnersSortCreditorUzs => 'Кредитор UZS';

  @override
  String get partnersSortCreditorUsd => 'Кредитор USD';

  @override
  String get partnerDetailTransactionsTab => 'Транзакции';

  @override
  String get partnerDetailSmsTab => 'История SMS';

  @override
  String get partnerDetailSmsSettings => 'Настройки SMS';

  @override
  String get partnerDetailEmptyTransactions => 'Пока нет транзакций';

  @override
  String get walletAmountLabel => 'Сумма';

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
  String get walletSmsWillBeSent => 'Партнёру будет отправлено SMS';

  @override
  String get walletSaveIncome => 'Сохранить приход';

  @override
  String get walletSaveExpense => 'Сохранить расход';

  @override
  String get walletCancelTransaction => 'Отменить транзакцию';

  @override
  String get walletCancelReasonLabel => 'Причина отмены';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profilePersonalInfo => 'Личные данные';

  @override
  String get profileSubscription => 'Подписка и тарифы';

  @override
  String get profileSmsPackages => 'SMS-пакеты';

  @override
  String get profileStaff => 'Сотрудники';

  @override
  String get profileDocuments => 'Справочники';

  @override
  String get profileNotifications => 'Уведомления';

  @override
  String get profileSettings => 'Настройки';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsThemeSystem => 'Системная';

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
  String get errorGenericTitle => 'Не удалось загрузить данные';

  @override
  String get errorGenericDescription =>
      'Проверьте интернет или попробуйте ещё раз.';

  @override
  String get connectivityOffline => 'Нет интернета — показаны последние данные';

  @override
  String get connectivityRestored => 'Подключение восстановлено';

  @override
  String get dashboardOverdueLabel => 'Просрочено';

  @override
  String get docWorkTypeNotFound => 'Вид работы не найден';

  @override
  String get docWorkTypeAdd => 'Добавить вид работы';

  @override
  String get docWorkTypeEdit => 'Редактировать вид работы';

  @override
  String get docWorkTypeDeleteConfirm => 'Удалить вид работы?';

  @override
  String get docPositionNotFound => 'Должность не найдена';

  @override
  String get docPositionAdd => 'Добавить должность';

  @override
  String get docPositionEdit => 'Редактировать должность';

  @override
  String get docPositionDeleteConfirm => 'Удалить должность?';

  @override
  String get installmentStepDetails => 'Данные';

  @override
  String get walletExpenseAmount => 'Сумма расхода';

  @override
  String get walletIncomeAmount => 'Сумма прихода';

  @override
  String get staffStepPhone => 'Телефон';

  @override
  String get errorValidation => 'Во введённых данных есть ошибка';

  @override
  String get errorTooManyRequests =>
      'Слишком много попыток. Подождите немного и повторите.';

  @override
  String errorWithDetails(Object details) {
    return 'Ошибка: $details';
  }

  @override
  String get errorRequestCancelled => 'Запрос отменён';

  @override
  String get errorGeneric => 'Произошла ошибка';

  @override
  String get dateToday => 'Сегодня';

  @override
  String get dateYesterday => 'Вчера';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня назад',
      many: '$count дней назад',
      few: '$count дня назад',
      one: '$count день назад',
    );
    return '$_temp0';
  }

  @override
  String get validationRequired => 'Это поле обязательно для заполнения';

  @override
  String get validationPhoneRequired => 'Введите номер телефона';

  @override
  String get validationPhoneInvalid =>
      'Номер телефона должен состоять из 9 цифр';

  @override
  String validationMinLength(int min) {
    String _temp0 = intl.Intl.pluralLogic(
      min,
      locale: localeName,
      other: 'Введите не менее $min символа',
      many: 'Введите не менее $min символов',
      few: 'Введите не менее $min символов',
      one: 'Введите не менее $min символа',
    );
    return '$_temp0';
  }

  @override
  String get validationPasswordMinLength =>
      'Пароль должен содержать не менее 6 символов';

  @override
  String get validationPasswordsMismatch => 'Пароли не совпадают';

  @override
  String get validationAmountRequired => 'Введите сумму';

  @override
  String get validationAmountPositive => 'Сумма должна быть больше 0';

  @override
  String get balanceNet => 'Чистый баланс';

  @override
  String get commonIncome => 'Приход';

  @override
  String get commonExpense => 'Расход';

  @override
  String get balanceInstallmentRemaining => 'Остаток по рассрочке';

  @override
  String get subscriptionBannerGrace => 'Срок вашей подписки скоро истекает';

  @override
  String get subscriptionBannerRenew => 'Продлить';

  @override
  String get subscriptionBannerReadOnly => 'Режим только для просмотра';

  @override
  String get subscriptionBannerPlans => 'Тарифы';

  @override
  String get subscriptionBannerRequired => 'Требуется подписка';

  @override
  String get fileCameraGalleryError =>
      'Не удалось открыть камеру или галерею. Проверьте разрешения устройства.';

  @override
  String get fileOpenError => 'Не удалось открыть файл. Попробуйте ещё раз.';

  @override
  String get fileAttach => 'Прикрепить файл';

  @override
  String get fileCamera => 'Камера';

  @override
  String get fileGallery => 'Галерея';

  @override
  String get fileFile => 'Файл';

  @override
  String get fileTooLarge => 'Размер файла не должен превышать 5 МБ';

  @override
  String get fileImage => 'Изображение';

  @override
  String get fileRemoveImage => 'Удалить изображение';

  @override
  String fileRetryUpload(Object name) {
    return '$name · Повторить';
  }

  @override
  String fileAttachedFiles(int count) {
    return 'Прикреплённые файлы ($count)';
  }

  @override
  String get fileOpenImage => 'Открыть изображение';

  @override
  String get fileOpenFile => 'Открыть файл';

  @override
  String fileNumbered(Object id) {
    return 'Файл #$id';
  }

  @override
  String get fileImageLoadRetry => 'Изображение не загрузилось. Повторить';

  @override
  String get commonConfirmContinue => 'Да, продолжить';

  @override
  String commonSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выбрано $count',
      many: 'Выбрано $count',
      few: 'Выбрано $count',
      one: 'Выбран $count',
    );
    return '$_temp0';
  }

  @override
  String get commonSelect => 'Выбрать';

  @override
  String get activityActionCancelled => 'отменил(а)';

  @override
  String get activityActionDeleted => 'удалил(а)';

  @override
  String get activityModelInstallmentPlan => 'план рассрочки';

  @override
  String get activityLogTitle => 'Журнал активности';

  @override
  String get activityLogFilterByAction => 'Фильтр по действию';

  @override
  String get activityLogEmpty => 'Активность не найдена';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationsEmpty => 'Уведомлений нет';

  @override
  String get authAccountsLoadError =>
      'Не удалось загрузить данные аккаунта. Попробуйте ещё раз.';

  @override
  String get authAccountSelectionBadge => 'ВЫБОР АККАУНТА 🏢';

  @override
  String get authAccountSelectionSubtitle =>
      'Выберите место работы как сотрудник или войдите в свой бизнес-аккаунт.';

  @override
  String get authAccountsLoading => 'Загрузка данных аккаунта...';

  @override
  String get commonReload => 'Обновить';

  @override
  String get authAccountOpening => 'Открытие аккаунта...';

  @override
  String get authOpenOwnBusiness => 'Открыть мой бизнес-аккаунт';

  @override
  String get authOwnerBadge => 'ОСНОВНОЙ • ВЛАДЕЛЕЦ';

  @override
  String get authOwnerDescription => 'Ваш бизнес и полный учёт';

  @override
  String get authStaffAccountsHeader => 'АККАУНТЫ, ПРИВЯЗАННЫЕ КАК СОТРУДНИК';

  @override
  String get authStaffAccountDescription => 'Учёт привязанной компании';

  @override
  String get authAccountsIsolated =>
      'Каждый аккаунт ведётся изолированно и безопасно';

  @override
  String get forceUpdateBadge => 'ДОСТУПНА НОВАЯ ВЕРСИЯ • UPDATE';

  @override
  String get forceUpdateTitle => 'Необходимо обновить приложение';

  @override
  String get forceUpdateDescription =>
      'В Hisup появились новые финансовые возможности, улучшенная безопасность и высокая скорость. Обновите приложение, чтобы продолжить.';

  @override
  String get forceUpdateFastTitle => 'Быстрая работа';

  @override
  String get forceUpdateFastDescription =>
      'Обмен данными значительно оптимизирован';

  @override
  String get forceUpdateSecurityTitle => 'Протоколы безопасности';

  @override
  String get forceUpdateSecurityDescription =>
      'Обновлённая система шифрования банковского уровня';

  @override
  String get forceUpdateButton => 'Обновить приложение';

  @override
  String get authSecureFooter =>
      '256-битное шифрование • Данные полностью защищены';

  @override
  String get authSmsSending => 'Отправка SMS-кода...';

  @override
  String get authPleaseWait => 'Пожалуйста, подождите';

  @override
  String get authCodeNotSent => 'Код не отправлен';

  @override
  String get errorUnknownRetry => 'Неизвестная ошибка. Попробуйте ещё раз.';

  @override
  String get authLoginHeading => 'Вход в аккаунт 👋';

  @override
  String get authLoginSubtitle => 'Введите ваш пароль, чтобы продолжить.';

  @override
  String get commonChange => 'Изменить';

  @override
  String get authPasswordHint => 'Введите пароль';

  @override
  String get authSecureFooterAll =>
      '256-битное шифрование • Все данные защищены';

  @override
  String get authOtpBadge => 'ШАГ БЕЗОПАСНОСТИ';

  @override
  String get authOtpHeading => 'Код подтверждения 🔐';

  @override
  String get authOtpSubtitle =>
      'Введите 4-значный SMS-код, отправленный на номер:';

  @override
  String get authOtpVerifying => 'Проверка кода...';

  @override
  String get authOtpResendInPrefix => 'Отправить код повторно:';

  @override
  String get authOtpDoNotShare => 'Никому не сообщайте SMS-код';

  @override
  String get authPhoneHeading => 'Давайте начнём! 👋';

  @override
  String get authPhoneSubtitle =>
      'Введите номер телефона, чтобы войти в аккаунт или подключить новый бизнес.';

  @override
  String get authPhoneLabel => 'Номер телефона';

  @override
  String get authPhoneValid => 'Верный формат';

  @override
  String get authAgreementPrefix => 'Я';

  @override
  String get authTermsBody =>
      'Используя платформу Hisup, вы соглашаетесь с прозрачностью всех финансовых операций, требованиями безопасности и правилами обслуживания.';

  @override
  String get authAgreementAnd => 'и';

  @override
  String get authPrivacyLink => 'Политика конфиденциальности';

  @override
  String get authPrivacyBody =>
      'Ваши персональные данные и финансовые отчёты надёжно защищены протоколами безопасности SSL 256 бит и не передаются третьим лицам.';

  @override
  String get authAgreementSuffix => 'полностью принимаю';

  @override
  String get commonGotIt => 'Понятно';

  @override
  String authHello(Object name) {
    return 'Привет, $name!';
  }

  @override
  String get authWelcome => 'Добро пожаловать!';

  @override
  String authPinWrongAttempts(Object attempts) {
    return 'Неверный PIN. Осталось попыток: $attempts';
  }

  @override
  String get authSecureEntry => 'Безопасный вход';

  @override
  String get authPincodeCreate => 'Создайте новый PIN-код';

  @override
  String get authRegisterBadge => 'НОВЫЙ ПРОФИЛЬ';

  @override
  String get authRegisterHeading => 'Регистрация ✨';

  @override
  String get authRegisterSubtitle =>
      'Создайте личный профиль в бизнес-системе Hisup.';

  @override
  String get authFullNameLabel => 'Ваше полное имя';

  @override
  String get authFullNameHint => 'Например: Алишер Усмонов';

  @override
  String get authPasswordMinHint => 'Минимум 6 символов';

  @override
  String get authPasswordRepeatHint => 'Введите пароль ещё раз';

  @override
  String get authResetBadge => 'ВОССТАНОВЛЕНИЕ ПАРОЛЯ';

  @override
  String get authResetHeading => 'Установка нового пароля 🔑';

  @override
  String get authResetSubtitle =>
      'Для безопасности аккаунта введите новый надёжный пароль.';

  @override
  String get authSaveAndLogin => 'Сохранить и войти';

  @override
  String get splashTagline => 'Управление бизнесом и финансами';

  @override
  String get splashSecure => 'Безопасная и защищённая система';

  @override
  String get dueQarzExpired => 'Просроченные долги';

  @override
  String get dueQarzToday => 'Срок сегодня';

  @override
  String get dueIn3Days => 'В течение 3 дней';

  @override
  String get dueInstallmentExpired => 'Просрочено (рассрочка)';

  @override
  String get dueInstallmentToday => 'Сегодня (рассрочка)';

  @override
  String get dueInstallment3Days => 'В течение 3 дней (рассрочка)';

  @override
  String get dueEmpty => 'В этом разделе нет данных';

  @override
  String get dashboardAddProject => 'Проект';

  @override
  String get greetingMorning => 'Доброе утро,';

  @override
  String get greetingDay => 'Добрый день,';

  @override
  String get greetingEvening => 'Добрый вечер,';

  @override
  String get greetingNight => 'Доброй ночи,';

  @override
  String get dashboardOpenProfile => 'Открыть профиль';

  @override
  String get hisupLogoLabel => 'Логотип Hisup';

  @override
  String get dashboardTitle => 'Панель управления';

  @override
  String notificationsUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count непрочитанного уведомления',
      many: '$count непрочитанных уведомлений',
      few: '$count непрочитанных уведомления',
      one: '$count непрочитанное уведомление',
    );
    return '$_temp0';
  }

  @override
  String get dashboardHeroTitle => 'Расчёты под контролем';

  @override
  String dashboardOverduePayments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count просроченного платежа',
      many: '$count просроченных платежей',
      few: '$count просроченных платежа',
      one: '$count просроченный платёж',
    );
    return '$_temp0';
  }

  @override
  String get dashboardHeroSubtitle =>
      'Управляйте проектами и платежами в одном месте';

  @override
  String get dashboardTodayDebts => 'Долги на сегодня';

  @override
  String get dashboardPartnersDebt => 'Долги партнёров';

  @override
  String get commonInstallment => 'Рассрочка';

  @override
  String get dueToday => 'Сегодня';

  @override
  String get dashboardPaymentsControl => 'Контроль платежей';

  @override
  String get projectStatusInProgress => 'В процессе';

  @override
  String get projectStatusFrozen => 'Заморожен';

  @override
  String get projectStatusCompleted => 'Завершён';

  @override
  String dashboardProjectsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count проекта',
      many: '$count проектов',
      few: '$count проекта',
      one: '$count проект',
    );
    return '$_temp0';
  }

  @override
  String get dashboardProjectsEmpty =>
      'Добавьте первый проект и отслеживайте работу здесь.';

  @override
  String get tutorialOpenError =>
      'Не удалось открыть руководство. Попробуйте позже.';

  @override
  String tutorialsCount(int count) {
    return 'Руководства ($count)';
  }

  @override
  String get currencySelectTitle => 'Выберите валюту';

  @override
  String get docCostTypes => 'Типы расходов';

  @override
  String get commonAdd => 'Добавить';

  @override
  String get docCostTypeNotFound => 'Тип расхода не найден';

  @override
  String get docCostTypeAdd => 'Добавить тип расхода';

  @override
  String get docWorkerAssigned => 'Привязывается работник';

  @override
  String get docSystem => 'Системный';

  @override
  String get commonDeleted => 'Удалён';

  @override
  String get docCostTypeDeleteConfirm => 'Удалить тип расхода?';

  @override
  String get commonIrreversible => 'Это действие нельзя будет отменить.';

  @override
  String get docCostTypeEdit => 'Редактировать тип расхода';

  @override
  String get commonName => 'Название';

  @override
  String get commonDescriptionOptional => 'Описание (необязательно)';

  @override
  String get docCurrencyRates => 'Курсы валют';

  @override
  String get docRatesLoadError => 'Не удалось загрузить курсы';

  @override
  String get docRatesEmpty => 'Курсы не найдены';

  @override
  String get docConverter => 'Конвертер';

  @override
  String get docReferenceBooks => 'Справочники';

  @override
  String get docWorkTypes => 'Виды работ';

  @override
  String get docWorkType => 'Вид работы';

  @override
  String get docPositions => 'Должности';

  @override
  String get docPosition => 'Должность';

  @override
  String get docWorkers => 'Работники';

  @override
  String get docWorkerNotFound => 'Работник не найден';

  @override
  String get docWorkerAdd => 'Добавить работника';

  @override
  String get docWorkerDeleteConfirm => 'Удалить работника?';

  @override
  String get docWorkerEdit => 'Редактировать работника';

  @override
  String get docSelectPosition => 'Выберите должность';

  @override
  String get commonNotSelected => 'Не выбрано';

  @override
  String installmentClosesPartFully(Object number) {
    return 'Полностью закрывает $number-ю часть';
  }

  @override
  String installmentClosesPartPartially(Object number) {
    return 'Частично закрывает $number-ю часть';
  }

  @override
  String get installmentValidationTotalPositive =>
      'Общая сумма должна быть больше 0.';

  @override
  String get installmentValidationAdvanceLess =>
      'Сумма аванса должна быть меньше общей суммы.';

  @override
  String get installmentValidationMinPartsWithAdvance =>
      'С авансом должна быть минимум 1 часть.';

  @override
  String get installmentValidationMinPartsNoAdvance =>
      'Без аванса должно быть минимум 2 части.';

  @override
  String get installmentValidationStartDatePast =>
      'Дата начала не может быть раньше сегодняшней.';

  @override
  String get installmentValidationPartPositive =>
      'Сумма каждой части должна быть больше 0.';

  @override
  String get installmentValidationEnterMinPartsWithAdvance =>
      'С авансом нужно указать минимум 1 часть.';

  @override
  String get installmentValidationEnterMinParts =>
      'Нужно указать минимум 2 части.';

  @override
  String get installmentValidationPartsSum =>
      'Сумма частей должна равняться общей сумме.';

  @override
  String get installmentValidationPaymentDatePast =>
      'Дата платежа не может быть раньше сегодняшней.';

  @override
  String get fileWaitForUploads => 'Дождитесь загрузки файлов.';

  @override
  String get installmentCancelPlan => 'Отменить план';

  @override
  String get commonPaid => 'Оплачено';

  @override
  String get commonRemaining => 'Осталось';

  @override
  String get installmentSchedule => 'График платежей';

  @override
  String installmentStagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count этапа',
      many: '$count этапов',
      few: '$count этапа',
      one: '$count этап',
    );
    return '$_temp0';
  }

  @override
  String get installmentReceivePayment => 'Принять платёж';

  @override
  String get installmentPaymentHistory => 'История платежей';

  @override
  String get installmentCancelPayment => 'Отменить платёж';

  @override
  String get errorLoadShort => 'Не удалось загрузить';

  @override
  String get installmentNoPayments => 'Платежей нет';

  @override
  String installmentReceivedBy(Object name) {
    return 'Принял(а): $name';
  }

  @override
  String get commonCancelled => 'Отменено';

  @override
  String get installmentRemainingColon => 'Осталось:';

  @override
  String get installmentNextPart => 'Следующая часть';

  @override
  String get installmentAllRemaining => 'Весь оставшийся долг';

  @override
  String get commonNote => 'Комментарий';

  @override
  String get installmentCashHint => 'Наличные';

  @override
  String get commonDate => 'Дата';

  @override
  String get installmentThisPayment => 'Этот платёж:';

  @override
  String get installmentAcceptPayment => 'Принять платёж';

  @override
  String get installmentPaymentExceeds =>
      'Сумма платежа не должна превышать оставшийся долг.';

  @override
  String get installmentPlanCreated => 'План создан';

  @override
  String get installmentTitle => 'Рассрочка';

  @override
  String installmentStepOf3(Object step) {
    return 'Шаг $step из 3';
  }

  @override
  String get installmentStepSchedule => 'Тип графика';

  @override
  String get installmentStepDistribution => 'Распределение';

  @override
  String get installmentEnterAmount => 'Введите сумму';

  @override
  String get installmentStep1Title => 'Шаг 1 • Основные данные';

  @override
  String get installmentClient => 'Клиент';

  @override
  String get installmentAmountAndCurrency => 'Сумма и валюта';

  @override
  String get installmentCurrencyType => 'Тип валюты';

  @override
  String get currencyUzs => 'Узбекский сум';

  @override
  String get currencyUsd => 'Доллар США';

  @override
  String get commonNoteOptional => 'Комментарий (необязательно)';

  @override
  String get installmentNoteHint => 'Можете указать подробности...';

  @override
  String get installmentDocumentsOptional => 'Документы (необязательно)';

  @override
  String get installmentStep2Title => 'Шаг 2 • Тип графика';

  @override
  String get installmentEqualSchedule => 'Равными частями';

  @override
  String get installmentFreeSchedule => 'Свободный график';

  @override
  String get installmentEqualDescription =>
      'Укажите дату начала и количество частей. Система автоматически рассчитает равную сумму для каждой части.';

  @override
  String get installmentFreeDescription =>
      'Укажите сумму и дату для каждой части отдельно. Полная гибкость и контроль.';

  @override
  String get installmentStep3Equal => 'Шаг 3 • Равными частями';

  @override
  String get installmentStep3Free => 'Шаг 3 • Свободный график';

  @override
  String get installmentDistributionCalc => 'Расчёт распределения';

  @override
  String get installmentPaymentTable => 'Таблица платежей';

  @override
  String get installmentReviewPlan => 'Проверьте план';

  @override
  String installmentTotalLine(Object amount, Object currency) {
    return 'Итого: $amount $currency\n';
  }

  @override
  String installmentPerPartFormula(
    Object amount,
    Object currency,
    Object count,
  ) {
    return '$amount $currency ÷ $count частей';
  }

  @override
  String get installmentAdvance => 'Первоначальный взнос';

  @override
  String get installmentSetAdvance => 'Указать сумму аванса';

  @override
  String get installmentFirstPartDate => 'Дата первой части';

  @override
  String get installmentFirstPaymentDate => 'Дата первого платежа';

  @override
  String get installmentRemainingParts => 'Оставшиеся части';

  @override
  String get installmentPartsCount => 'Количество частей';

  @override
  String commonCountShort(Object count) {
    return '$count шт.';
  }

  @override
  String get installmentFullyDistributed => 'Полностью распределено';

  @override
  String get installmentAmountExceeded => 'Сумма превышена';

  @override
  String get installmentDistributionLeft => 'Остаток распределения';

  @override
  String installmentPlannedTotal(Object amount, Object currency) {
    return 'Всего запланировано $amount $currency.';
  }

  @override
  String installmentReduceBy(Object amount, Object currency) {
    return 'Уменьшите на $amount $currency.';
  }

  @override
  String installmentRemainingDistribute(Object amount, Object currency) {
    return 'Осталось: $amount $currency. Распределите всю сумму.';
  }

  @override
  String get installmentAddPart => 'Добавить часть';

  @override
  String get installmentStatusActive => 'Активна';

  @override
  String get installmentStatusClosed => 'Закрыта';

  @override
  String installmentPartsCountShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count части',
      many: '$count частей',
      few: '$count части',
      one: '$count часть',
    );
    return '$_temp0';
  }

  @override
  String get installmentAdvanceAmount => 'Сумма аванса';

  @override
  String installmentPartAmount(Object number) {
    return 'Сумма $number-й части';
  }

  @override
  String get installmentPaymentDate => 'Дата платежа';

  @override
  String get installmentRemovePart => 'Удалить часть';

  @override
  String get installmentNoPlans => 'Нет планов рассрочки';

  @override
  String get installmentNoPlansDescription =>
      'Создайте план, чтобы разделить крупную сумму на части.';

  @override
  String get installmentCreatePlan => 'Создать план';

  @override
  String get installmentCreatePlanPlus => '+ Создать план';

  @override
  String get commonExcelShort => 'Excel';

  @override
  String get partnerSmsSettingShort => 'Настройки SMS';

  @override
  String get partnerAccountUzs => 'Счёт в узбекских сумах';

  @override
  String get partnerAccountUsd => 'Счёт в долларах США';

  @override
  String get commonFilterByDate => 'Фильтр по дате';

  @override
  String get commonDeletedToast => 'Удалено';

  @override
  String get partnerNew => 'Новый партнёр';

  @override
  String get partnerUpdateData => 'Обновление данных';

  @override
  String get partnerEnterData => 'Введите данные партнёра';

  @override
  String get partnerNameHint => 'Имя партнёра или название организации';

  @override
  String get commonOptional => 'Необязательно';

  @override
  String get commonSaveChanges => 'Сохранить изменения';

  @override
  String get partnersAddButton => 'Добавить партнёра';

  @override
  String get fileWaitThenSave => 'Дождитесь загрузки файла, затем сохраните.';

  @override
  String get partnerLimitReached => 'Лимит исчерпан';

  @override
  String get commonViewPlans => 'Посмотреть тарифы';

  @override
  String get partnerSmsSettingsLoadError => 'Не удалось загрузить настройки';

  @override
  String get partnerSmsService => 'SMS-сервис';

  @override
  String get partnerSmsOnIncome => 'SMS при приходе';

  @override
  String get partnerSmsOnExpense => 'SMS при расходе';

  @override
  String get partnerSmsRemindBefore => 'Напоминать до срока';

  @override
  String commonDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0';
  }

  @override
  String get partnerSmsRemindOnDue => 'Напоминать в день срока';

  @override
  String get partnerSmsAfterDue => 'После срока';

  @override
  String get partnerSmsSendTime => 'Время отправки SMS';

  @override
  String get partnersClientsTitle => 'Клиенты';

  @override
  String get partnersClientsSubtitle => 'Ваши клиенты и расчёты';

  @override
  String get partnersAddClient => 'Добавить нового клиента';

  @override
  String get partnersSearchNamePhone => 'Имя или телефон';

  @override
  String get partnersExportExcel => 'Скачать отчёт Excel';

  @override
  String partnersSortTooltip(Object sort) {
    return 'Сортировка: $sort';
  }

  @override
  String get partnersClientsEmpty => 'Клиенты не найдены';

  @override
  String get partnersEmptyFiltered => 'Измените поиск или выбранный фильтр.';

  @override
  String get partnersEmptyStart => 'Добавьте партнёра и начните вести расчёты.';

  @override
  String get partnersSortDebtorUzsDot => 'Должник · UZS';

  @override
  String get partnersSortDebtorUsdDot => 'Должник · USD';

  @override
  String get partnersSortCreditorUzsDot => 'Кредитор · UZS';

  @override
  String get partnersSortCreditorUsdDot => 'Кредитор · USD';

  @override
  String get walletEditExpense => 'Редактировать расход';

  @override
  String get walletAdditionalInfo => 'Дополнительная информация';

  @override
  String get walletNoteHint => 'Кратко о платеже';

  @override
  String get walletRemoveDate => 'Удалить дату';

  @override
  String get commonSaving => 'Сохранение…';

  @override
  String get exportPreparing => 'Подготовка файла...';

  @override
  String get exportPleaseWait => 'Пожалуйста, подождите';

  @override
  String get exportShareError => 'Ошибка при отправке файла';

  @override
  String get exportDownloadError => 'Ошибка при загрузке';

  @override
  String get partnersClosedShort => 'Закрыт';

  @override
  String get partnerInstallmentPrefix => 'Рассрочка:';

  @override
  String get partnersClientActions => 'Действия с клиентом';

  @override
  String get commonCallAction => 'Позвонить';

  @override
  String get commonWriteSms => 'Написать SMS';

  @override
  String get commonOpenDetails => 'Открыть подробности';

  @override
  String get commonPhoneAppError => 'Не удалось открыть приложение «Телефон»';

  @override
  String get partnersClientsLoading => 'Загрузка клиентов';

  @override
  String get partnersSelect => 'Выберите партнёра';

  @override
  String get partnersSearchByNamePhone => 'Поиск по имени или телефону';

  @override
  String get partnersSearchChange => 'Измените имя или телефон для поиска.';

  @override
  String get partnersLoading => 'Загрузка партнёров';

  @override
  String get partnerSmsHistoryEmpty => 'История SMS пуста';

  @override
  String get walletReasonClientRejected => 'Клиент отказался от платежа';

  @override
  String get walletReasonWrongAmount => 'Указана неверная сумма';

  @override
  String get walletReasonDuplicate => 'Повторная (дубликат) запись';

  @override
  String get walletCancelRecalc => 'Это действие пересчитает баланс партнёра';

  @override
  String get walletQuickReason => 'Выберите быструю причину:';

  @override
  String get walletReasonOrNote => 'Комментарий или точная причина:';

  @override
  String get walletCancelReasonHintLong =>
      'Укажите причину отмены (минимум 3 символа)...';

  @override
  String get walletReasonMin3 => 'Требуется минимум 3 символа';

  @override
  String walletReasonMoreChars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Введите ещё $count символа',
      many: 'Введите ещё $count символов',
      few: 'Введите ещё $count символа',
      one: 'Введите ещё $count символ',
    );
    return '$_temp0';
  }

  @override
  String get walletReasonEnough => '✓ Причина достаточна';

  @override
  String get walletDeleteTransaction => 'Удалить транзакцию';

  @override
  String get walletDeleteConfirm =>
      'Вы действительно хотите полностью удалить эту транзакцию?';

  @override
  String get walletDeleteWarning =>
      'Это действие изменит баланс расчётов, и его нельзя будет отменить.';

  @override
  String get walletDeleteYes => 'Да, удалить';

  @override
  String get walletDeleteNo => 'Нет, отмена';

  @override
  String get dateFilterTitle => 'Сортировка по дате';

  @override
  String get dateFilterSubtitle => 'Выберите период транзакций';

  @override
  String get dateFilterAll => 'За всё время (сбросить фильтр)';

  @override
  String get dateFilterAllSubtitle => 'Все транзакции без ограничений';

  @override
  String get dateFilterThisMonth => 'Этот месяц';

  @override
  String get dateFilterLast7 => 'Последние 7 дней';

  @override
  String get dateFilterLastMonth => 'Прошлый месяц';

  @override
  String get dateFilterLast30 => 'Последние 30 дней';

  @override
  String get dateFilterCustom => 'Произвольный период...';

  @override
  String get dateFilterCustomSubtitle => 'Выбрать нужный период в календаре';

  @override
  String get receiptShareTitle => '🧾 ЭЛЕКТРОННАЯ КВИТАНЦИЯ ОБ ОПЛАТЕ — Hisup';

  @override
  String receiptShareAmount(Object sign, Object amount) {
    return 'Сумма: $sign$amount';
  }

  @override
  String receiptCommission(Object currency) {
    return 'Комиссия: 0 $currency (0%)';
  }

  @override
  String receiptSharePartner(Object name) {
    return 'Партнёр: $name';
  }

  @override
  String receiptSharePhone(Object phone) {
    return 'Телефон: $phone';
  }

  @override
  String receiptShareDateTime(Object date) {
    return 'Дата и время: $date';
  }

  @override
  String receiptShareCashier(Object name) {
    return 'Кассир / Ответственный: $name';
  }

  @override
  String receiptSharePurpose(Object text) {
    return 'Назначение платежа: $text';
  }

  @override
  String receiptShareReturnDate(Object date) {
    return 'Срок возврата: $date';
  }

  @override
  String receiptShareCancelReason(Object text) {
    return 'Причина отмены: $text';
  }

  @override
  String get receiptShareFooter =>
      'Платёжный документ Hisup по официальному банковскому стандарту';

  @override
  String get receiptShareError =>
      'Не удалось поделиться чеком. Попробуйте ещё раз.';

  @override
  String get receiptCopied => 'Данные чека скопированы полностью';

  @override
  String get receiptTitle => 'Чек об оплате';

  @override
  String get receiptBadge => 'ЭЛЕКТРОННАЯ КВИТАНЦИЯ';

  @override
  String get receiptCancelled => 'Платёж отменён';

  @override
  String get receiptPaidOut => 'Платёж успешно проведён';

  @override
  String get receiptReceived => 'Средства успешно получены';

  @override
  String get receiptRecipient => 'Получатель (партнёр)';

  @override
  String get receiptOperationType => 'Тип операции';

  @override
  String get receiptExpenseType => 'Расход (платёж)';

  @override
  String get receiptIncomeType => 'Приход (поступление)';

  @override
  String get receiptDateTime => 'Дата и время';

  @override
  String get receiptTransactionId => 'ID транзакции (RRN)';

  @override
  String get receiptIdCopied => 'ID скопирован';

  @override
  String get receiptAccountCurrency => 'Валюта счёта';

  @override
  String get currencyUsdFull => 'Доллар США (USD)';

  @override
  String get currencyUzsFull => 'Узбекский сум (UZS)';

  @override
  String get receiptCashier => 'Кассир / Ответственный';

  @override
  String get receiptReturnDate => 'Срок возврата';

  @override
  String get receiptPurpose => 'Назначение платежа (комментарий)';

  @override
  String get receiptCancelledPayment => 'Отменённый платёж';

  @override
  String get receiptConfirmed => 'Успешно подтверждён';

  @override
  String get receiptRegistered =>
      'Зарегистрировано в системе финансовой отчётности Hisup';

  @override
  String get receiptShare => 'Поделиться чеком';

  @override
  String walletReturnShort(Object date) {
    return 'Возврат: $date';
  }

  @override
  String walletEnteredBy(Object name) {
    return 'Внёс(ла): $name';
  }

  @override
  String get profileSaveName => 'Сохранить имя';

  @override
  String get profileChangePassword => 'Изменить пароль';

  @override
  String get profileChangePhone => 'Изменить телефон';

  @override
  String get profileOldPassword => 'Старый пароль';

  @override
  String get profileNewPhoneTitle => 'Новый номер телефона';

  @override
  String get profileNewPhone => 'Новый телефон';

  @override
  String get profilePhoneUpdated => 'Номер телефона обновлён';

  @override
  String get profileVerificationCode => 'Код подтверждения';

  @override
  String get profileOpenOwnAccount => 'Открыть свой аккаунт';

  @override
  String get profileSecurityPin => 'Безопасность и PIN-код';

  @override
  String get profileSecurityPinSubtitle => 'Включить или отключить PIN-код';

  @override
  String get profileOpenOwnAccountConfirm =>
      'Для вас будет открыт собственный бизнес-аккаунт на тарифе FREE. Продолжить?';

  @override
  String get profileOpenOwnAccountYes => 'Да, открыть';

  @override
  String get profileOwnAccountOpened => 'Ваш аккаунт открыт';

  @override
  String get authLogoutYes => 'Да, выйти';

  @override
  String get profileRoleOwner => 'Владелец';

  @override
  String get profileRoleStaff => 'Сотрудник';

  @override
  String profileVersion(Object version) {
    return 'Версия $version';
  }

  @override
  String get settingsPinEnabled => 'PIN-код успешно включён';

  @override
  String get settingsPinDisabled => 'PIN-код отключён';

  @override
  String get settingsPinUpdated => 'PIN-код успешно обновлён';

  @override
  String get settingsPinDisableTitle => 'Отключить PIN-код';

  @override
  String get settingsPinDisableBody =>
      'При входе в приложение PIN-код и биометрия запрашиваться не будут. Безопасность аккаунта может снизиться.\n\nВы действительно хотите отключить?';

  @override
  String get settingsPinDisableYes => 'Да, отключить';

  @override
  String get settingsPinProtect => 'Защита PIN-кодом';

  @override
  String get settingsPinOnSubtitle =>
      'При входе запрашиваются PIN-код и биометрия';

  @override
  String get settingsPinOffSubtitle => 'PIN-код при входе не запрашивается';

  @override
  String get settingsPinChange => 'Изменить PIN-код';

  @override
  String get settingsPinChangeSubtitle => 'Установить новый 4-значный код';

  @override
  String get settingsDangerZone => 'ОПАСНАЯ ЗОНА';

  @override
  String get authDeleteAccountConfirmBody =>
      'Все партнёры, транзакции, проекты и отчёты будут удалены безвозвратно. Это действие нельзя отменить. Вы действительно хотите удалить аккаунт?';

  @override
  String get commonYesDelete => 'Да, удалить';

  @override
  String get authAccountDeleted => 'Ваш аккаунт успешно удалён';

  @override
  String get subscriptionLoadError => 'Не удалось загрузить данные тарифа';

  @override
  String get subscriptionCurrentBadge => 'ТЕКУЩИЙ ТАРИФ';

  @override
  String get subscriptionTitle => 'Подписка';

  @override
  String get subscriptionNone => 'Нет подписки';

  @override
  String get subscriptionOverdue => 'Срок оплаты истёк';

  @override
  String subscriptionDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Осталось $count дня',
      many: 'Осталось $count дней',
      few: 'Осталось $count дня',
      one: 'Остался $count день',
    );
    return '$_temp0';
  }

  @override
  String subscriptionValidUntil(Object date) {
    return 'Действует до: $date';
  }

  @override
  String get subscriptionLimitsUsage => 'Лимиты и использование';

  @override
  String get staffMinOnePermission => 'Необходимо выбрать минимум 1 разрешение';

  @override
  String get staffAdd => 'Добавить сотрудника';

  @override
  String get staffAdded => 'Сотрудник добавлен';

  @override
  String get staffStepSms => 'SMS-код';

  @override
  String get staffPhone => 'Телефон сотрудника';

  @override
  String get staffPermissions => 'Разрешения';

  @override
  String get staffUpdatePermissions => 'Обновить разрешения';

  @override
  String get staffUpdatePermissionsWarning =>
      'При изменении разрешений все токены сотрудника будут удалены, и ему нужно будет войти заново.';

  @override
  String get staffEmpty => 'Сотрудников нет';

  @override
  String staffPermissionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count разрешения',
      many: '$count разрешений',
      few: '$count разрешения',
      one: '$count разрешение',
    );
    return '$_temp0';
  }

  @override
  String get staffDeleteConfirm => 'Удалить сотрудника?';

  @override
  String get commonSelectAll => 'Выбрать все';

  @override
  String get staffPermissionsLoading => 'Загрузка списка разрешений...';

  @override
  String get commonUnlimited => 'Безлимит';

  @override
  String get billingMonthly => 'Ежемесячно';

  @override
  String get billingSemiAnnual => '6 месяцев';

  @override
  String get billingAnnual => 'Ежегодно';

  @override
  String get subscriptionNoActive => 'Активная подписка не найдена';

  @override
  String get subscriptionCurrentPlan => 'Текущий тариф';

  @override
  String get subscriptionNoExpiry => 'Срок не установлен';

  @override
  String get subscriptionSmsNotifications => 'SMS-уведомления';

  @override
  String get subscriptionYourCurrentPlan => 'Ваш текущий тариф';

  @override
  String planFeaturePartners(Object value) {
    return 'Партнёры: $value';
  }

  @override
  String planFeatureProjects(Object value) {
    return 'Проекты: $value';
  }

  @override
  String planFeatureStaff(Object value) {
    return 'Сотрудники: $value';
  }

  @override
  String planFeatureSms(Object value) {
    return 'SMS: $value';
  }

  @override
  String get billingMonthlySubscription => 'Ежемесячная подписка';

  @override
  String get billingSemiAnnualSubscription => 'Подписка на 6 месяцев';

  @override
  String get billingAnnualSubscription => 'Годовая подписка';

  @override
  String planNamed(Object name) {
    return 'Тариф $name';
  }

  @override
  String get subscriptionActivated => 'Подписка активирована';

  @override
  String get smsPackagesDescription =>
      'Отправляйте клиентам быстрые SMS-напоминания о расчётах, долгах и платежах.';

  @override
  String smsPackageSubtitle(Object count) {
    return 'Пакет из $count SMS-уведомлений';
  }

  @override
  String get smsPackageAdded => 'SMS-пакет успешно добавлен';

  @override
  String get smsMostPopular => 'САМЫЙ ПОПУЛЯРНЫЙ ПАКЕТ';

  @override
  String smsPerPrice(Object price) {
    return '1 SMS ≈ $price сум';
  }

  @override
  String get commonBuy => 'Купить';

  @override
  String get paymentCreatingOrder => 'Формирование заказа';

  @override
  String get paymentConnecting =>
      'Устанавливается безопасное соединение с платёжной системой...';

  @override
  String get paymentVerifying => 'Проверка платежа';

  @override
  String get paymentConfirmInApp =>
      'Подтвердите платёж в платёжном приложении. Проверка продолжается автоматически...';

  @override
  String get paymentCancel => 'Отменить платёж';

  @override
  String get paymentWaiting => 'Ожидание платежа';

  @override
  String get paymentCheckHint =>
      'Если вы оплатили через платёжное приложение, нажмите кнопку «Проверить»';

  @override
  String get paymentCheck => 'Проверить';

  @override
  String get paymentSuccess => 'Успешно оплачено!';

  @override
  String get paymentSuccessSubtitle => 'Платёж принят, услуги обновлены';

  @override
  String get paymentFailed => 'Платёж не прошёл';

  @override
  String get paymentFailedDefault => 'Платёж отменён или произошла ошибка';

  @override
  String get paymentMethod => 'Способ оплаты';

  @override
  String get paymentMethodSubtitle => 'Выберите удобную платёжную систему';

  @override
  String get commonTotal => 'Итого';

  @override
  String get paymentClickSubtitle => 'Кошелёк Click и банковские карты';

  @override
  String get paymentSecure =>
      'Безопасность платежа гарантирована (256-bit SSL)';

  @override
  String get paymentFast => 'Быстро';

  @override
  String get projectChangeStatus => 'Изменить статус проекта';

  @override
  String get projectTabCosts => 'Расходы';

  @override
  String get projectTabIncomes => 'Доходы';

  @override
  String get projectTabContracts => 'Договоры';

  @override
  String projectFilesCount(int count) {
    return 'Файлы проекта ($count)';
  }

  @override
  String get projectFiles => 'Файлы проекта';

  @override
  String get projectStatusUpdated => 'Статус проекта обновлён';

  @override
  String get projectEdit => 'Редактировать проект';

  @override
  String get projectAdd => 'Добавить проект';

  @override
  String get projectNew => 'Новый проект';

  @override
  String get projectUpdateData => 'Обновите данные проекта';

  @override
  String get projectAndClientData => 'Данные проекта и заказчика';

  @override
  String get projectNameRequired => 'Название проекта *';

  @override
  String get projectNameHint => 'Например, строительство нового офиса';

  @override
  String get projectClientRequired => 'Заказчик *';

  @override
  String get projectClientHint => 'Имя или название организации';

  @override
  String get commonPhoneRequired => 'Телефон *';

  @override
  String get projectAddressOptional => 'Адрес (необязательно)';

  @override
  String get projectAddressHint => 'Город, улица или адрес проекта';

  @override
  String get projectFilesAndImages => 'Файлы и изображения';

  @override
  String get fileUploading => 'Загрузка файла…';

  @override
  String get projectCreate => 'Создать проект';

  @override
  String get projectSearchHint => 'Поиск по названию проекта';

  @override
  String get projectsEmpty => 'Проекты не найдены';

  @override
  String get costTypeSelect => 'Выберите тип расхода';

  @override
  String get costTypeSearch => 'Поиск типа расхода';

  @override
  String get costTypeCreateNew => 'Создать новый тип расхода';

  @override
  String get costTypeNoneYet => 'Типов расходов пока нет';

  @override
  String get costTypeEnterName => 'Введите название типа расхода';

  @override
  String get costTypeNew => 'Новый тип расхода';

  @override
  String get costTypeName => 'Название типа расхода';

  @override
  String get costTypeNameHint => 'Например, инструменты и оборудование';

  @override
  String get costTypeLinkWorker => 'Привязка к работнику';

  @override
  String get costTypeLinkWorkerHint =>
      'Если включено, при вводе расхода выбирается работник';

  @override
  String get commonCreateAndSelect => 'Создать и выбрать';

  @override
  String get positionSearch => 'Поиск должности';

  @override
  String get positionCreateNew => 'Создать новую должность';

  @override
  String get positionNoneYet => 'Должностей пока нет';

  @override
  String get positionEnterName => 'Введите название должности';

  @override
  String get positionNew => 'Новая должность';

  @override
  String get positionName => 'Название должности';

  @override
  String get positionNameHint => 'Например, электрик';

  @override
  String get contractsEmpty => 'Договоров нет';

  @override
  String get contractAdd => 'Добавить договор';

  @override
  String get workTypeSelect => 'Выберите вид работы';

  @override
  String get commonDescriptionRequired => 'Описание *';

  @override
  String get contractDescriptionHint => 'Кратко опишите выполняемую работу';

  @override
  String get contractDescriptionRequired =>
      'Описание обязательно. Опишите выполняемую работу.';

  @override
  String get contractEnterWorkTypeAmount => 'Укажите вид работы и сумму';

  @override
  String get costsEmpty => 'Расходов нет';

  @override
  String costWorker(Object name) {
    return 'Работник: $name';
  }

  @override
  String get costAdd => 'Добавить расход';

  @override
  String get costType => 'Тип расхода';

  @override
  String get costWorkerLabel => 'Работник';

  @override
  String get costEnterTypeAmount => 'Укажите тип расхода и сумму';

  @override
  String get costSelectWorker => 'Выберите работника';

  @override
  String get entryCostDetails => 'Детали расхода';

  @override
  String get entryIncomeDetails => 'Детали дохода';

  @override
  String get entryProjectCost => 'Расход проекта';

  @override
  String get entryProjectIncome => 'Доход проекта';

  @override
  String get entryOperation => 'Операция';

  @override
  String get entryNoNote => 'Комментарий не указан';

  @override
  String get incomesEmpty => 'Доходов нет';

  @override
  String get incomeAdd => 'Добавить доход';

  @override
  String get projectStatusTitle => 'Статус проекта';

  @override
  String projectCurrentStatus(Object status) {
    return 'Текущий статус: $status';
  }

  @override
  String get commonUpdating => 'Обновление…';

  @override
  String get projectSaveStatus => 'Сохранить статус';

  @override
  String get projectStatusInProgressHint => 'Работы по проекту продолжаются';

  @override
  String get projectStatusFrozenHint => 'Работы временно приостановлены';

  @override
  String get projectStatusCompletedHint => 'Работы по проекту завершены';

  @override
  String get projectStatusCurrent => 'Текущий';

  @override
  String get projectAssignStaff => 'Привязать сотрудника к проекту';

  @override
  String get projectUnassignedWorkers =>
      'Работники, не привязанные к этому проекту';

  @override
  String get workerSearchHint => 'Имя, телефон или должность';

  @override
  String get workerCreateNew => 'Создать нового работника';

  @override
  String get workerNoneFree =>
      'Нет свободных работников для привязки. Нажмите +, чтобы создать нового.';

  @override
  String get workersNotFound => 'Работники не найдены';

  @override
  String get workerAssigning => 'Привязка…';

  @override
  String get workerSelectStaff => 'Выберите сотрудников';

  @override
  String workerAssignCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Привязать $count сотрудника',
      many: 'Привязать $count сотрудников',
      few: 'Привязать $count сотрудников',
      one: 'Привязать $count сотрудника',
    );
    return '$_temp0';
  }

  @override
  String get workerAssign => 'Привязать работника';

  @override
  String get workersNoneAssigned => 'Работники не привязаны';

  @override
  String get workTypeSearch => 'Поиск вида работы';

  @override
  String get workTypeCreateNew => 'Создать новый вид работы';

  @override
  String get workTypeNoneYet => 'Видов работ пока нет';

  @override
  String get workTypeEnterName => 'Введите название вида работы';

  @override
  String get workTypeNew => 'Новый вид работы';

  @override
  String get workTypeName => 'Название вида работы';

  @override
  String get workTypeNameHint => 'Например, электромонтаж';

  @override
  String get workerSelect => 'Выберите работника';

  @override
  String get workerNoneYet => 'Работников пока нет';

  @override
  String get workerEnterName => 'Введите имя работника';

  @override
  String get errorAlreadyRegistered => 'Эти данные уже зарегистрированы';

  @override
  String get errorFillField => 'Заполните это поле';

  @override
  String get errorInvalidData => 'Введены неверные данные';

  @override
  String get workerNew => 'Новый работник';

  @override
  String get commonNameRequired => 'Имя *';

  @override
  String get workerNameHint => 'Имя работника';

  @override
  String get commonAdditionalPhoneOptional =>
      'Дополнительный телефон (необязательно)';

  @override
  String get positionRequired => 'Должность *';

  @override
  String get commonAdditionalInfoHint => 'Дополнительная информация';

  @override
  String get reportInstallmentTitle => 'Отчёт по рассрочке';

  @override
  String get reportInstallmentNoData => 'Нет данных о рассрочке';

  @override
  String get reportSections => 'Разделы отчёта';

  @override
  String get reportCollectionEfficiency => 'Эффективность взыскания';

  @override
  String get reportCollectionEfficiencySubtitle =>
      'Эффективность платежей и взысканные суммы';

  @override
  String get reportExpectedPayments => 'Ожидаемые платежи';

  @override
  String get reportExpectedPaymentsSubtitle => 'Прогноз на 30/60/90 дней';

  @override
  String get reportMonthlyDynamics => 'Месячная динамика';

  @override
  String get reportMonthlyDynamicsSubtitle => 'График платежей по месяцам';

  @override
  String get reportProblemClients => 'Проблемные клиенты';

  @override
  String get reportProblemClientsSubtitle =>
      'Список просрочивших и рискованных клиентов';

  @override
  String get reportByClients => 'По клиентам';

  @override
  String get reportByClientsSubtitle => 'Отчёт по рассрочке в разрезе клиентов';

  @override
  String get reportActivePlans => 'Активные планы';

  @override
  String get reportGiven => 'Выдано';

  @override
  String get reportCollected => 'Взыскано';

  @override
  String reportOverdueRate(Object rate) {
    return 'Уровень просрочки: $rate%';
  }

  @override
  String get reportPaymentStatuses => 'Статусы платежей';

  @override
  String reportPaymentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count платежа',
      many: '$count платежей',
      few: '$count платежа',
      one: '$count платёж',
    );
    return '$_temp0';
  }

  @override
  String get reportPartiallyPaid => 'Частично оплачено';

  @override
  String get reportPending => 'Ожидается';

  @override
  String get reportDays30 => '30 дней';

  @override
  String get reportDays60 => '60 дней';

  @override
  String get reportDays90 => '90 дней';

  @override
  String get reportExpectedAmount => 'Ожидаемая сумма';

  @override
  String get reportPayments => 'Платежи';

  @override
  String get reportPrevYear => 'Предыдущий год';

  @override
  String get reportNextYear => 'Следующий год';

  @override
  String get reportTotalPayments => 'Всего платежей';

  @override
  String get reportNoData => 'Нет данных';

  @override
  String get reportNoProblemClients => 'Проблемных клиентов нет';

  @override
  String get reportRiskHigh => 'Высокий риск';

  @override
  String get reportRiskMedium => 'Средний риск';

  @override
  String get reportRiskLow => 'Низкий риск';

  @override
  String reportOverdueSummary(Object count, Object days) {
    return 'Просроченных платежей: $count · В среднем $days дн.';
  }

  @override
  String reportRiskScore(Object score) {
    return 'Балл риска: $score';
  }

  @override
  String reportActivePlansCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count активного плана',
      many: '$count активных планов',
      few: '$count активных плана',
      one: '$count активный план',
    );
    return '$_temp0';
  }

  @override
  String reportLastPayment(Object date) {
    return 'Последний платёж: $date';
  }

  @override
  String get commonLoadMore => 'Загрузить ещё';

  @override
  String get reportNoTransactions => 'Транзакций нет';

  @override
  String reportDueDate(Object date) {
    return 'Срок: $date';
  }

  @override
  String get reportPartnerTitle => 'Отчёт по партнёру';

  @override
  String get reportExcel => 'Отчёт Excel';

  @override
  String get reportTabSettlements => 'Расчёты';

  @override
  String get reportTabInstallment => 'Рассрочка';

  @override
  String get reportAccountUzs => 'Счёт UZS';

  @override
  String get reportAccountUsd => 'Счёт USD';

  @override
  String get reportIncomesList => 'Список приходов';

  @override
  String get reportExpensesList => 'Список расходов';

  @override
  String get reportOperationsEmpty => 'Операции не найдены';

  @override
  String receiptShareAmountPlain(Object amount) {
    return 'Сумма: $amount';
  }

  @override
  String reportPaidAmount(Object amount) {
    return 'Оплачено: $amount';
  }

  @override
  String get reportPartnersTitle => 'Отчёт по партнёрам';

  @override
  String get reportActions => 'Действия с отчётом';

  @override
  String get reportOperations => 'Операции';

  @override
  String get reportTypes => 'Типы отчётов';

  @override
  String get reportDebtTerms => 'Отчёт по срокам долгов';

  @override
  String get reportDebtTermsSubtitle =>
      'Просроченные, сегодняшние и предстоящие долги';

  @override
  String get reportStaff => 'Отчёт по сотрудникам';

  @override
  String get reportStaffSubtitle => 'Все отчёты по сотрудникам';

  @override
  String get reportPeriod => 'Отчёт за период';

  @override
  String get reportPeriodSubtitle => 'Приход и расход за период';

  @override
  String get reportInstallmentShortSubtitle =>
      'Планы, взыскание, месячная динамика и проблемные клиенты';

  @override
  String get reportSelectPeriod => 'Выберите период отчёта';

  @override
  String get dateThisWeek => 'Эта неделя';

  @override
  String get reportTotalIncome => 'Всего приход';

  @override
  String get reportTotalExpense => 'Всего расход';

  @override
  String get reportStaffLoadError =>
      'Не удалось загрузить отчёт по сотрудникам';

  @override
  String get reportNoOperationsPeriod => 'За этот период операций нет';

  @override
  String reportStaffCount(Object count) {
    return 'Сотрудники · $count';
  }

  @override
  String get reportYourDebt => 'Ваш долг';

  @override
  String get reportClientsDebt => 'Долг клиентов';

  @override
  String get reportBalanceRest => 'Остаток';

  @override
  String get projectSelect => 'Выберите проект';

  @override
  String get reportFinance => 'Финансовый отчёт';

  @override
  String get projectNotSelected => 'Проект не выбран';

  @override
  String get projectSelectForFinance =>
      'Выберите проект, чтобы посмотреть финансовый отчёт';

  @override
  String get reportByCategories => 'По категориям';

  @override
  String get reportNoExpenses => 'Расходов нет';

  @override
  String get projectSearch => 'Поиск проекта';

  @override
  String get reportPartnersHomeSubtitle =>
      'Общий баланс, по периодам, сроки долгов, сотрудники';

  @override
  String get reportInstallmentHomeSubtitle =>
      'Общий анализ, ожидаемые платежи и динамика взыскания';

  @override
  String get reportProjectsTitle => 'Отчёт по проектам';

  @override
  String get reportProjectsSubtitle =>
      'Анализ баланса, расходов и доходов проекта';

  @override
  String get reportClientDebt => 'Долг клиента';

  @override
  String get reportClientCredit => 'Переплата клиента';

  @override
  String get reportAccountClosed => 'Расчёт закрыт';

  @override
  String get reportCurrentBalance => 'Текущий баланс';

  @override
  String reportOperationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count операции',
      many: '$count операций',
      few: '$count операции',
      one: '$count операция',
    );
    return '$_temp0';
  }

  @override
  String get reportBalanceDynamics => 'Динамика баланса';

  @override
  String get reportNoDataYet => 'Данных пока нет';

  @override
  String reportLastOperations(Object currency) {
    return 'Последние операции ($currency)';
  }

  @override
  String get reportDebtsList => 'Список долгов';

  @override
  String get reportUpcoming => 'Приближается';

  @override
  String get reportIn3DaysParen => '(3 дня)';

  @override
  String get reportMonthlyStats => 'Месячная статистика';

  @override
  String reportLastMonths(Object count, Object currency) {
    return 'Последние месяцы: $count ($currency)';
  }

  @override
  String get reportOverallStats => 'Общая статистика';

  @override
  String get reportCancelledShort => 'Отменено';

  @override
  String reportOverdueAmount(Object amount, Object currency) {
    return 'Просрочено: $amount $currency';
  }

  @override
  String get reportInstallmentPlans => 'Планы рассрочки';

  @override
  String get reportNoPlans => 'Планов нет';

  @override
  String reportDate(Object date) {
    return 'Дата: $date';
  }

  @override
  String get reportTotalAmount => 'Общая сумма';

  @override
  String get reportParts => 'Части';

  @override
  String reportPaidWithCurrency(Object amount, Object currency) {
    return 'Оплачено: $amount $currency';
  }

  @override
  String reportRemainingWithCurrency(Object amount, Object currency) {
    return 'Осталось: $amount $currency';
  }

  @override
  String get reportPartsSchedule => 'График частей платежа';

  @override
  String get reportMonthlyPaymentDynamics => 'Месячная динамика платежей';

  @override
  String reportPlanCollected(Object planned, Object collected) {
    return 'План: $planned | Собрано: $collected';
  }

  @override
  String receiptShareNumber(Object number) {
    return 'Номер чека: № $number';
  }

  @override
  String receiptShareStatus(Object status) {
    return 'Статус: $status';
  }

  @override
  String get receiptShareStatusCancelled => 'ОТМЕНЁН';

  @override
  String get receiptShareStatusSuccess => 'УСПЕШНО ПРОВЕДЁН';

  @override
  String receiptShareOperation(Object type) {
    return 'Операция: $type';
  }

  @override
  String get receiptIncomeTypeShare => 'Приход (поступление средств)';

  @override
  String installmentAdvanceLine(Object amount, Object currency) {
    return 'Первоначальный взнос: $amount $currency';
  }

  @override
  String get installmentRemainingPrefix => 'Осталось:';

  @override
  String installmentPerPartResult(Object amount, Object currency) {
    return '= $amount $currency/часть';
  }

  @override
  String get walletReasonEnteredByMistake => 'Введено по ошибке';

  @override
  String get activityActionCreated => 'создал(а)';

  @override
  String get activityActionUpdated => 'изменил(а)';

  @override
  String get activityActionRestored => 'восстановил(а)';

  @override
  String get activityModelWallet => 'транзакцию';

  @override
  String get activityModelPartner => 'партнёра';

  @override
  String get activityModelProject => 'проект';

  @override
  String activitySummary(Object name, Object object, Object action) {
    return '$name $action $object';
  }

  @override
  String get monthsShort => 'Янв,Фев,Мар,Апр,Май,Июн,Июл,Авг,Сен,Окт,Ноя,Дек';

  @override
  String receiptShareSubject(Object number) {
    return 'Чек об оплате № $number';
  }

  @override
  String get installmentAdvanceBadge => 'АВАНС';

  @override
  String get authStaffBadge => 'СОТРУДНИК';

  @override
  String get authLoginBadge => 'АУТЕНТИФИКАЦИЯ';

  @override
  String get settingsGeneral => 'ОБЩИЕ';

  @override
  String get settingsSecurity => 'БЕЗОПАСНОСТЬ';

  @override
  String get settingsLanguage => 'Язык';
}
