/// Barcha yo'nalish manzillari — bitta joyda (E_HISOB_FLUTTER_UI_UX_TZ.md 7-bo'lim).
abstract final class RoutePaths {
  // Auth
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const phone = '/auth/phone';
  static const otp = '/auth/otp';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';
  static const pincodeSetup = '/auth/pincode-setup';
  static const pincodeLock = '/auth/pincode';
  static const accountSelection = '/auth/account-selection';
  static const forceUpdate = '/system/force-update';

  // Shell / tabs
  static const dashboard = '/dashboard';
  static const partners = '/partners';
  static const projects = '/projects';
  static const reports = '/reports';
  static const profile = '/profile';

  // Dashboard details
  static const dashboardDueDates = '/dashboard/due-dates';
  static const dashboardInstallmentDueDates = '/dashboard/installment-due-dates';

  // Partners
  static const partnerCreate = '/partners/create';
  static String partnerDetail(int id) => '/partners/$id';
  static String partnerEdit(int id) => '/partners/$id/edit';
  static String walletCreate(int partnerId) => '/partners/$partnerId/wallet/create';
  static String smsSettings(int partnerId) => '/partners/$partnerId/sms-settings';
  static String smsHistory(int partnerId) => '/partners/$partnerId/sms-history';

  // Installments
  static String installmentsForPartner(int partnerId) => '/partners/$partnerId/installments';
  static String installmentCreate(int partnerId) => '/partners/$partnerId/installments/create';
  static String installmentDetail(int id) => '/installments/$id';
  static String installmentPaymentHistory(int id) => '/installments/$id/payments';

  // Projects
  static const projectCreate = '/projects/create';
  static String projectDetail(int id) => '/projects/$id';
  static String projectEdit(int id) => '/projects/$id/edit';

  // Reports
  static const reportPartners = '/reports/partners';
  static const reportPartnersPeriod = '/reports/partners/period';
  static const reportPartnersWarranty = '/reports/partners/warranty';
  static const reportPartnersWorkers = '/reports/partners/workers';
  static String reportPartnerDetail(int partnerId) => '/reports/partner/$partnerId';
  static const reportInstallments = '/reports/installments';
  static const reportProjects = '/reports/projects';

  // Subscription
  static const subscriptionPlans = '/profile/subscription/plans';
  static const smsPackagesPurchase = '/profile/sms/purchase';
  static String paymentStatus(String orderNumber) => '/payment/$orderNumber';

  // Staff
  static const staffCreate = '/profile/staff/create';
  static String staffEdit(int id) => '/profile/staff/$id';

  // Documents
  static const documentsWorkTypes = '/profile/documents/work-types';
  static const documentsCostTypes = '/profile/documents/cost-types';
  static const documentsPositions = '/profile/documents/positions';
  static const documentsWorkers = '/profile/documents/workers';

  // Profile
  static const profileEdit = '/profile/edit';
  static const profileSettings = '/profile/settings';
  static const profileSubscription = '/profile/subscription';
  static const profileStaff = '/profile/staff';
  static const profileDocuments = '/profile/documents';
  static const profileActivity = '/profile/activity';
  static const profileNotifications = '/profile/notifications';
  static const profileCurrency = '/profile/currency';
  static const profileSms = '/profile/sms';
  static const comingSoon = '/coming-soon';
}
