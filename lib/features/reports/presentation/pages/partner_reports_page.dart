import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/states/app_empty_state.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../../../core/utils/formatters/money_formatter.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../data/partner_report_models.dart';
import '../../data/reports_repository.dart';
import 'report_detail_list_page.dart';
import 'installment_reports_page.dart';
import 'partner_report_operations_page.dart';
import '../../../partners/data/partners_repository.dart';
import '../../../partners/presentation/widgets/export_excel_helper.dart';
import '../../../../core/constants/app_permission.dart';
import '../../../../core/widgets/navigation/permission_guard.dart';

/// Global partner dashboard, matching ReportClientMainPage.
class PartnerReportsPage extends StatefulWidget {
  const PartnerReportsPage({super.key});
  @override
  State<PartnerReportsPage> createState() => _PartnerReportsPageState();
}

class _PartnerReportsPageState extends State<PartnerReportsPage> {
  int _currency = 1;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.background,
    appBar: AppBar(
      centerTitle: true,
      backgroundColor: context.colors.surface,
      title: Text(
        'Hamkorlar hisoboti',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      actions: [
        PopupMenuButton<String>(
          tooltip: 'Hisobot amallari',
          onSelected: (_) => downloadAndShareExcel(
            context,
            download: () => getIt<PartnersRepository>().exportPartnersExcel(),
            fileName: 'hamkorlar_hisoboti.xlsx',
          ),
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'excel',
              child: Row(
                children: [
                  Icon(Icons.file_download_outlined, size: 20),
                  SizedBox(width: 8),
                  Text('Excel hisobot'),
                ],
              ),
            ),
          ],
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(66),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: _CurrencySwitch(
            value: _currency,
            onChanged: (value) => setState(() => _currency = value),
          ),
        ),
      ),
    ),
    body: SafeArea(top: false, child: _SummaryTab(currencyTypeId: _currency)),
  );
}

class _CurrencySwitch extends StatelessWidget {
  const _CurrencySwitch({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.colors.surfaceSecondary,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        for (final id in [1, 2]) ...[
          if (id == 2)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var index = 0; index < 2; index++)
                  Container(
                    width: 2,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: context.colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          Expanded(
            child: Semantics(
              selected: value == id,
              button: true,
              child: InkWell(
                onTap: () => onChanged(id),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 4,
                  ),
                  child: Text(
                    id == 1 ? 'UZS Hisob' : 'USD Hisob',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: value == id
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: value == id
                          ? context.colors.textPrimary
                          : context.colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

class _PartnerReportSectionPage extends StatefulWidget {
  const _PartnerReportSectionPage({
    required this.title,
    required this.initialCurrency,
    required this.builder,
  });
  final String title;
  final int initialCurrency;
  final Widget Function(int currency) builder;
  @override
  State<_PartnerReportSectionPage> createState() =>
      _PartnerReportSectionPageState();
}

class _PartnerReportSectionPageState extends State<_PartnerReportSectionPage> {
  late int _currency = widget.initialCurrency;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(66),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: _CurrencySwitch(
            value: _currency,
            onChanged: (value) => setState(() => _currency = value),
          ),
        ),
      ),
    ),
    body: SafeArea(top: false, child: widget.builder(_currency)),
  );
}

class _SummaryTab extends StatefulWidget {
  const _SummaryTab({required this.currencyTypeId});
  final int currencyTypeId;

  @override
  State<_SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends State<_SummaryTab> {
  Map<String, PartnerSummaryReport>? _reports;
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
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _reports = null;
      _error = null;
    });
    final result = await getIt<ReportsRepository>().getPartnersSummaryReports();
    if (!mounted || request != _request) return;
    result.when(
      success: (r) => setState(() => _reports = r),
      failure: (f) => setState(() => _error = f.message),
    );
  }

  void _openSection(String title, Widget Function(int) builder) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _PartnerReportSectionPage(
            title: title,
            initialCurrency: widget.currencyTypeId,
            builder: builder,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return AppErrorState(
        title: 'Yuklab bo\'lmadi',
        description: _error,
        onRetry: _load,
      );
    }
    final report = _reports?[widget.currencyTypeId == 2 ? 'USD' : 'UZS'];
    if (report == null) return const _SummarySkeleton();

    final currencyLabel = widget.currencyTypeId == 2 ? 'USD' : 'UZS';
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _ReportBalance(report: report, currency: currencyLabel),
          const SizedBox(height: 16),
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
                      color: context.colors.warning,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PartnerReportOperationsPage(
                            title: 'Operatsiyalar',
                            currencyTypeId: widget.currencyTypeId,
                            fetcher: (page) => getIt<ReportsRepository>()
                                .getPartnersMainOperations(
                                  currencyTypeId: widget.currencyTypeId,
                                  page: page,
                                ),
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
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Hisobot turlari',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _MainReportEntry(
            title: 'Qarz muddatlari hisoboti',
            subtitle: 'Muddati o‘tgan, bugun va kelgusi qarzlar',
            icon: Icons.access_time_rounded,
            color: context.colors.warning,
            onTap: () => _openSection(
              'Qarz muddatlari hisoboti',
              (currency) => _WarrantyTab(currencyTypeId: currency),
            ),
          ),
          _MainReportEntry(
            title: 'Xodimlar hisoboti',
            subtitle: 'Xodimlar bo‘yicha barcha hisobotlar',
            icon: Icons.people_alt_outlined,
            color: context.colors.primary,
            onTap: () => _openSection(
              'Xodimlar hisoboti',
              (currency) => _WorkersTab(currencyTypeId: currency),
            ),
          ),
          _MainReportEntry(
            title: 'Muddat hisoboti',
            subtitle: 'Davr bo‘yicha kirim va chiqim',
            icon: Icons.date_range_rounded,
            color: context.colors.info,
            onTap: () => _openSection(
              'Muddat hisoboti',
              (currency) => _PeriodTab(currencyTypeId: currency),
            ),
          ),
          PermissionGuard(
            permission: AppPermission.reportInstallmentsView,
            child: _MainReportEntry(
              title: 'Muddatli to‘lov hisoboti',
              subtitle:
                  'Rejalar, undirish, oylik dinamika va muammoli mijozlar',
              icon: Icons.receipt_long_rounded,
              color: context.colors.accentViolet,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const InstallmentReportsPage(),
                ),
              ),
            ),
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

  void _openOperations(String type, String title) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PartnerReportOperationsPage(
        title: title,
        currencyTypeId: widget.currencyTypeId,
        fetcher: (page) =>
            getIt<ReportsRepository>().getPartnersPeriodOperations(
              type: type,
              currencyTypeId: widget.currencyTypeId,
              from: _from,
              to: _to,
              page: page,
            ),
      ),
    ),
  );

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
            onTap: () => _openOperations('debt', 'Kirim'),
            amount: summary.debt,
            label: 'Kirim',
            currency: currencyKey,
            color: context.colors.success,
            icon: Icons.south_west_rounded,
          ),
          const SizedBox(height: 10),
          _ReportFlow(
            onTap: () => _openOperations('credit', 'Chiqim'),
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
          builder: (_) => PartnerReportOperationsPage(
            title: label,
            currencyTypeId: widget.currencyTypeId,
            fetcher: (page) =>
                getIt<ReportsRepository>().getPartnersWarrantyOperations(
                  type: type,
                  currencyTypeId: widget.currencyTypeId,
                  page: page,
                ),
          ),
        ),
      ),
    );
  }
}

class _WorkersTab extends StatefulWidget {
  const _WorkersTab({required this.currencyTypeId});
  final int currencyTypeId;

  @override
  State<_WorkersTab> createState() => _WorkersTabState();
}

class _WorkersTabState extends State<_WorkersTab> {
  List<WorkerReportItem>? _items;
  Map<String, PeriodSummary>? _totals;
  String? _error;
  int _request = 0;
  int _period = 0;
  DateTimeRange? _range;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _WorkersTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currencyTypeId != widget.currencyTypeId) _load();
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _items = null;
      _error = null;
    });
    final summaryFuture = getIt<ReportsRepository>().getWorkersSummary(
      from: _range?.start,
      to: _range?.end,
    );
    final result = await getIt<ReportsRepository>().getWorkersReport(
      currencyTypeId: widget.currencyTypeId,
      from: _range?.start,
      to: _range?.end,
    );
    final summary = await summaryFuture;
    if (!mounted || request != _request) return;
    summary.when(
      success: (data) => _totals = data,
      failure: (_) => _totals = null,
    );
    result.when(
      success: (r) => setState(() => _items = r),
      failure: (f) => setState(() => _error = f.message),
    );
  }

  Future<void> _selectPeriod(int value) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTimeRange? range;
    if (value == 4) {
      range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: today,
        initialDateRange: _range,
        helpText: 'Hisobot davrini tanlang',
        saveText: 'Tanlash',
      );
      if (!mounted || range == null) return;
    } else if (value > 0) {
      final start = switch (value) {
        1 => today,
        2 => today.subtract(Duration(days: today.weekday - 1)),
        _ => DateTime(now.year, now.month),
      };
      range = DateTimeRange(start: start, end: today);
    }
    setState(() {
      _period = value;
      _range = range;
    });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final currency = MoneyFormatter.currencyCode(widget.currencyTypeId);
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              for (final (index, label) in [
                'Barchasi',
                'Bugun',
                'Bu hafta',
                'Bu oy',
                'Sana tanlash',
              ].indexed)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: _period == index,
                    onSelected: (_) => _selectPeriod(index),
                  ),
                ),
            ],
          ),
        ),
        if (_totals?[currency] case final total?)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                _ReportFlow(
                  amount: total.debt,
                  label: 'Jami kirim',
                  currency: currency,
                  color: context.colors.success,
                  icon: Icons.south_west_rounded,
                ),
                const SizedBox(height: 8),
                _ReportFlow(
                  amount: total.credit,
                  label: 'Jami chiqim',
                  currency: currency,
                  color: context.colors.error,
                  icon: Icons.north_east_rounded,
                ),
              ],
            ),
          ),
        if (_range != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              '${AppDateFormatter.toApiFilterDate(_range!.start)} — ${AppDateFormatter.toApiFilterDate(_range!.end)}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        Expanded(
          child: _error != null
              ? AppErrorState(
                  title: "Xodimlar hisobotini yuklab bo‘lmadi",
                  description: _error,
                  onRetry: _load,
                )
              : items == null
              ? const AppSkeletonList()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (items.isEmpty)
                        const AppEmptyState(
                          title: "Bu davrda operatsiyalar yo‘q",
                          icon: Icons.groups_outlined,
                        )
                      else ...[
                        Text(
                          'Xodimlar · ${items.length}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 12),
                        for (final worker in items)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AppCard(
                              hasShadow: false,
                              padding: const EdgeInsets.all(16),
                              borderRadius: BorderRadius.circular(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            context.colors.primaryContainer,
                                        child: Icon(
                                          Icons.person_outline_rounded,
                                          color: context.colors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              worker.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            if (worker.role?.isNotEmpty ??
                                                false)
                                              Text(
                                                worker.role!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium
                                                    ?.copyWith(
                                                      color: context
                                                          .colors
                                                          .textSecondary,
                                                    ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${worker.operationsCount} ta',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  for (final (label, amount, color) in [
                                    (
                                      'Kirim',
                                      worker.debt,
                                      context.colors.success,
                                    ),
                                    (
                                      'Chiqim',
                                      worker.credit,
                                      context.colors.error,
                                    ),
                                  ])
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Row(
                                        children: [
                                          Text(
                                            label,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: context
                                                      .colors
                                                      .textSecondary,
                                                ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              MoneyFormatter.format(
                                                amount,
                                                currencyLabel: currency,
                                              ),
                                              textAlign: TextAlign.right,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall
                                                  ?.copyWith(
                                                    color: color,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _ReportBalance extends StatelessWidget {
  const _ReportBalance({required this.report, required this.currency});
  final PartnerSummaryReport report;
  final String currency;
  @override
  Widget build(BuildContext context) {
    final corrected = -report.balance;
    final subtitle = corrected < Decimal.zero
        ? 'Sizning qarzingiz'
        : corrected > Decimal.zero
        ? 'Mijozlar qarzi'
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final income = _ReportFlow(
              amount: report.debt,
              label: 'Kirim',
              currency: currency,
              color: context.colors.success,
              icon: Icons.south_west_rounded,
            );
            final expense = _ReportFlow(
              amount: report.credit,
              label: 'Chiqim',
              currency: currency,
              color: context.colors.error,
              icon: Icons.north_east_rounded,
            );
            if (constraints.maxWidth < 300 ||
                MediaQuery.textScalerOf(context).scale(14) > 19) {
              return Column(
                children: [income, const SizedBox(height: 12), expense],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: income),
                const SizedBox(width: 12),
                Expanded(child: expense),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: context.colors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 22,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Qoldiq',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.people_alt_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${report.partnersCount} ta',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: .85),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Text(
                MoneyFormatter.format(corrected, currencyLabel: currency),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportFlow extends StatelessWidget {
  const _ReportFlow({
    required this.amount,
    required this.label,
    required this.currency,
    required this.color,
    required this.icon,
    this.onTap,
  });
  final Decimal amount;
  final String label;
  final String currency;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: color,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              MoneyFormatter.groupDigits(amount),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currency,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: .8),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MainReportEntry extends StatelessWidget {
  const _MainReportEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: AppCard(
      hasShadow: false,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 26, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            color: context.colors.textTertiary,
            size: 20,
          ),
        ],
      ),
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
      onTap: onTap,
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
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    symbol,
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                    ),
                  ],
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
