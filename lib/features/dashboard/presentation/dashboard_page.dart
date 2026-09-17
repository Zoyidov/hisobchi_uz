import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/cubits/owner_context_cubit.dart';
import '../../../core/cubits/user_cubit.dart';
import '../../../core/constants/app_permission.dart';
import '../../../core/di/injector.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../core/widgets/cards/app_kpi_card.dart';
import '../../../core/widgets/feedback/subscription_banner.dart';
import '../../../core/widgets/navigation/permission_guard.dart';
import '../../../core/widgets/states/app_error_state.dart';
import '../../../core/widgets/states/app_skeleton.dart';
import '../../../core/widgets/media/app_avatar.dart';
import '../../notifications/presentation/cubit/notification_badge_cubit.dart';
import '../../partners/presentation/pages/wallet_form_page.dart';
import '../data/dashboard_models.dart';
import '../data/dashboard_repository.dart';
import 'dashboard_cubit.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    getIt<NotificationBadgeCubit>().refresh();
    return BlocProvider(
      create: (_) => DashboardCubit(getIt<DashboardRepository>())..load(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserCubit>().currentUserOrNull;
    final ownerContext = context.watch<OwnerContextCubit>().state;
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<DashboardCubit>().refresh(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                  child: Row(
                    children: [
                      if (user != null) ...[
                        AppAvatar(name: user.name, size: 44),
                        const SizedBox(width: AppSpacing.sm + 2),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assalomu alaykum${user != null ? ', ${user.name}' : ''} 👋',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (ownerContext.isStaffMode)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  '${ownerContext.ownerName ?? ''} hisobida ishlayapsiz',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: colors.textSecondary),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      BlocBuilder<NotificationBadgeCubit, int>(
                        builder: (context, unreadCount) => Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.border.withValues(alpha: 0.8)),
                            boxShadow: colors.cardShadow,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => context.push(RoutePaths.profileNotifications),
                            icon: Badge(
                              isLabelVisible: unreadCount > 0,
                              label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                              backgroundColor: colors.error,
                              child: Icon(Icons.notifications_none_rounded, color: colors.textPrimary, size: 22),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SubscriptionBanner(onAction: () => context.push(RoutePaths.profileSubscription))),
              SliverToBoxAdapter(
                child: BlocBuilder<DashboardCubit, DashboardState>(
                  builder: (context, state) {
                    return switch (state) {
                      DashboardLoading() => const Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            children: [
                              AppSkeletonKpiRow(),
                              SizedBox(height: AppSpacing.md),
                              AppSkeletonKpiRow(),
                            ],
                          ),
                        ),
                      DashboardError(:final failure) => Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: AppErrorState(
                            failure: failure,
                            onRetry: () => context.read<DashboardCubit>().load(),
                          ),
                        ),
                      DashboardLoaded(:final summary, :final tutorials) => _DashboardContent(summary: summary, tutorials: tutorials),
                    };
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.summary, required this.tutorials});

  final DashboardSummary summary;
  final List<TutorialItem> tutorials;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          const _QuickActionsRow(),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Text(
                'Hamkorlar',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.colors.border.withValues(alpha: 0.7)),
                ),
                child: Text(
                  '${summary.partnersCount} ta',
                  style: TextStyle(color: context.colors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Expanded(
                child: AppKpiCard(
                  label: 'Muddati o\'tgan',
                  value: '${summary.qarzExpired}',
                  icon: Icons.error_outline_rounded,
                  color: context.colors.error,
                  isZero: summary.qarzExpired == 0,
                  onTap: () => _openPartnerDue(context, DueDateType.qarzExpired),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppKpiCard(
                  label: 'Bugun',
                  value: '${summary.qarzToday}',
                  icon: Icons.schedule_rounded,
                  color: context.colors.warning,
                  isZero: summary.qarzToday == 0,
                  onTap: () => _openPartnerDue(context, DueDateType.qarzToday),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppKpiCard(
                  label: '3 kun ichida',
                  value: '${summary.qarz3Days}',
                  icon: Icons.event_available_rounded,
                  color: context.colors.success,
                  isZero: summary.qarz3Days == 0,
                  onTap: () => _openPartnerDue(context, DueDateType.qarz3Days),
                ),
              ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Bo\'lib to\'lash',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Expanded(
                child: AppKpiCard(
                  label: 'Muddati o\'tgan',
                  value: '${summary.installmentExpired}',
                  icon: Icons.error_outline_rounded,
                  color: context.colors.error,
                  isZero: summary.installmentExpired == 0,
                  onTap: () => _openInstallmentDue(context, DueDateType.installmentExpired),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppKpiCard(
                  label: 'Bugun',
                  value: '${summary.installmentToday}',
                  icon: Icons.schedule_rounded,
                  color: context.colors.warning,
                  isZero: summary.installmentToday == 0,
                  onTap: () => _openInstallmentDue(context, DueDateType.installmentToday),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppKpiCard(
                  label: '3 kun ichida',
                  value: '${summary.installment3Days}',
                  icon: Icons.event_available_rounded,
                  color: context.colors.info,
                  isZero: summary.installment3Days == 0,
                  onTap: () => _openInstallmentDue(context, DueDateType.installment3Days),
                ),
              ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Loyihalar',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            onTap: () => context.go(RoutePaths.projects),
            padding: const EdgeInsets.all(AppSpacing.md),
            borderRadius: BorderRadius.circular(18),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.work_rounded, color: context.colors.primary, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${summary.projectsCount} ta loyiha',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _ProjectStatusDot(color: context.colors.info, label: 'Jarayonda ${summary.projectsInProgress}'),
                          const SizedBox(width: AppSpacing.sm),
                          _ProjectStatusDot(color: context.colors.warning, label: 'Muzlatilgan ${summary.projectsFrozen}'),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: context.colors.textTertiary),
              ],
            ),
          ),
          if (tutorials.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Qo\'llanmalar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...tutorials.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: AppCard(
                  onTap: () => launchUrl(Uri.parse(t.url), mode: LaunchMode.externalApplication),
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.play_arrow_rounded, color: context.colors.primary, size: 22),
                      ),
                      const SizedBox(width: AppSpacing.sm + 2),
                      Expanded(
                        child: Text(
                          t.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(Icons.arrow_outward_rounded, size: 18, color: context.colors.textTertiary),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openPartnerDue(BuildContext context, DueDateType type) {
    context.push(RoutePaths.dashboardDueDates, extra: type);
  }

  void _openInstallmentDue(BuildContext context, DueDateType type) {
    context.push(RoutePaths.dashboardInstallmentDueDates, extra: type);
  }
}

class _ProjectStatusDot extends StatelessWidget {
  const _ProjectStatusDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PermissionGuard(
          permission: AppPermission.walletsDebtCreate,
          child: Expanded(
            child: _QuickAction(
              icon: Icons.arrow_downward_rounded,
              label: 'Kirim',
              color: context.colors.success,
              onTap: () => showWalletFormSheet(context, type: 'debt'),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        PermissionGuard(
          permission: AppPermission.walletsCreditCreate,
          child: Expanded(
            child: _QuickAction(
              icon: Icons.arrow_upward_rounded,
              label: 'Chiqim',
              color: context.colors.error,
              onTap: () => showWalletFormSheet(context, type: 'credit'),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        PermissionGuard(
          permission: AppPermission.partnersCreate,
          child: Expanded(
            child: _QuickAction(
              icon: Icons.person_add_alt_rounded,
              label: 'Hamkor',
              color: context.colors.primary,
              onTap: () => context.push(RoutePaths.partnerCreate),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
          ),
        ],
      ),
    );
  }
}
