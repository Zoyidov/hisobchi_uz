import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_permission.dart';
import '../../../core/cubits/owner_context_cubit.dart';
import '../../../core/cubits/user_cubit.dart';
import '../../../core/di/injector.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../core/widgets/feedback/subscription_banner.dart';
import '../../../core/widgets/media/app_avatar.dart';
import '../../../core/widgets/navigation/permission_guard.dart';
import '../../../core/widgets/states/app_error_state.dart';
import '../../../core/widgets/states/app_skeleton.dart';
import '../../notifications/presentation/cubit/notification_badge_cubit.dart';
import '../../partners/presentation/pages/wallet_form_page.dart';
import '../data/dashboard_models.dart';
import '../data/dashboard_repository.dart';
import 'dashboard_cubit.dart';

/// "Asosiy" — Premium iOS uslubidagi zamonaviy fintech boshqaruv paneli.
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

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'Xayrli tong';
    if (hour >= 11 && hour < 17) return 'Xayrli kun';
    if (hour >= 17 && hour < 22) return 'Xayrli kech';
    return 'Xayrli tun';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserCubit>().currentUserOrNull;
    final ownerContext = context.watch<OwnerContextCubit>().state;
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.lightImpact();
            await context.read<DashboardCubit>().refresh();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // 1. Header (Avatar, Dynamic Greeting, Notification Bell)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                  child: Row(
                    children: [
                      if (user != null) ...[
                        GestureDetector(
                          onTap: () => context.go(RoutePaths.profile),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.primary.withValues(alpha: 0.25),
                                width: 2,
                              ),
                            ),
                            child: AppAvatar(name: user.name, size: 44),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm + 2),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getGreeting()}${user != null ? ', ${user.name}' : ''} 👋',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                    fontSize: 20,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            if (ownerContext.isStaffMode)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${ownerContext.ownerName ?? ''} hisobida',
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            else
                              Text(
                                'Moliyaviy ko\'rsatkichlar monitoringi',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // iOS Notification Bell
                      BlocBuilder<NotificationBadgeCubit, int>(
                        builder: (context, unreadCount) => Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.border.withValues(alpha: 0.8)),
                            boxShadow: colors.cardShadow,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              context.push(RoutePaths.profileNotifications);
                            },
                            icon: Badge(
                              isLabelVisible: unreadCount > 0,
                              label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                              backgroundColor: colors.error,
                              child: Icon(
                                CupertinoIcons.bell_fill,
                                color: colors.textPrimary,
                                size: 21,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Subscription Banner
              SliverToBoxAdapter(
                child: SubscriptionBanner(
                  onAction: () => context.push(RoutePaths.profileSubscription),
                ),
              ),

              // 3. Main Dashboard Content (Hero, Quick Actions, KPIs)
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
                      DashboardLoaded(:final summary, :final tutorials) => _DashboardContent(
                          summary: summary,
                          tutorials: tutorials,
                          animController: _animController,
                        ),
                    };
                  },
                ),
              ),

              // Bottom navbar tagida kontent qolib ketmasligi uchun bo'sh joy
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.summary,
    required this.tutorials,
    required this.animController,
  });

  final DashboardSummary summary;
  final List<TutorialItem> tutorials;
  final AnimationController animController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),

          // 1. Hero Moliyaviy Hub Kartasi
          _HeroFinanceCard(
            summary: summary,
            animation: CurvedAnimation(
              parent: animController,
              curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // 2. Tezkor Amallar (Kirim, Chiqim, Hamkor, Loyiha)
          _FadeSlideTransition(
            animation: CurvedAnimation(
              parent: animController,
              curve: const Interval(0.15, 0.6, curve: Curves.easeOutCubic),
            ),
            child: const _QuickActionsRow(),
          ),

          const SizedBox(height: AppSpacing.xl),

          // 3. Hamkorlar Qarz Nazorati
          _FadeSlideTransition(
            animation: CurvedAnimation(
              parent: animController,
              curve: const Interval(0.3, 0.75, curve: Curves.easeOutCubic),
            ),
            child: _PartnersDebtSection(summary: summary),
          ),

          const SizedBox(height: AppSpacing.xl),

          // 4. Bo'lib to'lash Jadvali
          _FadeSlideTransition(
            animation: CurvedAnimation(
              parent: animController,
              curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic),
            ),
            child: _InstallmentsSection(summary: summary),
          ),

          const SizedBox(height: AppSpacing.xl),

          // 5. Loyihalar Portfeli
          _FadeSlideTransition(
            animation: CurvedAnimation(
              parent: animController,
              curve: const Interval(0.55, 0.95, curve: Curves.easeOutCubic),
            ),
            child: _ProjectsSection(summary: summary),
          ),

          // 6. Video Qo'llanmalar
          if (tutorials.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            _FadeSlideTransition(
              animation: CurvedAnimation(
                parent: animController,
                curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic),
              ),
              child: _TutorialsSection(tutorials: tutorials),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero Finance Card
// ---------------------------------------------------------------------------
class _HeroFinanceCard extends StatelessWidget {
  const _HeroFinanceCard({required this.summary, required this.animation});

  final DashboardSummary summary;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final totalDueExpired = summary.qarzExpired + summary.installmentExpired;

    return _FadeSlideTransition(
      animation: animation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0F172A),
              Color.lerp(const Color(0xFF0F172A), colors.primary, 0.35) ?? const Color(0xFF1E293B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        CupertinoIcons.chart_pie_fill,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Hisob-kitob holati',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: totalDueExpired > 0
                        ? colors.error.withValues(alpha: 0.25)
                        : colors.success.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: totalDueExpired > 0
                          ? colors.error.withValues(alpha: 0.5)
                          : colors.success.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: totalDueExpired > 0 ? colors.error : colors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        totalDueExpired > 0 ? '$totalDueExpired ta ogohlantirish' : 'Barchasi joyida',
                        style: TextStyle(
                          color: totalDueExpired > 0 ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _HeroStatTile(
                    icon: CupertinoIcons.person_2_fill,
                    value: '${summary.partnersCount}',
                    label: 'Hamkorlar',
                    onTap: () => context.go(RoutePaths.partners),
                  ),
                ),
                Container(
                  width: 1,
                  height: 38,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                Expanded(
                  child: _HeroStatTile(
                    icon: CupertinoIcons.briefcase_fill,
                    value: '${summary.projectsCount}',
                    label: 'Loyihalar',
                    onTap: () => context.go(RoutePaths.projects),
                  ),
                ),
                Container(
                  width: 1,
                  height: 38,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                Expanded(
                  child: _HeroStatTile(
                    icon: CupertinoIcons.timer_fill,
                    value: '${summary.qarzToday + summary.installmentToday}',
                    label: 'Bugungi qarz',
                    onTap: () => context.push(RoutePaths.dashboardDueDates, extra: DueDateType.qarzToday),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStatTile extends StatelessWidget {
  const _HeroStatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Actions Row (Kirim, Chiqim, Hamkor, Loyiha)
// ---------------------------------------------------------------------------
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        PermissionGuard(
          permission: AppPermission.walletsDebtCreate,
          child: Expanded(
            child: _QuickActionItem(
              icon: CupertinoIcons.arrow_down_left_circle_fill,
              label: 'Kirim',
              color: colors.success,
              onTap: () async {
                final res = await showWalletFormSheet(context, type: 'debt');
                if (res != null && context.mounted) {
                  context.read<DashboardCubit>().refresh();
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 10),
        PermissionGuard(
          permission: AppPermission.walletsCreditCreate,
          child: Expanded(
            child: _QuickActionItem(
              icon: CupertinoIcons.arrow_up_right_circle_fill,
              label: 'Chiqim',
              color: colors.error,
              onTap: () async {
                final res = await showWalletFormSheet(context, type: 'credit');
                if (res != null && context.mounted) {
                  context.read<DashboardCubit>().refresh();
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 10),
        PermissionGuard(
          permission: AppPermission.partnersCreate,
          child: Expanded(
            child: _QuickActionItem(
              icon: CupertinoIcons.person_crop_circle_badge_plus,
              label: 'Hamkor',
              color: colors.primary,
              onTap: () async {
                await context.push(RoutePaths.partnerCreate);
                if (context.mounted) {
                  context.read<DashboardCubit>().refresh();
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 10),
        PermissionGuard(
          permission: AppPermission.projectsCreate,
          child: Expanded(
            child: _QuickActionItem(
              icon: CupertinoIcons.folder_badge_plus,
              label: 'Loyiha',
              color: const Color(0xFFF59E0B),
              onTap: () => context.go(RoutePaths.projects),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatefulWidget {
  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_QuickActionItem> createState() => _QuickActionItemState();
}

class _QuickActionItemState extends State<_QuickActionItem> with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border.withValues(alpha: 0.7)),
            boxShadow: colors.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.color.withValues(alpha: 0.18),
                      widget.color.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(widget.icon, color: widget.color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Partners Debt Section
// ---------------------------------------------------------------------------
class _PartnersDebtSection extends StatelessWidget {
  const _PartnersDebtSection({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(CupertinoIcons.person_2_fill, color: colors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Hamkorlar qarzi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.border.withValues(alpha: 0.7)),
                  ),
                  child: Text(
                    '${summary.partnersCount} ta',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              onPressed: () => context.go(RoutePaths.partners),
              child: Row(
                children: [
                  Text(
                    'Barchasi',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(CupertinoIcons.chevron_right, size: 12, color: colors.primary),
                ],
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
                child: _IosKpiCard(
                  label: 'Muddati o\'tgan',
                  value: '${summary.qarzExpired}',
                  icon: CupertinoIcons.exclamationmark_triangle_fill,
                  color: colors.error,
                  isZero: summary.qarzExpired == 0,
                  onTap: () async {
                    await context.push(RoutePaths.dashboardDueDates, extra: DueDateType.qarzExpired);
                    if (context.mounted) context.read<DashboardCubit>().refresh();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _IosKpiCard(
                  label: 'Bugun',
                  value: '${summary.qarzToday}',
                  icon: CupertinoIcons.clock_fill,
                  color: const Color(0xFFF59E0B),
                  isZero: summary.qarzToday == 0,
                  onTap: () async {
                    await context.push(RoutePaths.dashboardDueDates, extra: DueDateType.qarzToday);
                    if (context.mounted) context.read<DashboardCubit>().refresh();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _IosKpiCard(
                  label: '3 kun ichida',
                  value: '${summary.qarz3Days}',
                  icon: CupertinoIcons.calendar_today,
                  color: colors.success,
                  isZero: summary.qarz3Days == 0,
                  onTap: () async {
                    await context.push(RoutePaths.dashboardDueDates, extra: DueDateType.qarz3Days);
                    if (context.mounted) context.read<DashboardCubit>().refresh();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Installments Section
// ---------------------------------------------------------------------------
class _InstallmentsSection extends StatelessWidget {
  const _InstallmentsSection({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(CupertinoIcons.creditcard_fill, color: const Color(0xFF8B5CF6), size: 18),
            const SizedBox(width: 8),
            Text(
              'Bo\'lib to\'lash jadvali',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
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
                child: _IosKpiCard(
                  label: 'Muddati o\'tgan',
                  value: '${summary.installmentExpired}',
                  icon: CupertinoIcons.xmark_octagon_fill,
                  color: colors.error,
                  isZero: summary.installmentExpired == 0,
                  onTap: () async {
                    await context.push(
                      RoutePaths.dashboardInstallmentDueDates,
                      extra: DueDateType.installmentExpired,
                    );
                    if (context.mounted) context.read<DashboardCubit>().refresh();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _IosKpiCard(
                  label: 'Bugun',
                  value: '${summary.installmentToday}',
                  icon: CupertinoIcons.clock_fill,
                  color: const Color(0xFFF59E0B),
                  isZero: summary.installmentToday == 0,
                  onTap: () async {
                    await context.push(
                      RoutePaths.dashboardInstallmentDueDates,
                      extra: DueDateType.installmentToday,
                    );
                    if (context.mounted) context.read<DashboardCubit>().refresh();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _IosKpiCard(
                  label: '3 kun ichida',
                  value: '${summary.installment3Days}',
                  icon: CupertinoIcons.calendar,
                  color: const Color(0xFF3B82F6),
                  isZero: summary.installment3Days == 0,
                  onTap: () async {
                    await context.push(
                      RoutePaths.dashboardInstallmentDueDates,
                      extra: DueDateType.installment3Days,
                    );
                    if (context.mounted) context.read<DashboardCubit>().refresh();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Modern iOS KPI Card
// ---------------------------------------------------------------------------
class _IosKpiCard extends StatelessWidget {
  const _IosKpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isZero,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isZero;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activeColor = isZero ? colors.textTertiary : color;

    return AppCard(
      onTap: isZero
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap();
            },
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: activeColor, size: 17),
              ),
              if (!isZero)
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: activeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: isZero ? colors.textTertiary : colors.textPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  height: 1.2,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Projects Section
// ---------------------------------------------------------------------------
class _ProjectsSection extends StatelessWidget {
  const _ProjectsSection({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = summary.projectsCount;
    final inProgress = summary.projectsInProgress;
    final frozen = summary.projectsFrozen;
    final completed = summary.projectsCompleted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(CupertinoIcons.briefcase_fill, color: colors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Loyihalar portfeli',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                ),
              ],
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              onPressed: () => context.go(RoutePaths.projects),
              child: Row(
                children: [
                  Text(
                    'Barchasi',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(CupertinoIcons.chevron_right, size: 12, color: colors.primary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          onTap: () {
            HapticFeedback.lightImpact();
            context.go(RoutePaths.projects);
          },
          padding: const EdgeInsets.all(18),
          borderRadius: BorderRadius.circular(22),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors.primary.withValues(alpha: 0.2),
                          colors.primary.withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(CupertinoIcons.briefcase, color: colors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$total ta umumiy loyiha',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Barcha faol va yakunlangan ishlar',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(CupertinoIcons.chevron_right, color: colors.textTertiary, size: 18),
                ],
              ),
              const SizedBox(height: 16),
              // Segmented progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 8,
                  child: total == 0
                      ? Container(color: colors.surfaceSecondary)
                      : Row(
                          children: [
                            if (inProgress > 0)
                              Expanded(
                                flex: inProgress,
                                child: Container(color: const Color(0xFF3B82F6)),
                              ),
                            if (frozen > 0)
                              Expanded(
                                flex: frozen,
                                child: Container(color: const Color(0xFFF59E0B)),
                              ),
                            if (completed > 0)
                              Expanded(
                                flex: completed,
                                child: Container(color: const Color(0xFF10B981)),
                              ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ProjectStatusBadge(color: const Color(0xFF3B82F6), label: 'Jarayonda', count: inProgress),
                  _ProjectStatusBadge(color: const Color(0xFFF59E0B), label: 'Muzlatilgan', count: frozen),
                  _ProjectStatusBadge(color: const Color(0xFF10B981), label: 'Yakunlangan', count: completed),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProjectStatusBadge extends StatelessWidget {
  const _ProjectStatusBadge({required this.color, required this.label, required this.count});

  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        Text(
          '$count',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tutorials Section
// ---------------------------------------------------------------------------
class _TutorialsSection extends StatelessWidget {
  const _TutorialsSection({required this.tutorials});

  final List<TutorialItem> tutorials;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(CupertinoIcons.play_circle_fill, color: colors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              'Qo\'llanmalar va darsliklar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...tutorials.map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: AppCard(
              onTap: () {
                HapticFeedback.lightImpact();
                launchUrl(Uri.parse(t.url), mode: LaunchMode.externalApplication);
              },
              padding: const EdgeInsets.all(12),
              borderRadius: BorderRadius.circular(16),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(CupertinoIcons.play_arrow_solid, color: colors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Icon(CupertinoIcons.arrow_up_right_square, size: 18, color: colors.textTertiary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Micro-animation helper
// ---------------------------------------------------------------------------
class _FadeSlideTransition extends StatelessWidget {
  const _FadeSlideTransition({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1.0 - animation.value) * 16),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
