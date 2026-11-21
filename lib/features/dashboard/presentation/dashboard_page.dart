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
import '../../../core/widgets/feedback/subscription_banner.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/widgets/states/app_error_state.dart';
import '../../../core/widgets/states/app_skeleton.dart';
import '../../notifications/presentation/cubit/notification_badge_cubit.dart';
import '../../partners/presentation/pages/wallet_form_page.dart';
import '../data/dashboard_models.dart';
import '../data/dashboard_repository.dart';
import 'dashboard_cubit.dart';
import '../../../core/icons/app_icons.dart';

part 'widgets/dashboard_header.dart';
part 'widgets/dashboard_overview.dart';
part 'widgets/dashboard_actions.dart';
part 'widgets/dashboard_payments.dart';
part 'widgets/dashboard_projects.dart';
part 'widgets/dashboard_tutorials.dart';
part 'widgets/dashboard_style.dart';

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
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
      constraints: const BoxConstraints(maxWidth: 640),
      child: child,
    ),
  );
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
      const SizedBox(height: 12),
      const _QuickActions(),
      const SizedBox(height: 12),
      _PaymentOverview(summary: summary),
      const SizedBox(height: 12),
      _ProjectsSection(summary: summary),
      if (tutorials.isNotEmpty) ...[
        const SizedBox(height: 12),
        _TutorialsSection(tutorials: tutorials),
      ],
    ],
  );
}
