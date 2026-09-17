import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/app_balance_card.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../../../../core/widgets/states/app_empty_state.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../../projects/data/project_models.dart';
import '../../../projects/data/projects_repository.dart';
import '../../data/project_report_models.dart';
import '../../data/reports_repository.dart';

/// Loyihalar hisoboti — loyiha tanlash, dropdown emas (MOBILE_APP_TZ.md 12.4).
class ProjectReportsPage extends StatefulWidget {
  const ProjectReportsPage({super.key});

  @override
  State<ProjectReportsPage> createState() => _ProjectReportsPageState();
}

class _ProjectReportsPageState extends State<ProjectReportsPage> {
  Project? _project;
  ProjectBalanceReport? _report;
  String? _error;
  bool _loading = false;

  Future<void> _pickProject() async {
    final projectsResult = await getIt<ProjectsRepository>().getProjects(page: 1);
    final projects = projectsResult.dataOrNull?.items ?? <Project>[];
    if (!mounted) return;
    final selected = await showAppBottomSheet<Project>(
      context,
      title: 'Loyihani tanlang',
      heightFactor: 0.7,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: projects.length,
        itemBuilder: (context, i) => ListTile(
          title: Text(projects[i].projectName),
          onTap: () => Navigator.of(context).pop(projects[i]),
        ),
      ),
    );
    if (selected != null) {
      setState(() => _project = selected);
      _load();
    }
  }

  Future<void> _load() async {
    if (_project == null) return;
    setState(() {
      _loading = true;
      _report = null;
      _error = null;
    });
    final result = await getIt<ReportsRepository>().getProjectBalance(_project!.id);
    if (!mounted) return;
    setState(() => _loading = false);
    result.when(success: (r) => setState(() => _report = r), failure: (f) => setState(() => _error = f.message));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loyihalar hisoboti')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: _pickProject,
              icon: const Icon(Icons.work_outline_rounded),
              label: Text(_project?.projectName ?? 'Loyihani tanlang'),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_project == null) {
      return const AppEmptyState(title: 'Loyiha tanlanmagan', icon: Icons.work_outline_rounded);
    }
    if (_error != null) return AppErrorState(title: 'Yuklab bo\'lmadi', description: _error, onRetry: _load);
    if (_loading || _report == null) return const AppSkeletonList();

    final report = _report!;
    final colors = context.colors;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        children: [
          AppBalanceCard(currencyLabel: 'UZS', income: report.incomeUzs, expense: report.costsUzs, balance: report.balanceUzs),
          if (report.incomeUsd != Decimal.zero || report.costsUsd != Decimal.zero) ...[
            const SizedBox(height: AppSpacing.sm),
            AppBalanceCard(currencyLabel: 'USD', income: report.incomeUsd, expense: report.costsUsd, balance: report.balanceUsd),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (report.details.isNotEmpty) ...[
            Text('Xarajat turlari', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      for (var i = 0; i < report.details.length; i++)
                        PieChartSectionData(
                          value: report.details[i].amount.toDouble(),
                          title: report.details[i].costTypeName,
                          radius: 70,
                          titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
                          color: Colors.primaries[i % Colors.primaries.length],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final item in report.details)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.costTypeName, style: TextStyle(color: colors.textSecondary)),
                    Text(item.amount.toString()),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
