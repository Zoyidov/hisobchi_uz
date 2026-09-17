import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/chips/app_status_chip.dart';
import '../../../../core/widgets/misc/app_segmented_control.dart';
import '../../../../core/widgets/states/app_empty_state.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../../../core/widgets/typography/money_text.dart';
import '../../data/installment_report_models.dart';
import '../../data/reports_repository.dart';

/// Bo'lib to'lash hisobotlari — 5 tabli (MOBILE_APP_TZ.md 12.3).
class InstallmentReportsPage extends StatefulWidget {
  const InstallmentReportsPage({super.key});

  @override
  State<InstallmentReportsPage> createState() => _InstallmentReportsPageState();
}

class _InstallmentReportsPageState extends State<InstallmentReportsPage> {
  var _currencyTypeId = 1;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bo\'lib to\'lash hisobotlari'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Umumiy'),
              Tab(text: 'Hamkorlar'),
              Tab(text: 'Muammoli'),
              Tab(text: 'Undirish'),
              Tab(text: 'Oylik'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppSegmentedControl<int>(
                value: _currencyTypeId,
                segments: const [AppSegment(value: 1, label: 'UZS'), AppSegment(value: 2, label: 'USD')],
                onChanged: (v) => setState(() => _currencyTypeId = v),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _SummaryTab(currencyTypeId: _currencyTypeId),
                  _PartnersTab(currencyTypeId: _currencyTypeId),
                  _RiskyTab(currencyTypeId: _currencyTypeId),
                  _RecoveryTab(currencyTypeId: _currencyTypeId),
                  _MonthlyTab(currencyTypeId: _currencyTypeId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryTab extends StatefulWidget {
  const _SummaryTab({required this.currencyTypeId});
  final int currencyTypeId;
  @override
  State<_SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends State<_SummaryTab> {
  InstallmentReportSummary? _summary;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _SummaryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currencyTypeId != widget.currencyTypeId) _load();
  }

  Future<void> _load() async {
    setState(() {
      _summary = null;
      _error = null;
    });
    final result = await getIt<ReportsRepository>().getInstallmentSummary(widget.currencyTypeId);
    if (!mounted) return;
    result.when(success: (r) => setState(() => _summary = r), failure: (f) => setState(() => _error = f.message));
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return AppErrorState(title: 'Yuklab bo\'lmadi', description: _error, onRetry: _load);
    final s = _summary;
    if (s == null) return const AppSkeletonList();
    final currencyLabel = widget.currencyTypeId == 2 ? 'USD' : 'UZS';
    final colors = context.colors;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Row(
            children: [
              Expanded(child: _statusCount(context, 'Faol', s.activeCount, colors.info)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _statusCount(context, 'Yopilgan', s.completedCount, colors.success)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _statusCount(context, 'Bekor', s.cancelledCount, colors.textTertiary)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              children: [
                _row(context, 'Berilgan', s.totalGiven, currencyLabel),
                const SizedBox(height: 8),
                _row(context, 'To\'langan', s.totalPaid, currencyLabel, color: colors.success),
                const SizedBox(height: 8),
                _row(context, 'Qolgan', s.totalRemaining, currencyLabel, color: colors.warning),
                const SizedBox(height: 8),
                _row(context, 'Muddati o\'tgan', s.overdueAmount, currencyLabel, color: colors.error),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCount(BuildContext context, String label, int count, Color color) {
    return AppCard(
      child: Column(
        children: [
          Text('$count', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color)),
          Text(label, style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, dynamic amount, String currencyLabel, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), MoneyText(amount, currencyLabel: currencyLabel, colorOverride: color)],
    );
  }
}

class _PartnersTab extends StatefulWidget {
  const _PartnersTab({required this.currencyTypeId});
  final int currencyTypeId;
  @override
  State<_PartnersTab> createState() => _PartnersTabState();
}

class _PartnersTabState extends State<_PartnersTab> {
  List<InstallmentPartnerRanking>? _items;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _PartnersTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currencyTypeId != widget.currencyTypeId) _load();
  }

  Future<void> _load() async {
    setState(() {
      _items = null;
      _error = null;
    });
    final result = await getIt<ReportsRepository>().getInstallmentPartners(widget.currencyTypeId);
    if (!mounted) return;
    result.when(success: (r) => setState(() => _items = r), failure: (f) => setState(() => _error = f.message));
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return AppErrorState(title: 'Yuklab bo\'lmadi', description: _error, onRetry: _load);
    final items = _items;
    if (items == null) return const AppSkeletonList();
    if (items.isEmpty) return const AppEmptyState(title: 'Ma\'lumot yo\'q', icon: Icons.people_outline_rounded);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          final item = items[i];
          return AppCard(
            onTap: () => context.push(RoutePaths.reportPartnerDetail(item.partnerId)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.partnerName, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Qolgan:', style: TextStyle(color: context.colors.textSecondary)),
                    MoneyText(item.remaining, currencyTypeId: widget.currencyTypeId),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RiskyTab extends StatefulWidget {
  const _RiskyTab({required this.currencyTypeId});
  final int currencyTypeId;
  @override
  State<_RiskyTab> createState() => _RiskyTabState();
}

class _RiskyTabState extends State<_RiskyTab> {
  List<RiskyPartner>? _items;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _RiskyTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currencyTypeId != widget.currencyTypeId) _load();
  }

  Future<void> _load() async {
    setState(() {
      _items = null;
      _error = null;
    });
    final result = await getIt<ReportsRepository>().getRiskyPartners(widget.currencyTypeId);
    if (!mounted) return;
    result.when(success: (r) => setState(() => _items = r), failure: (f) => setState(() => _error = f.message));
  }

  AppStatusChipTone _toneFor(String level) => switch (level.toLowerCase()) {
        'yuqori' || 'high' => AppStatusChipTone.error,
        'o\'rta' || 'medium' => AppStatusChipTone.warning,
        _ => AppStatusChipTone.neutral,
      };

  @override
  Widget build(BuildContext context) {
    if (_error != null) return AppErrorState(title: 'Yuklab bo\'lmadi', description: _error, onRetry: _load);
    final items = _items;
    if (items == null) return const AppSkeletonList();
    if (items.isEmpty) return const AppEmptyState(title: 'Muammoli hamkorlar yo\'q', icon: Icons.check_circle_outline_rounded);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          final item = items[i];
          return AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.partnerName, style: Theme.of(context).textTheme.titleSmall),
                      Text('O\'rtacha kechikish: ${item.averageDelayDays} kun', style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                AppStatusChip(label: 'Risk: ${item.riskLevel}', tone: _toneFor(item.riskLevel)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RecoveryTab extends StatefulWidget {
  const _RecoveryTab({required this.currencyTypeId});
  final int currencyTypeId;
  @override
  State<_RecoveryTab> createState() => _RecoveryTabState();
}

class _RecoveryTabState extends State<_RecoveryTab> {
  RecoveryReport? _report;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _RecoveryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currencyTypeId != widget.currencyTypeId) _load();
  }

  Future<void> _load() async {
    setState(() {
      _report = null;
      _error = null;
    });
    final result = await getIt<ReportsRepository>().getRecoveryReport(widget.currencyTypeId);
    if (!mounted) return;
    result.when(success: (r) => setState(() => _report = r), failure: (f) => setState(() => _error = f.message));
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return AppErrorState(title: 'Yuklab bo\'lmadi', description: _error, onRetry: _load);
    final r = _report;
    if (r == null) return const AppSkeletonList();
    final currencyLabel = widget.currencyTypeId == 2 ? 'USD' : 'UZS';

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            child: Column(
              children: [
                Text('${r.recoveryRate}%', style: Theme.of(context).textTheme.displaySmall),
                Text(r.ratingLabel, style: TextStyle(color: context.colors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text('Qaytarilgan'), MoneyText(r.recoveredAmount, currencyLabel: currencyLabel, colorOverride: context.colors.success)],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text('Muddati o\'tgan'), MoneyText(r.overdueAmount, currencyLabel: currencyLabel, colorOverride: context.colors.error)],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyTab extends StatefulWidget {
  const _MonthlyTab({required this.currencyTypeId});
  final int currencyTypeId;
  @override
  State<_MonthlyTab> createState() => _MonthlyTabState();
}

class _MonthlyTabState extends State<_MonthlyTab> {
  List<MonthlyInstallmentStat>? _items;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _MonthlyTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currencyTypeId != widget.currencyTypeId) _load();
  }

  Future<void> _load() async {
    setState(() {
      _items = null;
      _error = null;
    });
    final result = await getIt<ReportsRepository>().getMonthlyInstallments(year: DateTime.now().year, currencyTypeId: widget.currencyTypeId);
    if (!mounted) return;
    result.when(success: (r) => setState(() => _items = r), failure: (f) => setState(() => _error = f.message));
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return AppErrorState(title: 'Yuklab bo\'lmadi', description: _error, onRetry: _load);
    final items = _items;
    if (items == null) return const AppSkeletonList();
    if (items.isEmpty) return const AppEmptyState(title: 'Ma\'lumot yo\'q', icon: Icons.bar_chart_rounded);

    final maxY = items.map((e) => e.amount.toDouble()).fold(0.0, (a, b) => a > b ? a : b);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            child: SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: maxY == 0 ? 1 : maxY * 1.2,
                  barGroups: [
                    for (var i = 0; i < items.length; i++)
                      BarChartGroupData(x: i, barRods: [
                        BarChartRodData(toY: items[i].amount.toDouble(), color: context.colors.primary, width: 12),
                      ]),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= items.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(items[index].month, style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
