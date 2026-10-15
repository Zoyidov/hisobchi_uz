import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/misc/app_segmented_control.dart';
import '../../../../core/widgets/states/app_empty_state.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../../../core/utils/formatters/money_formatter.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
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
        backgroundColor: context.colors.background,
        appBar: AppBar(
          title: const Text('Hamkorlar hisoboti'),
          backgroundColor: context.colors.surface,
          surfaceTintColor: Colors.transparent,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  dividerHeight: 0,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(4),
                  indicator: BoxDecoration(
                    color: context.colors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: context.colors.textSecondary,
                  labelStyle: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                  tabs: const [
                    Tab(text: 'Umumiy'),
                    Tab(text: 'Davr'),
                    Tab(text: 'Muddatlar'),
                    Tab(text: 'Xodimlar'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: AppSegmentedControl<int>(
                value: _currencyTypeId,
                segments: const [
                  AppSegment(value: 1, label: 'UZS'),
                  AppSegment(value: 2, label: 'USD'),
                ],
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
  int _request = 0;

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
    final request = ++_request;
    setState(() {
      _report = null;
      _error = null;
    });
    final result = await getIt<ReportsRepository>().getPartnersSummary(
      widget.currencyTypeId,
    );
    if (!mounted || request != _request) return;
    result.when(
      success: (r) => setState(() => _report = r),
      failure: (f) => setState(() => _error = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return AppErrorState(
        title: 'Yuklab bo\'lmadi',
        description: _error,
        onRetry: _load,
      );
    }
    final report = _report;
    if (report == null) return const _SummarySkeleton();

    final currencyLabel = widget.currencyTypeId == 2 ? 'USD' : 'UZS';
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _ReportBalance(report: report, currency: currencyLabel),
          const SizedBox(height: 20),
          Text(
            'Hamkorlar holati',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 16) / 3;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: width,
                    child: _ReportMetric(
                      label: 'Operatsiyalar',
                      count: report.operationsCount,
                      icon: Icons.swap_horiz_rounded,
                      color: context.colors.primary,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _ReportMetric(
                      label: 'Haqdorlar',
                      count: report.creditorsCount,
                      icon: Icons.arrow_downward_rounded,
                      color: context.colors.success,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ReportDetailListPage(
                            title: 'Haqdorlar',
                            fetcher: (page) => getIt<ReportsRepository>()
                                .getPartnersSummaryDetails(
                                  type: 'xaqdor',
                                  currencyTypeId: widget.currencyTypeId,
                                  page: page,
                                ),
                            currencyTypeId: widget.currencyTypeId,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _ReportMetric(
                      label: 'Qarzdorlar',
                      count: report.debtorsCount,
                      icon: Icons.arrow_upward_rounded,
                      color: context.colors.error,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ReportDetailListPage(
                            title: 'Qarzdorlar',
                            fetcher: (page) => getIt<ReportsRepository>()
                                .getPartnersSummaryDetails(
                                  type: 'qarzdor',
                                  currencyTypeId: widget.currencyTypeId,
                                  page: page,
                                ),
                            currencyTypeId: widget.currencyTypeId,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
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
    final result = await getIt<ReportsRepository>().getPartnersPeriods(
      from: _from,
      to: _to,
    );
    if (!mounted) return;
    result.when(
      success: (r) => setState(() => _periods = r),
      failure: (f) => setState(() => _error = f.message),
    );
  }

  Future<void> _pickRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _from, end: _to),
    );
    if (range != null && mounted) {
      setState(() {
        _from = range.start;
        _to = range.end;
      });
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return AppErrorState(
        title: 'Yuklab bo\'lmadi',
        description: _error,
        onRetry: _load,
      );
    }
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
            label: Text(
              '${AppDateFormatter.display(_from)} — ${AppDateFormatter.display(_to)}',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ReportFlow(
            amount: summary.debt,
            label: 'Kirim',
            currency: currencyKey,
            color: context.colors.success,
            icon: Icons.south_west_rounded,
          ),
          const SizedBox(height: 10),
          _ReportFlow(
            amount: summary.credit,
            label: 'Chiqim',
            currency: currencyKey,
            color: context.colors.error,
            icon: Icons.north_east_rounded,
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
    result.when(
      success: (r) => setState(() => _data = r),
      failure: (f) => setState(() => _error = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return AppErrorState(
        title: 'Yuklab bo\'lmadi',
        description: _error,
        onRetry: _load,
      );
    }
    final data = _data;
    if (data == null) return const AppSkeletonList();

    final key = widget.currencyTypeId == 2 ? 'USD' : 'UZS';
    final summary = data[key] ?? WarrantyPeriodsSummary.zero;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _warrantyCard(
            context,
            'Muddati o\'tgan',
            summary.expired,
            context.colors.error,
            'qarz_expired',
          ),
          const SizedBox(height: AppSpacing.sm),
          _warrantyCard(
            context,
            'Bugun',
            summary.today,
            context.colors.warning,
            'qarz_today',
          ),
          const SizedBox(height: AppSpacing.sm),
          _warrantyCard(
            context,
            '3 kun ichida',
            summary.in3Days,
            context.colors.success,
            'qarz_3_days',
          ),
        ],
      ),
    );
  }

  Widget _warrantyCard(
    BuildContext context,
    String label,
    int count,
    Color color,
    String type,
  ) {
    return _ReportMetric(
      label: label,
      count: count,
      color: color,
      compactRow: true,
      icon: Icons.event_outlined,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ReportDetailListPage(
            title: label,
            fetcher: (page) =>
                getIt<ReportsRepository>().getWarrantyPeriodsDetails(
                  type: type,
                  currencyTypeId: widget.currencyTypeId,
                  page: page,
                ),
            currencyTypeId: widget.currencyTypeId,
          ),
        ),
      ),
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
    result.when(
      success: (r) => setState(() => _items = r),
      failure: (f) => setState(() => _error = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return AppErrorState(
        title: 'Yuklab bo\'lmadi',
        description: _error,
        onRetry: _load,
      );
    }
    final items = _items;
    if (items == null) return const AppSkeletonList();
    if (items.isEmpty) {
      return const AppEmptyState(
        title: 'Xodimlar bo\'yicha ma\'lumot yo\'q',
        icon: Icons.groups_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          final worker = items[i];
          return AppCard(
            hasShadow: false,
            padding: const EdgeInsets.all(14),
            borderRadius: BorderRadius.circular(18),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: context.colors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: context.colors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    worker.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${worker.operationsCount}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Operatsiya',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
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

class _ReportBalance extends StatelessWidget {
  const _ReportBalance({required this.report, required this.currency});
  final PartnerSummaryReport report;
  final String currency;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: context.colors.primaryContainer,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: context.colors.primary.withValues(alpha: .16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 20,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Umumiy balans',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  currency,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              MoneyFormatter.format(report.balance, currencyLabel: currency),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: -.6,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      LayoutBuilder(
        builder: (context, constraints) {
          final flows = [
            _ReportFlow(
              amount: report.debt,
              label: 'Kirim',
              currency: currency,
              color: context.colors.success,
              icon: Icons.south_west_rounded,
            ),
            _ReportFlow(
              amount: report.credit,
              label: 'Chiqim',
              currency: currency,
              color: context.colors.error,
              icon: Icons.north_east_rounded,
            ),
          ];
          if (MediaQuery.textScalerOf(context).scale(14) > 20 ||
              constraints.maxWidth < 300) {
            return Column(
              children: [flows[0], const SizedBox(height: 10), flows[1]],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: flows[0]),
              const SizedBox(width: 10),
              Expanded(child: flows[1]),
            ],
          );
        },
      ),
    ],
  );
}

class _ReportFlow extends StatelessWidget {
  const _ReportFlow({
    required this.amount,
    required this.label,
    required this.currency,
    required this.color,
    required this.icon,
  });
  final Decimal amount;
  final String label;
  final String currency;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => AppCard(
    hasShadow: false,
    padding: const EdgeInsets.all(14),
    borderRadius: BorderRadius.circular(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          MoneyFormatter.format(amount, currencyLabel: currency),
          textAlign: TextAlign.right,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _ReportMetric extends StatelessWidget {
  const _ReportMetric({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    this.onTap,
    this.compactRow = false,
  });
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;
  final bool compactRow;

  @override
  Widget build(BuildContext context) {
    final accent = count == 0 ? context.colors.textTertiary : color;
    final symbol = Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 17, color: accent),
    );
    return AppCard(
      hasShadow: false,
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(18),
      onTap: count == 0 ? null : onTap,
      child: compactRow
          ? Row(
              children: [
                symbol,
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.colors.textTertiary,
                  size: 18,
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                symbol,
                const SizedBox(height: 10),
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: count == 0
                        ? context.colors.textTertiary
                        : context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
    );
  }
}

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      AppSkeletonBox(height: 110, borderRadius: BorderRadius.circular(22)),
      const SizedBox(height: 10),
      Row(
        children: [
          for (var i = 0; i < 2; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == 0 ? 10 : 0),
                child: AppSkeletonBox(
                  height: 90,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 20),
      const Align(
        alignment: Alignment.centerLeft,
        child: AppSkeletonBox(width: 140, height: 16),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          for (var i = 0; i < 3; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                child: AppSkeletonBox(
                  height: 110,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
        ],
      ),
    ],
  );
}
