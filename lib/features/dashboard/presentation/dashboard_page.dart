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
import '../../../core/widgets/cards/app_card.dart';
import '../../../core/widgets/feedback/subscription_banner.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/widgets/states/app_error_state.dart';
import '../../../core/widgets/states/app_skeleton.dart';
import '../../notifications/presentation/cubit/notification_badge_cubit.dart';
import '../../partners/presentation/pages/wallet_form_page.dart';
import '../data/dashboard_models.dart';
import '../data/dashboard_repository.dart';
import 'dashboard_cubit.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => DashboardCubit(getIt<DashboardRepository>())..load(),
    child: const _DashboardView(),
  );
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  @override
  void initState() {
    super.initState();
    getIt<NotificationBadgeCubit>().refresh();
  }

  Future<void> _refresh() async {
    HapticFeedback.lightImpact();
    await Future.wait([
      context.read<DashboardCubit>().refresh(),
      getIt<NotificationBadgeCubit>().refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.background,
    body: SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          key: const PageStorageKey('dashboard-scroll'),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              sliver: SliverToBoxAdapter(
                child: _constrain(const _DashboardHeader()),
              ),
            ),
            SliverToBoxAdapter(
              child: _constrain(
                SubscriptionBanner(
                  onAction: () => context.push(RoutePaths.profileSubscription),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _constrain(
                  BlocBuilder<DashboardCubit, DashboardState>(
                    builder: (context, state) => switch (state) {
                      DashboardLoading() => const _DashboardSkeleton(),
                      DashboardError(:final failure) => AppErrorState(
                        failure: failure,
                        onRetry: () => context.read<DashboardCubit>().load(),
                      ),
                      DashboardLoaded(:final summary, :final tutorials) =>
                        _DashboardContent(
                          summary: summary,
                          tutorials: tutorials,
                        ),
                    },
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
    ),
  );

  Widget _constrain(Widget child) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1040),
      child: child,
    ),
  );
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  String get _greeting => switch (DateTime.now().hour) {
    >= 5 && < 11 => 'Xayrli tong',
    >= 11 && < 17 => 'Xayrli kun',
    >= 17 && < 22 => 'Xayrli kech',
    _ => 'Xayrli tun',
  };

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserCubit>().currentUserOrNull;
    final owner = context.watch<OwnerContextCubit>().state;
    final colors = context.colors;
    return Row(
      children: [
        if (user != null) ...[
          Semantics(
            button: true,
            label: 'Profilni ochish',
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => context.go(RoutePaths.profile),
              child: Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.borderSubtle),
                ),
                child: SvgPicture.asset(
                  'assets/icon/hisup_mark.svg',
                  semanticsLabel: 'Hisup logosi',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                user?.name ?? 'Boshqaruv paneli',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              if (owner.isStaffMode) ...[
                const SizedBox(height: 4),
                Text(
                  '${owner.ownerName ?? 'Tashkilot'} hisobida',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: colors.primary),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        BlocBuilder<NotificationBadgeCubit, int>(
          builder: (context, count) => IconButton.filledTonal(
            tooltip: 'Bildirishnomalar',
            style: IconButton.styleFrom(
              backgroundColor: colors.surface,
              minimumSize: const Size(48, 48),
            ),
            onPressed: () => context.push(RoutePaths.profileNotifications),
            icon: Badge(
              isLabelVisible: count > 0,
              label: Text(count > 99 ? '99+' : '$count'),
              child: const Icon(Icons.notifications_none_rounded),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.summary, required this.tutorials});
  final DashboardSummary summary;
  final List<TutorialItem> tutorials;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _OverviewCard(summary: summary),
      const SizedBox(height: 16),
      const _QuickActions(),
      const SizedBox(height: 16),
      _PaymentOverview(summary: summary),
      const SizedBox(height: 16),
      _ProjectsSection(summary: summary),
      if (tutorials.isNotEmpty) ...[
        const SizedBox(height: 16),
        _TutorialsSection(tutorials: tutorials),
      ],
    ],
  );
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.summary});
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final overdue = summary.qarzExpired + summary.installmentExpired;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            overdue > 0
                ? '$overdue ta muddati o‘tgan to‘lov'
                : 'Hisob-kitoblar nazoratda',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              final tiles = [
                _OverviewTile(
                  value: summary.partnersCount,
                  label: 'Hamkorlar',
                  icon: Icons.people_outline_rounded,
                  onTap: () => context.go(RoutePaths.partners),
                ),
                _OverviewTile(
                  value: summary.projectsCount,
                  label: 'Loyihalar',
                  icon: Icons.work_outline_rounded,
                  onTap: () => context.go(RoutePaths.projects),
                ),
                // This tile links to partner debts, so its count uses the same source.
                _OverviewTile(
                  value: summary.qarzToday,
                  label: 'Bugungi qarzlar',
                  icon: Icons.schedule_rounded,
                  onTap: () => _openDue(context, DueDateType.qarzToday),
                ),
              ];
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tile in tiles)
                    SizedBox(
                      width: constraints.maxWidth < 220
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 16) / 3,
                      child: tile,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OverviewTile extends StatelessWidget {
  const _OverviewTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final int value;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(10),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: context.colors.textTertiary, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$value',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserCubit>().currentUserOrNull;
    final owner = context.watch<OwnerContextCubit>().state;
    final colors = context.colors;
    final actions =
        <
              ({
                String permission,
                String label,
                IconData icon,
                Color color,
                VoidCallback onTap,
              })
            >[
              (
                permission: AppPermission.walletsDebtCreate,
                label: 'Kirim',
                icon: Icons.south_west_rounded,
                color: colors.success,
                onTap: () => _wallet(context, 'debt'),
              ),
              (
                permission: AppPermission.walletsCreditCreate,
                label: 'Chiqim',
                icon: Icons.north_east_rounded,
                color: colors.error,
                onTap: () => _wallet(context, 'credit'),
              ),
              (
                permission: AppPermission.partnersCreate,
                label: 'Hamkor',
                icon: Icons.person_add_alt_1_rounded,
                color: colors.primary,
                onTap: () async {
                  await context.push(RoutePaths.partnerCreate);
                  if (context.mounted) {
                    await context.read<DashboardCubit>().refresh();
                  }
                },
              ),
              (
                permission: AppPermission.projectsCreate,
                label: 'Loyiha',
                icon: Icons.create_new_folder_outlined,
                color: colors.accentViolet,
                onTap: () => context.go(RoutePaths.projects),
              ),
            ]
            .where(
              (action) =>
                  user?.hasPermission(action.permission, owner) ?? false,
            )
            .toList();
    if (actions.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns =
                constraints.maxWidth < 280 ||
                    MediaQuery.textScalerOf(context).scale(14) > 20
                ? 2
                : actions.length;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final action in actions)
                  SizedBox(
                    width:
                        (constraints.maxWidth - (columns - 1) * 10) / columns,
                    child: AppCard(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        action.onTap();
                      },
                      hasShadow: false,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 6,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        children: [
                          _IconTile(
                            icon: action.icon,
                            color: action.color,
                            size: 32,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            action.label,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _wallet(BuildContext context, String type) async {
    final result = await showWalletFormSheet(context, type: type);
    if (result != null && context.mounted) {
      await context.read<DashboardCubit>().refresh();
    }
  }
}

Future<void> _openDue(BuildContext context, DueDateType type) async {
  await context.push(
    type.isInstallment
        ? RoutePaths.dashboardInstallmentDueDates
        : RoutePaths.dashboardDueDates,
    extra: type,
  );
  if (context.mounted) await context.read<DashboardCubit>().refresh();
}

class _PaymentOverview extends StatelessWidget {
  const _PaymentOverview({required this.summary});
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final groups = [
      (
        label: 'Hamkorlar qarzi',
        values: [summary.qarzExpired, summary.qarzToday, summary.qarz3Days],
        types: [
          DueDateType.qarzExpired,
          DueDateType.qarzToday,
          DueDateType.qarz3Days,
        ],
      ),
      (
        label: 'Bo‘lib to‘lash',
        values: [
          summary.installmentExpired,
          summary.installmentToday,
          summary.installment3Days,
        ],
        types: [
          DueDateType.installmentExpired,
          DueDateType.installmentToday,
          DueDateType.installment3Days,
        ],
      ),
    ];
    final accents = [colors.error, colors.warning, colors.info];
    final labels = ['Muddati o‘tgan', 'Bugun', '3 kun ichida'];
    return AppCard(
      hasShadow: false,
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'To‘lovlar nazorati',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          for (var g = 0; g < groups.length; g++) ...[
            if (g > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: colors.divider),
              )
            else
              const SizedBox(height: 12),
            Text(
              groups[g].label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked =
                    constraints.maxWidth < 240 ||
                    MediaQuery.textScalerOf(context).scale(12) > 20;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < 3; i++)
                      SizedBox(
                        width: stacked
                            ? constraints.maxWidth
                            : (constraints.maxWidth - 16) / 3,
                        child: Material(
                          color: accents[i].withValues(alpha: .07),
                          borderRadius: BorderRadius.circular(12),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: groups[g].values[i] == 0
                                ? null
                                : () => _openDue(context, groups[g].types[i]),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${groups[g].values[i]}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: groups[g].values[i] == 0
                                              ? colors.textTertiary
                                              : accents[i],
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    labels[i],
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: colors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _ProjectsSection extends StatelessWidget {
  const _ProjectsSection({required this.summary});
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statuses = [
      (
        label: 'Jarayonda',
        count: summary.projectsInProgress,
        color: colors.primary,
      ),
      (
        label: 'Muzlatilgan',
        count: summary.projectsFrozen,
        color: colors.warning,
      ),
      (
        label: 'Yakunlangan',
        count: summary.projectsCompleted,
        color: colors.success,
      ),
    ];
    final classified = statuses.fold<int>(0, (sum, item) => sum + item.count);
    final unclassified = (summary.projectsCount - classified).clamp(
      0,
      summary.projectsCount,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          hasShadow: false,
          borderRadius: BorderRadius.circular(22),
          padding: const EdgeInsets.all(14),
          onTap: () => context.go(RoutePaths.projects),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _IconTile(
                    icon: Icons.work_outline_rounded,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${summary.projectsCount} ta loyiha',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (summary.projectsCount == 0)
                Text(
                  'Birinchi loyihangizni qo‘shib, ishlarni shu yerda kuzating.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                )
              else
                Semantics(
                  label: statuses
                      .map((s) => '${s.label}: ${s.count}')
                      .join(', '),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 8,
                      child: Row(
                        children: [
                          for (final status in statuses)
                            if (status.count > 0)
                              Expanded(
                                flex: status.count,
                                child: ColoredBox(color: status.color),
                              ),
                          if (unclassified > 0)
                            Expanded(
                              flex: unclassified,
                              child: ColoredBox(color: colors.surfaceTertiary),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 20,
                runSpacing: 12,
                children: [
                  for (final status in statuses)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: status.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${status.label}  ${status.count}',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TutorialsSection extends StatelessWidget {
  const _TutorialsSection({required this.tutorials});
  final List<TutorialItem> tutorials;

  Future<void> _open(BuildContext context, TutorialItem tutorial) async {
    final uri = Uri.tryParse(tutorial.url);
    var opened = false;
    if (uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } on Exception {
        opened = false;
      }
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Qo‘llanmani ochib bo‘lmadi. Keyinroq qayta urinib ko‘ring.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => AppCard(
    hasShadow: false,
    padding: EdgeInsets.zero,
    borderRadius: BorderRadius.circular(18),
    child: ExpansionTile(
      key: const PageStorageKey('dashboard-tutorials-expanded'),
      shape: const Border(),
      collapsedShape: const Border(),
      leading: Icon(
        Icons.play_circle_outline_rounded,
        color: context.colors.primary,
      ),
      title: Text(
        'Qo‘llanmalar (${tutorials.length})',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      children: [
        for (final tutorial in tutorials)
          ListTile(
            leading: Icon(
              Icons.play_arrow_rounded,
              color: context.colors.primary,
            ),
            title: Text(
              tutorial.title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: const Icon(Icons.open_in_new_rounded, size: 18),
            onTap: () => _open(context, tutorial),
          ),
      ],
    ),
  );
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.color, this.size = 44});
  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Icon(icon, color: color, size: 22),
  );
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppSkeletonBox(height: 88, borderRadius: BorderRadius.circular(20)),
      const SizedBox(height: 16),
      Row(
        children: [
          for (var i = 0; i < 4; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == 3 ? 0 : 8),
                child: AppSkeletonBox(
                  height: 80,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 16),
      AppSkeletonBox(height: 240, borderRadius: BorderRadius.circular(20)),
      const SizedBox(height: 16),
      AppSkeletonBox(height: 120, borderRadius: BorderRadius.circular(20)),
    ],
  );
}
