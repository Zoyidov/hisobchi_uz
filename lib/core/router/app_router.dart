import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/account_selection_page.dart';
import '../../features/auth/presentation/pages/force_update_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/phone_page.dart';
import '../../features/auth/presentation/pages/pincode_lock_page.dart';
import '../../features/auth/presentation/pages/pincode_setup_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/cubit/otp_cubit.dart';
import '../../features/dashboard/data/dashboard_models.dart';
import '../../features/dashboard/presentation/due_dates_page.dart';
import '../../features/partners/data/partner_models.dart';
import '../../features/partners/presentation/pages/partner_detail_page.dart';
import '../../features/partners/presentation/pages/partner_form_page.dart';
import '../../features/partners/presentation/pages/partners_list_page.dart';
import '../../features/partners/presentation/pages/partner_sms_settings_page.dart';
import '../../features/partners/presentation/pages/wallet_form_page.dart';
import '../../features/installments/presentation/pages/installment_detail_page.dart';
import '../../features/installments/presentation/pages/installment_payment_history_page.dart';
import '../../features/installments/presentation/pages/installment_wizard_page.dart';
import '../../features/projects/presentation/pages/projects_list_page.dart';
import '../../features/staff/presentation/pages/staff_list_page.dart';
import '../../features/activity_log/presentation/pages/activity_log_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/subscription/presentation/pages/my_subscription_page.dart';
import '../../features/subscription/presentation/pages/plans_page.dart';
import '../../features/subscription/presentation/pages/sms_packages_page.dart';
import '../../features/reports/presentation/pages/partner_detail_report_page.dart';
import '../../features/reports/presentation/pages/reports_home_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/documents/presentation/pages/currency_rates_page.dart';
import '../../features/documents/presentation/pages/documents_home_page.dart';
import '../../features/profile/presentation/pages/profile_edit_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/shell/main_shell_page.dart';
import '../cubits/auth_cubit.dart';
import 'route_paths.dart';

/// AuthCubit o'zgarishlarini GoRouter'ga uzatadi — token holati o'zgarganda
/// redirect qayta baholanadi.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Ekranlar orasidagi asosiy yo'nalish jadvali (E_HISOB_FLUTTER_UI_UX_TZ.md 7-bo'lim).
GoRouter buildAppRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final isAuthenticated = authCubit.state == AuthStatus.authenticated;
      final loc = state.matchedLocation;

      final isAuthFlow = loc.startsWith('/auth') ||
          loc == RoutePaths.splash ||
          loc == RoutePaths.onboarding ||
          loc == RoutePaths.forceUpdate;

      if (!isAuthenticated && authCubit.state != AuthStatus.splash && !isAuthFlow) {
        return RoutePaths.phone;
      }
      return null;
    },
    routes: [
      GoRoute(path: RoutePaths.splash, builder: (context, state) => const SplashPage()),
      GoRoute(path: RoutePaths.forceUpdate, builder: (context, state) => const ForceUpdatePage()),
      GoRoute(path: RoutePaths.phone, builder: (context, state) => const PhonePage()),
      GoRoute(
        path: RoutePaths.otp,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OtpPage(
            phone: extra['phone'] as String? ?? '',
            mode: extra['mode'] == 'register' ? OtpMode.register : OtpMode.resetPassword,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.register,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return RegisterPage(
            phone: extra['phone'] as String? ?? '',
            verifyToken: extra['verifyToken'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return LoginPage(phone: extra['phone'] as String? ?? '');
        },
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ForgotPasswordPage(phone: extra['phone'] as String? ?? '');
        },
      ),
      GoRoute(
        path: RoutePaths.resetPassword,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ResetPasswordPage(
            phone: extra['phone'] as String? ?? '',
            otpCode: extra['otpCode'] as String? ?? '',
          );
        },
      ),
      GoRoute(path: RoutePaths.pincodeSetup, builder: (context, state) => const PincodeSetupPage()),
      GoRoute(path: RoutePaths.pincodeLock, builder: (context, state) => const PincodeLockPage()),
      GoRoute(path: RoutePaths.accountSelection, builder: (context, state) => const AccountSelectionPage()),

      // Bottom-nav shell — har bir tab o'z holatini saqlaydi
      // (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 15: "tab switch state preserving").
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShellPage(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.dashboard, builder: (context, state) => const DashboardPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.partners, builder: (context, state) => const PartnersListPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.projects, builder: (context, state) => const ProjectsListPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.reports, builder: (context, state) => const ReportsHomePage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.profile, builder: (context, state) => const ProfilePage()),
          ]),
        ],
      ),

      // Dashboard details
      GoRoute(
        path: RoutePaths.dashboardDueDates,
        builder: (context, state) => DueDatesPage(type: state.extra as DueDateType? ?? DueDateType.qarzExpired),
      ),
      GoRoute(
        path: RoutePaths.dashboardInstallmentDueDates,
        builder: (context, state) =>
            DueDatesPage(type: state.extra as DueDateType? ?? DueDateType.installmentExpired),
      ),

      // Partners
      GoRoute(path: RoutePaths.partnerCreate, builder: (context, state) => const PartnerFormPage()),
      GoRoute(
        path: '/partners/:id',
        builder: (context, state) => PartnerDetailPage(partnerId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/partners/:id/edit',
        builder: (context, state) => PartnerFormPage(editing: state.extra as Partner?),
      ),
      GoRoute(
        path: '/partners/:id/wallet/create',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return WalletFormPage(
            partner: extra['partner'] as Partner,
            lockedType: extra['type'] as String?,
            editingWallet: extra['editingWallet'] as Wallet?,
          );
        },
      ),
      GoRoute(
        path: '/partners/:id/sms-settings',
        builder: (context, state) =>
            PartnerSmsSettingsPage(partnerId: int.parse(state.pathParameters['id']!)),
      ),

      // Installments
      GoRoute(
        path: '/partners/:id/installments/create',
        builder: (context, state) => InstallmentWizardPage(partner: state.extra as Partner),
      ),
      GoRoute(
        path: '/installments/:id',
        builder: (context, state) => InstallmentDetailPage(planId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/installments/:id/payments',
        builder: (context, state) => InstallmentPaymentHistoryPage(
          planId: int.parse(state.pathParameters['id']!),
          currencyTypeId: state.extra as int? ?? 1,
        ),
      ),

      GoRoute(
        path: '/reports/partner/:id',
        builder: (context, state) {
          final partner = state.extra as Partner?;
          return PartnerDetailReportPage(
            partnerId: int.parse(state.pathParameters['id']!),
            partnerName: partner?.name ?? '',
          );
        },
      ),

      // Profile sub-routes (placeholders — keyingi bosqichda to'ldiriladi)
      GoRoute(path: RoutePaths.profileEdit, builder: (context, state) => const ProfileEditPage()),
      GoRoute(path: RoutePaths.profileSubscription, builder: (context, state) => const MySubscriptionPage()),
      GoRoute(path: RoutePaths.subscriptionPlans, builder: (context, state) => const PlansPage()),
      GoRoute(path: RoutePaths.profileStaff, builder: (context, state) => const StaffListPage()),
      GoRoute(path: RoutePaths.profileDocuments, builder: (context, state) => const DocumentsHomePage()),
      GoRoute(path: RoutePaths.profileActivity, builder: (context, state) => const ActivityLogPage()),
      GoRoute(path: RoutePaths.profileNotifications, builder: (context, state) => const NotificationsPage()),
      GoRoute(path: RoutePaths.profileCurrency, builder: (context, state) => const CurrencyRatesPage()),
      GoRoute(path: RoutePaths.profileSms, builder: (context, state) => const SmsPackagesPage()),
    ],
  );
}
