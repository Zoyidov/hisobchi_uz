import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../core/widgets/sheets/app_selection_sheet.dart';
import '../../../../core/widgets/states/app_empty_state.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../data/activity_log_models.dart';
import '../../data/activity_log_repository.dart';
import '../cubit/activity_log_cubit.dart';

/// Faollik jurnali — vaqt bo'yicha timeline (MOBILE_APP_TZ.md 16-bo'lim).
class ActivityLogPage extends StatelessWidget {
  const ActivityLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ActivityLogCubit(getIt<ActivityLogRepository>())..loadFirst(),
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
        context.read<ActivityLogCubit>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ActivityLogCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faollik jurnali'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () async {
              final selected = await showAppSelectionSheet<ActivityAction?>(
                context,
                title: 'Amal bo\'yicha filtr',
                selectedValue: cubit.actionFilter,
                items: [
                  const AppSelectionItem(value: null, label: 'Barchasi'),
                  for (final a in ActivityAction.values) AppSelectionItem(value: a, label: a.label),
                ],
              );
              if (context.mounted) cubit.updateFilters(action: selected);
            },
          ),
        ],
      ),
      body: BlocBuilder<ActivityLogCubit, ActivityLogState>(
        builder: (context, state) {
          if (state.isLoading) return const AppSkeletonList();
          if (state.failure != null && state.items.isEmpty) {
            return AppErrorState(failure: state.failure, onRetry: cubit.loadFirst);
          }
          if (state.isEmpty) return const AppEmptyState(title: 'Faoliyat topilmadi', icon: Icons.history_rounded);

          return RefreshIndicator(
            onRefresh: cubit.refresh,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: state.items.length + (state.hasNext ? 1 : 0),
              itemBuilder: (context, i) {
                if (i >= state.items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final entry = state.items[i];
                final isLast = i == state.items.length - 1;
                return _TimelineTile(entry: entry, isLast: isLast);
              },
            ),
          );
        },
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.entry, required this.isLast});
  final ActivityLogEntry entry;
  final bool isLast;

  Color _color(BuildContext context) {
    final colors = context.colors;
    return switch (entry.action) {
      ActivityAction.created => colors.success,
      ActivityAction.updated => colors.info,
      ActivityAction.cancelled => colors.warning,
      ActivityAction.deleted => colors.error,
      ActivityAction.restored => colors.success,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = _color(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              if (!isLast) Expanded(child: Container(width: 2, color: colors.border)),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.summary, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 2),
                  Text(entry.modelType, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                  if (entry.createdAt != null)
                    Text(AppDateFormatter.displayDateTime(entry.createdAt!), style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
