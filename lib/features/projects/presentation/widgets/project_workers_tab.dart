import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/media/app_avatar.dart';
import '../../../../core/widgets/sheets/app_multi_selection_sheet.dart';
import '../../../../core/widgets/sheets/app_selection_sheet.dart';
import '../../../../core/widgets/states/app_empty_state.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../../documents/data/document_models.dart';
import '../../../documents/data/documents_repository.dart';
import '../../data/project_models.dart';
import '../../data/projects_repository.dart';
import '../cubit/project_subtabs_cubit.dart';

/// Tab D: Ishchilar (MOBILE_APP_TZ.md 10.4-D).
class ProjectWorkersTab extends StatelessWidget {
  const ProjectWorkersTab({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectWorkersCubit(getIt<ProjectsRepository>(), projectId)..load(),
      child: _View(projectId: projectId),
    );
  }
}

class _View extends StatelessWidget {
  const _View({required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectWorkersCubit, ListState<ProjectWorker>>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _assignWorkers(context, projectId),
                  icon: const Icon(Icons.person_add_alt_rounded),
                  label: const Text('Ishchi biriktirish'),
                ),
              ),
            ),
            Expanded(
              child: switch (state) {
                ListLoading() => const AppSkeletonList(),
                ListError(:final failure) =>
                  AppErrorState(failure: failure, onRetry: () => context.read<ProjectWorkersCubit>().load()),
                ListLoaded(:final items) => items.isEmpty
                    ? const AppEmptyState(title: 'Ishchilar biriktirilmagan', icon: Icons.engineering_outlined)
                    : RefreshIndicator(
                        onRefresh: () => context.read<ProjectWorkersCubit>().load(),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, i) {
                            final worker = items[i];
                            return AppCard(
                              child: Row(
                                children: [
                                  AppAvatar(name: worker.name, size: 40),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(worker.name, style: Theme.of(context).textTheme.titleSmall),
                                        if (worker.positionName != null)
                                          Text(worker.positionName!, style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline, color: context.colors.error),
                                    onPressed: () async {
                                      final error = await context.read<ProjectWorkersCubit>().removeWorker(worker.id);
                                      if (error != null && context.mounted) AppSnackbar.error(context, error.message);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _assignWorkers(BuildContext context, int projectId) async {
    final cubit = context.read<ProjectWorkersCubit>();
    final result = await getIt<DocumentsRepository>().getWorkers(notInProjectId: projectId);
    final available = result.dataOrNull ?? <Worker>[];
    if (!context.mounted) return;
    if (available.isEmpty) {
      AppSnackbar.error(context, 'Biriktirish uchun bo\'sh ishchi yo\'q');
      return;
    }
    final selected = await showAppMultiSelectionSheet<int>(
      context,
      title: 'Ishchilar',
      items: available.map((w) => AppSelectionItem(value: w.id, label: w.name)).toList(),
    );
    if (selected == null || selected.isEmpty || !context.mounted) return;
    final error = await cubit.addWorkers(selected);
    if (error != null && context.mounted) AppSnackbar.error(context, error.message);
  }
}
