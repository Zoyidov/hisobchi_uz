/// Barcha backend REST endpointlari — bitta joyda, feature qatlamlarida
/// hardcode qilinmaydi (MOBILE_APP_TZ.md bo'lim 4).
abstract final class ApiEndpoints {
  // Auth
  static const checkVersion = '/auth/mobile-check-version';
  static const verifyNumber = '/auth/verify-number';
  static const otp = '/auth/otp';
  static const otpVerify = '/auth/otp/verify';
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const resetPassword = '/auth/reset-password';
  static const me = '/auth/me';
  static const staffPermissions = '/auth/staff/permissions';
  static String logout(String deviceToken) => '/auth/logout/$deviceToken';
  static const deleteAccount = '/auth/delete-account';
  static String appSettings(int userId) =>
      '/auth/app-settings-update-or-create/$userId';
  static String loginPincode(int userId) => '/auth/login-pincode/$userId';
  static const updateProfileInfo = '/auth/update-profile-info';
  static const updatePassword = '/auth/update-password';
  static const updateProfilePhoneVerify = '/auth/update-profile-phone-verify';
  static const updateProfilePhoneCheckOtp = '/auth/update-profile-phone-check-otp';
  static const activateOwnAccount = '/auth/activate-own-account';

  // Dashboard / reports
  static const dashboard = '/reports/dashboard';
  static const dashboardDueDates = '/reports/dashboard/due-dates';
  static const dashboardInstallmentDueDates =
      '/reports/dashboard/installments/due-dates';
  static const tutorials = '/reports/app/tutorials';
  static String partnerSentSms(int partnerId) =>
      '/reports/partners/sended-sms/$partnerId';

  // Reports — Partners V3
  static const partnersV3SummaryTypes = '/reports/partners-v3/summary-report-types';
  static const partnersV3Summary = '/reports/partners-v3/summary';
  static const partnersV3SummaryDetails = '/reports/partners-v3/summary-qarzdor-xaqdor-details';
  static const partnersV3Periods = '/reports/partners-v3/periods';
  static const partnersV3PeriodsOperations = '/reports/partners-v3/periods-operations';
  static const partnersV3WarrantyPeriods = '/reports/partners-v3/warranty-periods';
  static const partnersV3WarrantyPeriodsDetails = '/reports/partners-v3/warranty-periods-details';
  static const partnersV3Workers = '/reports/partners-v3/workers';
  static const partnersV3WorkersLists = '/reports/partners-v3/workers-lists';
  static const partnersV3WorkersSummary = '/reports/partners-v3/workers-details->summary';
  static const partnersV3WorkersOperations = '/reports/partners-v3/workers-details->operations';

  // Reports — Partner detail V2
  static String partnerDetailsV2(int partnerId) => '/reports/partners-v2/partner-details/$partnerId';
  static const partnerDetailsSectionOne = '/reports/partners-v2/partner-details-section-one';

  // Reports — Installments
  static const installmentReportSummary = '/reports/installments/summary';
  static const installmentReportPartners = '/reports/installments/partners';
  static const installmentReportForecast = '/reports/installments/forecast';
  static const installmentReportRisky = '/reports/installments/risky-partners';
  static const installmentReportRecovery = '/reports/installments/recovery';
  static const installmentReportMonthly = '/reports/installments/monthly';
  static const installmentReportItems = '/reports/installments/items';
  static String installmentReportPartner(int partnerId) => '/reports/installments/partner/$partnerId';

  // Reports — Projects
  static const projectReportBalance = '/reports/projects/balance';
  static const projectReportIncomeDetails = '/reports/projects/income-details';
  static const projectReportCostDetails = '/reports/projects/cost-details';
  static const projectReportWorkersCosts = '/reports/projects/workers-costs';
  static const projectReportWorkersCostsDetails = '/reports/projects/workers-costs-details';

  // Partners
  static const partnersAccount = '/partners/partners/account';
  static const partnersSimple = '/partners/partners';
  static const partnersExportExcel = '/partners/partners/export/excel';
  static const partner = '/partners/partner';
  static String partnerById(int id) => '/partners/partner/$id';
  static String partnerRestore(int id) => '/partners/partner/$id/restore';
  static String partnerForceDelete(int id) =>
      '/partners/partner/$id/force-delete';
  static String partnerAccount(int id) => '/partners/partner/$id/account';
  static String partnerSettings(int id) => '/partners/partner/settings/$id';
  static String partnerInstallments(int id) =>
      '/partners/partner/$id/installments';
  static String partnerWalletsExportExcel(int id) =>
      '/partners/partner/$id/wallets/export/excel';

  // Wallets
  static const wallets = '/partners/wallets';
  static const wallet = '/partners/wallet';
  static String walletById(int id) => '/partners/wallet/$id';
  static String walletCancel(int id) => '/partners/wallet/$id/cancel';
  static String walletRestore(int id) => '/partners/wallet/$id/restore';
  static String walletForceDelete(int id) =>
      '/partners/wallet/$id/force-delete';

  // Installments
  static const installments = '/partners/installments';
  static String installmentById(int id) => '/partners/installments/$id';
  static String installmentItems(int id) => '/partners/installments/$id/items';
  static String installmentPayment(int id) =>
      '/partners/installments/$id/payment';
  static String installmentPaymentHistory(int id) =>
      '/partners/installments/$id/payment-history';
  static String installmentPaymentCancel(int planId, int paymentId) =>
      '/partners/installments/$planId/payments/$paymentId';

  // Projects
  static const projects = '/project/projects';
  static const projectStatuses = '/project/project-statuses';
  static const project = '/project/project';
  static String projectById(int id) => '/project/project/$id';
  static String projectRestore(int id) => '/project/project/$id/restore';
  static String projectForceDelete(int id) =>
      '/project/project/$id/force-delete';
  static String projectUpdateStatus(int id) =>
      '/project/project/$id/update-status';
  static const projectContracts = '/project/project-contracts';
  static const projectContract = '/project/project-contract';
  static const projectIncomes = '/project/project-incomes';
  static const projectIncome = '/project/project-income';
  static const projectCosts = '/project/project-costs';
  static const projectCost = '/project/project-cost';
  static String projectWorkers(int projectId) =>
      '/project/project/$projectId/workers';
  static const workerAddToProject = '/project/worker-add-to-project';
  static const workerRemoveFromProject = '/project/worker-remove-from-project';

  // Documents
  static const currencies = '/documents/currencies';
  static const workTypes = '/documents/work-types';
  static const workType = '/documents/work-type';
  static String workTypeById(int id) => '/documents/work-type/$id';
  static String workTypeRestore(int id) => '/documents/work-type/$id/restore';
  static String workTypeForceDelete(int id) => '/documents/work/$id/force-delete';

  static const costTypes = '/documents/cost-types';
  static const costType = '/documents/cost-type';
  static String costTypeById(int id) => '/documents/cost-type/$id';
  static String costTypeRestore(int id) => '/documents/cost-type/$id/restore';
  static String costTypeForceDelete(int id) => '/documents/cost-type/$id/force-delete';

  static const positions = '/documents/worker-positions';
  static const position = '/documents/worker-position';
  static String positionById(int id) => '/documents/worker-position/$id';
  static String positionRestore(int id) => '/documents/worker-position/$id/restore';
  static String positionForceDelete(int id) => '/documents/worker-position/$id/force-delete';

  static const workers = '/documents/workers';
  static const worker = '/documents/worker';
  static String workerById(int id) => '/documents/worker/$id';
  static String workerRestore(int id) => '/documents/worker/$id/restore';
  static String workerForceDelete(int id) => '/documents/worker/$id/force-delete';

  static const currencyExchangeRates = '/documents/currencys-exchange-rates';
  static String cbuRatesByDate(String date) => '/currency-calc/cbu-rates/$date';

  // Files
  static const filesUpload = '/files/upload';
  static String fileDelete(int id) => '/files/delete/$id';

  // Subscription
  static const subscriptionShow = '/subscription/show';
  static const subscriptionStatistics = '/subscription/get-statistics';
  static const pricingPlans = '/pricing-plans';
  static String pricingPlanById(int id) => '/pricing-plans/$id';
  static const subscriptionPurchase = '/subscription/purchase';
  static String checkOrderStatus(String orderNumber) => '/subscription/check-order-status/$orderNumber';
  static const pricingSms = '/pricing-sms';
  static const pricingSmsPurchase = '/pricing-sms/purchase';

  // Staff
  static const staff = '/auth/staff';
  static String staffById(int id) => '/auth/staff/$id';
  static const staffSendOtp = '/auth/staff/send-otp';
  static const staffVerifyOtp = '/auth/staff/verify-otp';

  // Notifications
  static const notifications = '/notifications';
  static const notificationsUnreadCount = '/notifications/unread-count';
  static String notificationMarkAsRead(int id) => '/notifications/$id/mark-as-read';

  // Activity log
  static const activityLog = '/activity-logs';
}
