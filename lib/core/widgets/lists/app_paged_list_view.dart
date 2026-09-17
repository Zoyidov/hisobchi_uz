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
class AppPagedListView<T> extends StatefulWidget {
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

  @override
  State<AppPagedListView<T>> createState() => _AppPagedListViewState<T>();
}

class _AppPagedListViewState<T> extends State<AppPagedListView<T>> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - (88 * AppPageSize.infiniteScrollThreshold);
    if (_scrollController.position.pixels >= threshold) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    if (state.isLoading && state.items.isEmpty) {
      return const AppSkeletonList();
    }

    if (state.failure != null && state.items.isEmpty) {
      return AppErrorState(failure: state.failure, onRetry: widget.onRetry);
    }

    if (state.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: AppEmptyState(
                title: widget.emptyTitle,
                description: widget.emptyDescription,
                icon: widget.emptyIcon,
                actionLabel: widget.emptyAction,
                onAction: widget.onEmptyAction,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.separated(
        controller: _scrollController,
        padding: widget.padding,
        itemCount: (widget.header != null ? 1 : 0) + state.items.length + (state.hasNext || state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          var i = index;
          if (widget.header != null) {
            if (i == 0) return widget.header!;
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
                    onPressed: widget.onLoadMore,
                  ),
                ),
              );
            }
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return widget.itemBuilder(context, state.items[i], i);
        },
      ),
    );
  }
}
