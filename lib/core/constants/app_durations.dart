/// Tarmoq va UX bilan bog'liq doimiy davomiyliklar (MOBILE_APP_TZ.md 4.4, 5.4).
abstract final class ApiDurations {
  static const connectTimeoutSec = 15;
  static const receiveTimeoutSec = 30;
  static const sendTimeoutSec = 30;
  static const excelReceiveTimeoutSec = 120;
}

abstract final class AppDurations {
  static const otpCountdownSec = 60;
  static const verifyTokenValiditySec = 120;
  static const searchDebounceMs = 400;
  static const splashMaxMs = 3000;
  static const pincodeMaxAttempts = 5;
  static const backgroundLockThresholdSec = 60;
  static const paymentPollingIntervalSec = 5;
  static const paymentPollingMaxSec = 120;

  static const instant = Duration.zero;
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const medium = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);
}

abstract final class AppPageSize {
  static const partners = 15;
  static const installments = 20;
  static const projects = 10;
  static const notifications = 20;
  static const activityLog = 20;
  static const infiniteScrollThreshold = 3;
}
