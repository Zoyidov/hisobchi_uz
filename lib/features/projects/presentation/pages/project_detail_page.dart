import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/app_balance_card.dart';
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
import 'project_form_page.dart';

/// Loyiha kartochkasi — 4 tabli ekran (MOBILE_APP_TZ.md 10.4).
class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectDetailCubit(getIt<ProjectsRepository>(), projectId)..load(),
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
                body: AppErrorState(failure: failure, onRetry: () => context.read<ProjectDetailCubit>().load()),
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
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ProjectFormPage(editing: project)));
              if (context.mounted) context.read<ProjectDetailCubit>().refresh();
            },
          ),
          PopupMenuButton<ProjectStatus>(
            onSelected: (status) => context.read<ProjectDetailCubit>().updateStatus(status),
            itemBuilder: (context) => ProjectStatus.values
                .map((s) => PopupMenuItem(value: s, child: Text(s.label)))
                .toList(),
          ),
        ],
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'Shartnomalar'),
            Tab(text: 'Daromadlar'),
            Tab(text: 'Xarajatlar'),
            Tab(text: 'Ishchilar'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(project.projectOwner, style: Theme.of(context).textTheme.bodyMedium),
                    AppStatusChip(
                      label: project.status.label,
                      tone: switch (project.status) {
                        ProjectStatus.inProgress => AppStatusChipTone.info,
                        ProjectStatus.frozen => AppStatusChipTone.warning,
                        ProjectStatus.completed => AppStatusChipTone.success,
                      },
                    ),
                  ],
                ),
                if (accounts != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppBalanceCard(
                    currencyLabel: 'UZS',
                    income: accounts.uzs.income,
                    expense: accounts.uzs.cost,
                    balance: accounts.uzs.balance,
                  ),
                  if (accounts.usd.income != Decimal.zero || accounts.usd.cost != Decimal.zero) ...[
                    const SizedBox(height: AppSpacing.sm),
                    AppBalanceCard(
                      currencyLabel: 'USD',
                      income: accounts.usd.income,
                      expense: accounts.usd.cost,
                      balance: accounts.usd.balance,
                    ),
                  ],
                ],
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                ProjectContractsTab(projectId: project.id),
                ProjectIncomesTab(projectId: project.id),
                ProjectCostsTab(projectId: project.id),
                ProjectWorkersTab(projectId: project.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
