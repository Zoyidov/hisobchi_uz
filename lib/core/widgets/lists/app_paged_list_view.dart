import 'package:flutter/material.dart';

import '../../constants/app_durations.dart' show AppPageSize;
import '../../paging/paged_list_cubit.dart';
import '../../theme/app_spacing.dart';
import '../buttons/app_button.dart';
import '../states/app_empty_state.dart';
import '../states/app_error_state.dart';
import '../states/app_skeleton.dart';

/// Umumiy infinite-scroll ro'yxat — Loading/Empty/Error/Success 4 holati bilan
/// (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 143, MOBILE_APP_TZ.md 4.7, 7-bandlar).
class AppPagedListView<T> extends StatelessWidget {
  const AppPagedListView({
    super.key,
    required this.state,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.onRefresh,
    required this.onRetry,
    this.emptyTitle = 'Ma\'lumot topilmadi',
    this.emptyDescription,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyAction,
    this.onEmptyAction,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.header,
    this.controller,
    this.primary,
    this.physics,
  });

  final PagedListState<T> state;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final String emptyTitle;
  final String? emptyDescription;
  final IconData emptyIcon;
  final String? emptyAction;
  final VoidCallback? onEmptyAction;
  final EdgeInsetsGeometry padding;
  final Widget? header;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.items.isEmpty) {
      return const AppSkeletonList();
    }

    if (state.failure != null && state.items.isEmpty) {
      return AppErrorState(failure: state.failure, onRetry: onRetry);
    }

    if (state.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          controller: controller,
          primary: primary,
          physics: physics ?? const AlwaysScrollableScrollPhysics(),
          padding: padding,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: AppEmptyState(
                title: emptyTitle,
                description: emptyDescription,
                icon: emptyIcon,
                actionLabel: emptyAction,
                onAction: onEmptyAction,
              ),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == Axis.vertical) {
          final metrics = notification.metrics;
          final threshold =
              metrics.maxScrollExtent - (88 * AppPageSize.infiniteScrollThreshold);
          if (metrics.pixels >= threshold && !state.isLoadingMore && state.hasNext) {
            onLoadMore();
          }
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.separated(
          controller: controller,
          primary: primary,
          physics: physics ?? const AlwaysScrollableScrollPhysics(),
          padding: padding,
          itemCount: (header != null ? 1 : 0) +
              state.items.length +
              (state.hasNext || state.isLoadingMore ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            var i = index;
            if (header != null) {
              if (i == 0) return header!;
              i -= 1;
            }
            if (i >= state.items.length) {
              if (state.failure != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: AppButton.secondary(
                      label: 'Qayta urinish',
                      expand: false,
                      onPressed: onLoadMore,
                    ),
                  ),
                );
              }
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return itemBuilder(context, state.items[i], i);
          },
        ),
      ),
    );
  }
}
