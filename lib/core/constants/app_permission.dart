/// Backend permission kalitlari (MOBILE_APP_TZ.md 6.4). `me().permissions`
/// yoki `works_for[i].permissions` massivlarida shu qatorlar keladi.
abstract final class AppPermission {
  // Mijozlar
  static const partnersView = 'partners.view';
  static const partnersCreate = 'partners.create';
  static const partnersEdit = 'partners.edit';
  static const partnersDelete = 'partners.delete';

  // Kirim/chiqim
  static const walletsDebtCreate = 'wallets_debt.create';
  static const walletsDebtCancel = 'wallets_debt.cancel';
  static const walletsCreditCreate = 'wallets_credit.create';
  static const walletsCreditCancel = 'wallets_credit.cancel';

  // Loyihalar
  static const projectsView = 'projects.view';
  static const projectsCreate = 'projects.create';
  static const projectsEdit = 'projects.edit';
  static const projectsDelete = 'projects.delete';

  // Bo'lib to'lash
  static const installmentsView = 'installments.view';
  static const installmentsCreate = 'installments.create';
  static const installmentsEdit = 'installments.edit';
  static const installmentsDelete = 'installments.delete';
  static const installmentsPayment = 'installments.payment';
  static const installmentsCancelPayment = 'installments.cancel_payment';

  // Hisobotlar
  static const reportPartnersView = 'report_partners.view';
  static const reportPartnerView = 'report_partner.view';
  static const reportProjectView = 'report_project.view';
  static const reportInstallmentsView = 'report_installments.view';

  // Profil
  static const planAboutView = 'plan_about.view';
  static const planLimitView = 'plan_limit.view';
}
