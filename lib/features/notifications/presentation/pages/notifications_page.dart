import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../core/widgets/states/app_empty_state.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../data/notification_models.dart';
import '../../data/notifications_repository.dart';
import '../cubit/notification_badge_cubit.dart';
import '../cubit/notifications_cubit.dart';

/// Bildirishnomalar ro'yxati + deep-link navigatsiya (MOBILE_APP_TZ.md 14.2-14.3).
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsCubit(getIt<NotificationsRepository>())..loadFirst(),
      child: const _View(),
    );
  }
}

class _View extends StatefulWidget {
  const _View();
  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<NotificationsCubit>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTap(BuildContext context, AppNotification notification) {
    context.read<NotificationsCubit>().markAsRead(notification);
    if (getIt.isRegistered<NotificationBadgeCubit>()) {
      getIt<NotificationBadgeCubit>().refresh();
    }

    final data = notification.data;
    switch (notification.type) {
      case 'subscription':
        context.push(RoutePaths.profileSubscription);
      case 'sms_purchase':
        context.push(RoutePaths.profileSms);
      default:
        if (data != null && data['partner_id'] != null) {
          context.push(RoutePaths.partnerDetail(data['partner_id'] as int));
        } else if (data != null && data['plan_id'] != null) {
          context.push(RoutePaths.installmentDetail(data['plan_id'] as int));
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<NotificationsCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('Bildirishnomalar')),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state.isLoading) return const AppSkeletonList();
          if (state.failure != null && state.items.isEmpty) {
            return AppErrorState(failure: state.failure, onRetry: cubit.loadFirst);
          }
          if (state.isEmpty) return const AppEmptyState(title: 'Bildirishnoma yo\'q', icon: Icons.notifications_none_rounded);

          return RefreshIndicator(
            onRefresh: cubit.refresh,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: state.items.length + (state.hasNext ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                if (i >= state.items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final n = state.items[i];
                final colors = context.colors;
                return Material(
                  color: n.isRead ? colors.surface : colors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _handleTap(context, n),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.border)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!n.isRead)
                            Container(
                              margin: const EdgeInsets.only(top: 6, right: 8),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n.title,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(n.body, style: TextStyle(color: colors.textSecondary)),
                                const SizedBox(height: 6),
                                if (n.createdAt != null)
                                  Text(AppDateFormatter.displayDateTime(n.createdAt!), style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
