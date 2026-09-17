import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/cards/app_kpi_card.dart';
import '../../../../core/widgets/misc/app_segmented_control.dart';
import '../../../../core/widgets/states/app_empty_state.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../../../core/widgets/typography/money_text.dart';
import '../../data/partner_report_models.dart';
import '../../data/reports_repository.dart';
import 'report_detail_list_page.dart';

/// Hamkorlar hisoboti — 4 tabli, valyuta segmenti umumiy
/// (MOBILE_APP_TZ.md 12.1, 12.5).
class PartnerReportsPage extends StatefulWidget {
  const PartnerReportsPage({super.key});

  @override
  State<PartnerReportsPage> createState() => _PartnerReportsPageState();
}

class _PartnerReportsPageState extends State<PartnerReportsPage> {
  var _currencyTypeId = 1;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hamkorlar hisoboti'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Umumiy'),
              Tab(text: 'Davr bo\'yicha'),
              Tab(text: 'Qarz muddatlari'),
              Tab(text: 'Xodimlar'),
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
                  _PeriodTab(currencyTypeId: _currencyTypeId),
                  _WarrantyTab(currencyTypeId: _currencyTypeId),
                  _WorkersTab(),
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
  PartnerSummaryReport? _report;
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
      _report = null;
      _error = null;
    });
    final result = await getIt<ReportsRepository>().getPartnersSummary(widget.currencyTypeId);
    if (!mounted) return;
    result.when(success: (r) => setState(() => _report = r), failure: (f) => setState(() => _error = f.message));
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return AppErrorState(title: 'Yuklab bo\'lmadi', description: _error, onRetry: _load);
    final report = _report;
    if (report == null) return const AppSkeletonList();

    final currencyLabel = widget.currencyTypeId == 2 ? 'USD' : 'UZS';
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Row(
            children: [
              Expanded(child: _kpi(context, 'Kirim', report.debt, currencyLabel, context.colors.success)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _kpi(context, 'Chiqim', report.credit, currencyLabel, context.colors.error)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _kpi(context, 'Balans', report.balance, currencyLabel, context.colors.primary),
          const SizedBox(height: AppSpacing.lg),
          AppKpiCard(
            label: 'Operatsiyalar',
            value: '${report.operationsCount}',
            icon: Icons.swap_horiz_rounded,
            isZero: report.operationsCount == 0,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppKpiCard(
            label: 'Xaqdorlar',
            value: '${report.creditorsCount}',
            icon: Icons.arrow_downward_rounded,
            color: context.colors.success,
            isZero: report.creditorsCount == 0,
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => ReportDetailListPage(
                title: 'Xaqdorlar',
                fetcher: (page) => getIt<ReportsRepository>().getPartnersSummaryDetails(
                  type: 'xaqdor',
                  currencyTypeId: widget.currencyTypeId,
                  page: page,
                ),
                currencyTypeId: widget.currencyTypeId,
              ),
            )),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppKpiCard(
            label: 'Qarzdorlar',
            value: '${report.debtorsCount}',
            icon: Icons.arrow_upward_rounded,
            color: context.colors.error,
            isZero: report.debtorsCount == 0,
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => ReportDetailListPage(
                title: 'Qarzdorlar',
                fetcher: (page) => getIt<ReportsRepository>().getPartnersSummaryDetails(
                  type: 'qarzdor',
                  currencyTypeId: widget.currencyTypeId,
                  page: page,
                ),
                currencyTypeId: widget.currencyTypeId,
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _kpi(BuildContext context, String label, dynamic amount, String currencyLabel, Color color) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: context.colors.textSecondary)),
          const SizedBox(height: 4),
          MoneyText(amount, currencyLabel: currencyLabel, colorOverride: color, size: MoneySize.card),
        ],
      ),
    );
  }
}

class _PeriodTab extends StatefulWidget {
  const _PeriodTab({required this.currencyTypeId});
  final int currencyTypeId;

  @override
  State<_PeriodTab> createState() => _PeriodTabState();
}

class _PeriodTabState extends State<_PeriodTab> {
  Map<String, PeriodSummary>? _periods;
  String? _error;
  DateTime _from = DateTime.now().subtract(const Duration(days: 30));
  DateTime _to = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _PeriodTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currencyTypeId != widget.currencyTypeId) _load();
  }

  Future<void> _load() async {
    setState(() {
      _periods = null;
      _error = null;
    });
    final result = await getIt<ReportsRepository>().getPartnersPeriods(from: _from, to: _to);
    if (!mounted) return;
    result.when(success: (r) => setState(() => _periods = r), failure: (f) => setState(() => _error = f.message));
  }

  Future<void> _pickRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _from, end: _to),
    );
    if (range != null) {
      setState(() {
        _from = range.start;
        _to = range.end;
      });
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return AppErrorState(title: 'Yuklab bo\'lmadi', description: _error, onRetry: _load);
    final periods = _periods;
    if (periods == null) return const AppSkeletonList();

    final currencyKey = widget.currencyTypeId == 2 ? 'USD' : 'UZS';
    final summary = periods[currencyKey] ?? PeriodSummary.zero;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          OutlinedButton.icon(
            onPressed: _pickRange,
            icon: const Icon(Icons.date_range_rounded),
            label: Text('${_from.day}.${_from.month}.${_from.year} — ${_to.day}.${_to.month}.${_to.year}'),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kirim'),
                    MoneyText(summary.debt, currencyLabel: currencyKey, colorOverride: context.colors.success),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Chiqim'),
                    MoneyText(summary.credit, currencyLabel: currencyKey, colorOverride: context.colors.error),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WarrantyTab extends StatefulWidget {
  const _WarrantyTab({required this.currencyTypeId});
  final int currencyTypeId;

  @override
  State<_WarrantyTab> createState() => _WarrantyTabState();
}

class _WarrantyTabState extends State<_WarrantyTab> {
  Map<String, WarrantyPeriodsSummary>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _data = null;
      _error = null;
    });
    final result = await getIt<ReportsRepository>().getWarrantyPeriods();
    if (!mounted) return;
    result.when(success: (r) => setState(() => _data = r), failure: (f) => setState(() => _error = f.message));
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return AppErrorState(title: 'Yuklab bo\'lmadi', description: _error, onRetry: _load);
    final data = _data;
    if (data == null) return const AppSkeletonList();

    final key = widget.currencyTypeId == 2 ? 'USD' : 'UZS';
    final summary = data[key] ?? WarrantyPeriodsSummary.zero;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _warrantyCard(context, 'Muddati o\'tgan', summary.expired, context.colors.error, 'qarz_expired'),
          const SizedBox(height: AppSpacing.sm),
          _warrantyCard(context, 'Bugun', summary.today, context.colors.warning, 'qarz_today'),
          const SizedBox(height: AppSpacing.sm),
          _warrantyCard(context, '3 kun ichida', summary.in3Days, context.colors.success, 'qarz_3_days'),
        ],
      ),
    );
  }

  Widget _warrantyCard(BuildContext context, String label, int count, Color color, String type) {
    return AppKpiCard(
      label: label,
      value: '$count',
      color: color,
      isZero: count == 0,
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => ReportDetailListPage(
          title: label,
          fetcher: (page) => getIt<ReportsRepository>().getWarrantyPeriodsDetails(
            type: type,
            currencyTypeId: widget.currencyTypeId,
            page: page,
          ),
          currencyTypeId: widget.currencyTypeId,
        ),
      )),
    );
  }
}

class _WorkersTab extends StatefulWidget {
  @override
  State<_WorkersTab> createState() => _WorkersTabState();
}

class _WorkersTabState extends State<_WorkersTab> {
  List<WorkerReportItem>? _items;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _items = null;
      _error = null;
    });
    final result = await getIt<ReportsRepository>().getWorkersReport(
      from: DateTime.now().subtract(const Duration(days: 30)),
      to: DateTime.now(),
    );
    if (!mounted) return;
    result.when(success: (r) => setState(() => _items = r), failure: (f) => setState(() => _error = f.message));
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return AppErrorState(title: 'Yuklab bo\'lmadi', description: _error, onRetry: _load);
    final items = _items;
    if (items == null) return const AppSkeletonList();
    if (items.isEmpty) return const AppEmptyState(title: 'Xodimlar bo\'yicha ma\'lumot yo\'q', icon: Icons.groups_outlined);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          final worker = items[i];
          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(worker.name, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text('Operatsiyalar: ${worker.operationsCount}', style: TextStyle(color: context.colors.textSecondary, fontSize: 13)),
              ],
            ),
          );
        },
      ),
    );
  }
}
