import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_permission.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/paging/paged_list_cubit.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/chips/app_filter_chip.dart';
import '../../../../core/widgets/inputs/app_search_field.dart';
import '../../../../core/widgets/lists/app_paged_list_view.dart';
import '../../../../core/widgets/navigation/permission_guard.dart';
import '../../data/project_models.dart';
import '../../data/projects_repository.dart';
import '../cubit/projects_cubit.dart';
import '../widgets/project_card.dart';
import 'project_detail_page.dart';
import 'project_form_page.dart';

/// Loyihalar ro'yxati (MOBILE_APP_TZ.md 10.2).
class ProjectsListPage extends StatelessWidget {
  const ProjectsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectsCubit(getIt<ProjectsRepository>())..loadFirst(),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ProjectsCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loyihalar'),
        actions: [
          PermissionGuard(
            permission: AppPermission.projectsCreate,
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _openCreate(context),
                icon: const Icon(CupertinoIcons.plus, size: 15),
                label: const Text('Qo\'shish', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
            child: AppSearchField(onChanged: cubit.updateSearch, hint: 'Loyiha nomi bo\'yicha qidirish'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: AppFilterChip(label: 'Barchasi', selected: cubit.status == null, onTap: () => cubit.updateStatus(null)),
                  ),
                  for (final status in ProjectStatus.values)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xs),
                      child: AppFilterChip(
                        label: status.label,
                        selected: cubit.status == status,
                        onTap: () => cubit.updateStatus(status),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: BlocBuilder<ProjectsCubit, PagedListState<Project>>(
              builder: (context, state) {
                return AppPagedListView<Project>(
                  state: state,
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, 110),
                  onLoadMore: cubit.loadMore,
                  onRefresh: cubit.refresh,
                  onRetry: cubit.loadFirst,
                  emptyIcon: CupertinoIcons.briefcase,
                  emptyTitle: 'Loyihalar topilmadi',
                  emptyAction: 'Loyiha qo\'shish',
                  onEmptyAction: () => _openCreate(context),
                  itemBuilder: (context, project, index) => ProjectCard(
                    project: project,
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (_) => ProjectDetailPage(projectId: project.id),
                      ));
                      if (context.mounted) cubit.refresh();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openCreate(BuildContext context) async {
    final cubit = context.read<ProjectsCubit>();
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ProjectFormPage()));
    if (context.mounted) cubit.refresh();
  }
}
