import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters/money_formatter.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../../../../core/widgets/states/app_empty_state.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../../projects/data/project_models.dart';
import '../../../projects/data/projects_repository.dart';
import '../../../projects/presentation/widgets/project_costs_tab.dart';
import '../../../projects/presentation/widgets/project_incomes_tab.dart';
import '../../data/project_report_models.dart';
import '../../data/reports_repository.dart';

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
  int _request = 0;

  Future<void> _pickProject() async {
    final selected = await showAppBottomSheet<Project>(
      context,
      title: 'Loyihani tanlang',
      heightFactor: .8,
      child: const _ProjectPicker(),
    );
    if (selected == null || !mounted) return;
    setState(() => _project = selected);
    await _load();
  }

  Future<void> _load() async {
    final project = _project;
    if (project == null) return;
    final request = ++_request;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await getIt<ReportsRepository>().getProjectBalance(
      project.id,
    );
    if (!mounted || request != _request) return;
    setState(() {
      _loading = false;
      result.when(
        success: (report) => _report = report,
        failure: (error) => _error = error.message,
      );
    });
  }

  Future<void> _openEntries({CostBreakdownItem? category}) async {
    final project = _project;
    if (project == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(category == null ? 'Kirim' : category.costTypeName),
          ),
          body: SafeArea(
            child: category == null
                ? ProjectIncomesTab(projectId: project.id)
                : ProjectCostsTab(
                    projectId: project.id,
                    costTypeId: category.costTypeId,
                  ),
          ),
        ),
      ),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      centerTitle: true,
      title: Text(
        'Moliya hisoboti',
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    body: SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: OutlinedButton.icon(
              onPressed: _pickProject,
              icon: const Icon(Icons.work_outline_rounded, size: 19),
              label: Row(
                children: [
                  Expanded(
                    child: Text(
                      _project?.projectName ?? 'Loyihani tanlang',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                ],
              ),
            ),
          ),
          Expanded(child: _body(context)),
        ],
      ),
    ),
  );
  Widget _body(BuildContext context) {
    if (_project == null) {
      return const AppEmptyState(
        title: 'Loyiha tanlanmagan',
        description: 'Moliya hisobotini ko‘rish uchun loyihani tanlang',
        icon: Icons.work_outline_rounded,
      );
    }
    if (_error != null) {
      return AppErrorState(description: _error, onRetry: _load);
    }
    if (_loading || _report == null) return const AppSkeletonList();
    final report = _report!;
    final colors = context.colors;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _FinanceCard(
            label: 'Qoldiq',
            icon: report.balanceUzs < Decimal.zero
                ? Icons.trending_down_rounded
                : Icons.trending_up_rounded,
            uzs: report.balanceUzs,
            usd: report.balanceUsd,
            tint: colors.primary,
            filled: true,
          ),
          const SizedBox(height: 16),
          _FinanceCard(
            label: 'Kirim',
            icon: Icons.south_west_rounded,
            uzs: report.incomeUzs,
            usd: report.incomeUsd,
            tint: colors.success,
            onTap: () => _openEntries(),
          ),
          const SizedBox(height: 16),
          AppCard(
            hasShadow: false,
            padding: const EdgeInsets.all(18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.error.withValues(alpha: .3),
              width: 1.2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FinanceHeader(
                  label: 'Chiqim',
                  icon: Icons.north_east_rounded,
                  uzs: report.costsUzs,
                  usd: report.costsUsd,
                  tint: colors.error,
                ),
                const SizedBox(height: 18),
                Divider(height: 1, color: colors.divider),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 17,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kategoriyalar bo‘yicha',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      '${report.details.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (report.details.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 36,
                          color: colors.textTertiary,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Xarajatlar mavjud emas',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                for (final detail in report.details)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CategoryCard(
                      detail: detail,
                      totalUzs: report.details.fold(
                        Decimal.zero,
                        (sum, item) => sum + item.amount,
                      ),
                      totalUsd: report.details.fold(
                        Decimal.zero,
                        (sum, item) => sum + item.summaUsd,
                      ),
                      onTap: detail.costTypeId <= 0
                          ? null
                          : () => _openEntries(category: detail),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceCard extends StatelessWidget {
  const _FinanceCard({
    required this.label,
    required this.icon,
    required this.uzs,
    required this.usd,
    required this.tint,
    this.filled = false,
    this.onTap,
  });
  final String label;
  final IconData icon;
  final Decimal uzs;
  final Decimal usd;
  final Color tint;
  final bool filled;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => AppCard(
    hasShadow: false,
    padding: const EdgeInsets.all(18),
    borderRadius: BorderRadius.circular(20),
    color: filled ? tint : context.colors.surface,
    border: Border.all(color: tint.withValues(alpha: .3), width: 1.2),
    onTap: onTap,
    child: _FinanceHeader(
      label: label,
      icon: icon,
      uzs: uzs,
      usd: usd,
      tint: tint,
      filled: filled,
      actionable: onTap != null,
    ),
  );
}

class _FinanceHeader extends StatelessWidget {
  const _FinanceHeader({
    required this.label,
    required this.icon,
    required this.uzs,
    required this.usd,
    required this.tint,
    this.filled = false,
    this.actionable = false,
  });
  final String label;
  final IconData icon;
  final Decimal uzs;
  final Decimal usd;
  final Color tint;
  final bool filled;
  final bool actionable;
  @override
  Widget build(BuildContext context) {
    final foreground = filled ? Colors.white : tint;
    final heading = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: filled
                ? Colors.white.withValues(alpha: .16)
                : tint.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 21, color: foreground),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: filled ? Colors.white : context.colors.textPrimary,
            ),
          ),
        ),
      ],
    );
    final amounts = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          MoneyFormatter.format(uzs, currencyTypeId: 1),
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: foreground,
          ),
        ),
        if (filled || usd != Decimal.zero) ...[
          const SizedBox(height: 7),
          Text(
            MoneyFormatter.format(usd, currencyTypeId: 2),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: foreground.withValues(alpha: .9),
            ),
          ),
        ],
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 310 ||
            MediaQuery.textScalerOf(context).scale(14) > 19) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [heading, const SizedBox(height: 14), amounts],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: heading),
            const SizedBox(width: 12),
            Expanded(flex: 6, child: amounts),
            if (actionable) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: context.colors.textTertiary,
                size: 17,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.detail,
    required this.totalUzs,
    required this.totalUsd,
    this.onTap,
  });
  final CostBreakdownItem detail;
  final Decimal totalUzs;
  final Decimal totalUsd;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: context.colors.primary.withValues(alpha: .05),
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    detail.costTypeName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 19,
                    color: context.colors.textTertiary,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (detail.amount != Decimal.zero ||
                detail.summaUsd == Decimal.zero)
              _CurrencyShare(
                amount: detail.amount,
                total: totalUzs,
                currency: 1,
              ),
            if (detail.summaUsd != Decimal.zero) ...[
              if (detail.amount != Decimal.zero) const SizedBox(height: 10),
              _CurrencyShare(
                amount: detail.summaUsd,
                total: totalUsd,
                currency: 2,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _CurrencyShare extends StatelessWidget {
  const _CurrencyShare({
    required this.amount,
    required this.total,
    required this.currency,
  });
  final Decimal amount;
  final Decimal total;
  final int currency;
  @override
  Widget build(BuildContext context) {
    final share = total <= Decimal.zero
        ? 0.0
        : (amount / total).toDouble().clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          MoneyFormatter.format(amount, currencyTypeId: currency),
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: context.colors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: share,
                  minHeight: 6,
                  color: context.colors.primary,
                  backgroundColor: context.colors.primary.withValues(alpha: .1),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${(share * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: context.colors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProjectPicker extends StatefulWidget {
  const _ProjectPicker();
  @override
  State<_ProjectPicker> createState() => _ProjectPickerState();
}

class _ProjectPickerState extends State<_ProjectPicker> {
  final _controller = TextEditingController();
  final List<Project> _items = [];
  Timer? _debounce;
  int _request = 0;
  int _page = 0;
  bool _loading = true;
  bool _hasMore = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load({bool reset = false}) async {
    if (!reset && (_loading || !_hasMore)) return;
    final request = ++_request;
    final page = reset ? 1 : _page + 1;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) _items.clear();
    });
    final result = await getIt<ProjectsRepository>().getProjects(
      page: page,
      search: _controller.text.trim(),
    );
    if (!mounted || request != _request) return;
    setState(() {
      _loading = false;
      result.when(
        success: (data) {
          _items.addAll(data.items);
          _hasMore = data.hasNext;
          _page = page;
        },
        failure: (error) => _error = error.message,
      );
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Loyihani qidirish',
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onChanged: (_) {
            _request++;
            _debounce?.cancel();
            _debounce = Timer(
              const Duration(milliseconds: 300),
              () => _load(reset: true),
            );
          },
        ),
      ),
      Expanded(
        child: _items.isEmpty && _loading
            ? const AppSkeletonList()
            : _items.isEmpty && _error != null
            ? AppErrorState(
                description: _error,
                onRetry: () => _load(reset: true),
              )
            : ListView(
                children: [
                  if (_items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Loyihalar topilmadi',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  for (final project in _items)
                    ListTile(
                      leading: const Icon(Icons.work_outline_rounded),
                      title: Text(project.projectName),
                      subtitle: Text(project.projectOwner),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).pop(project),
                    ),
                  if (_items.isNotEmpty && _error != null)
                    TextButton(
                      onPressed: () => _load(),
                      child: const Text('Qayta urinish'),
                    ),
                  if (_hasMore && _error == null)
                    Center(
                      child: _loading
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            )
                          : TextButton(
                              onPressed: () => _load(),
                              child: const Text('Yana yuklash'),
                            ),
                    ),
                ],
              ),
      ),
    ],
  );
}
