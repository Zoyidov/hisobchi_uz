import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/icons/app_edit_icon.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/constants/app_permission.dart';
import '../../../../core/widgets/navigation/permission_guard.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/media/app_file_preview.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/project_balance_card.dart';
import '../../../../core/widgets/chips/app_status_chip.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../data/project_models.dart';
import '../../data/projects_repository.dart';
import '../cubit/project_detail_cubit.dart';
import '../widgets/project_contracts_tab.dart';
import '../widgets/project_costs_tab.dart';
import '../widgets/project_incomes_tab.dart';
import '../widgets/project_workers_tab.dart';
import '../widgets/project_status_sheet.dart';
import 'project_form_page.dart';

/// Loyiha kartochkasi — 4 tabli ekran (MOBILE_APP_TZ.md 10.4).
class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProjectDetailCubit(getIt<ProjectsRepository>(), projectId)..load(),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: BlocBuilder<ProjectDetailCubit, ProjectDetailState>(
        builder: (context, state) {
          return switch (state) {
            ProjectDetailLoading() => const Scaffold(body: AppSkeletonList()),
            ProjectDetailError(:final failure) => Scaffold(
              appBar: AppBar(),
              body: AppErrorState(
                failure: failure,
                onRetry: () => context.read<ProjectDetailCubit>().load(),
              ),
            ),
            ProjectDetailLoaded(:final project) => _Loaded(project: project),
          };
        },
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final accounts = project.accounts;
    return Scaffold(
      appBar: AppBar(
        title: Text(project.projectName, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const AppEditIcon(),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProjectFormPage(editing: project),
                ),
              );
              if (context.mounted) context.read<ProjectDetailCubit>().refresh();
            },
          ),
          PermissionGuard(
            permission: AppPermission.projectsEdit,
            child: IconButton(
              tooltip: 'Loyiha holatini o‘zgartirish',
              icon: const Icon(Icons.tune_rounded, size: 22),
              onPressed: () => _changeStatus(context, project),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final scrollable =
                      constraints.maxWidth < 300 ||
                      MediaQuery.textScalerOf(context).scale(12) > 16;
                  return TabBar(
                    isScrollable: scrollable,
                    tabAlignment: scrollable
                        ? TabAlignment.start
                        : TabAlignment.fill,
                    dividerHeight: 0,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: const EdgeInsets.all(4),
                    indicator: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: context.colors.textSecondary,
                    labelStyle: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                    labelPadding: EdgeInsets.symmetric(
                      horizontal: scrollable ? 12 : 4,
                    ),
                    tabs: const [
                      Tab(text: 'Xarajatlar'),
                      Tab(text: 'Daromadlar'),
                      Tab(text: 'Ishchilar'),
                      Tab(text: 'Shartnomalar'),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            project.projectOwner,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      _StatusBadge(project: project),
                    ],
                  ),
                ),
                if (project.files.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library_outlined, size: 19),
                      label: Text('Loyiha fayllari (${project.files.length})'),
                      onPressed: () => showAppBottomSheet<void>(
                        context,
                        title: 'Loyiha fayllari',
                        heightFactor: .7,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: AppFilePreview(files: project.files),
                        ),
                      ),
                    ),
                  ),
                ],
                if (accounts != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ProjectBalanceCard(account: accounts),
                ],
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                ProjectCostsTab(projectId: project.id),
                ProjectIncomesTab(projectId: project.id),
                ProjectWorkersTab(projectId: project.id),
                ProjectContractsTab(projectId: project.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _changeStatus(BuildContext context, Project project) async {
  final cubit = context.read<ProjectDetailCubit>();
  final saved = await showProjectStatusSheet(context, project: project);
  if (saved == true && context.mounted && !cubit.isClosed) {
    AppSnackbar.success(context, 'Loyiha holati yangilandi');
    await cubit.refresh();
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final chip = AppStatusChip(
      label: project.status.label,
      tone: switch (project.status) {
        ProjectStatus.inProgress => AppStatusChipTone.info,
        ProjectStatus.frozen => AppStatusChipTone.warning,
        ProjectStatus.completed => AppStatusChipTone.success,
      },
    );
    return PermissionGuard(
      permission: AppPermission.projectsEdit,
      fallback: chip,
      child: Tooltip(
        message: 'Loyiha holatini o‘zgartirish',
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _changeStatus(context, project),
          child: chip,
        ),
      ),
    );
  }
}
