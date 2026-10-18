import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/paged_result.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../core/utils/formatters/money_formatter.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/misc/app_segmented_control.dart';
import '../../../../core/widgets/states/app_empty_state.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../data/installment_report_models.dart';
import '../../data/reports_repository.dart';

ReportsRepository get _repository => getIt<ReportsRepository>();
String _money(Decimal amount, int currency) =>
    MoneyFormatter.format(amount, currencyTypeId: currency);
void _open(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

/// Currency overview with the same report hierarchy as the legacy application.
class InstallmentReportsPage extends StatelessWidget {
  const InstallmentReportsPage({super.key});
  @override
  Widget build(BuildContext context) => _CurrencyReportPage(
    title: 'Muddatli to‘lov hisoboti',
    builder: (currency) => _ReportLoader<InstallmentReportSummary>(
      key: ValueKey(currency),
      load: () => _repository.getInstallmentSummary(currency),
      builder: (context, summary, reload) => _ReportList(
        onRefresh: reload,
        children: [
          if (summary.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Bo‘lib to‘lash ma’lumoti yo‘q',
                textAlign: TextAlign.center,
              ),
            ),
          _SummaryCard(summary: summary, currency: currency),
          const SizedBox(height: 22),
          Text(
            'Hisobot bo‘limlari',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          _ReportEntry(
            icon: Icons.trending_up_rounded,
            color: context.colors.success,
            title: 'Undirish samaradorligi',
            subtitle: 'To‘lov samaradorligi va undirilgan summalar',
            onTap: () =>
                _open(context, _RecoveryPage(initialCurrency: currency)),
          ),
          _ReportEntry(
            icon: Icons.calendar_month_rounded,
            color: context.colors.accentViolet,
            title: 'Kutilayotgan to‘lovlar',
            subtitle: '30/60/90 kunlik prognoz',
            onTap: () =>
                _open(context, _ForecastPage(initialCurrency: currency)),
          ),
          _ReportEntry(
            icon: Icons.bar_chart_rounded,
            color: context.colors.primary,
            title: 'Oylik dinamika',
            subtitle: 'Oylar bo‘yicha to‘lov grafigi',
            onTap: () =>
                _open(context, _MonthlyPage(initialCurrency: currency)),
          ),
          _ReportEntry(
            icon: Icons.warning_amber_rounded,
            color: context.colors.error,
            title: 'Muammoli mijozlar',
            subtitle: 'Kechiktirilgan va xavfli mijozlar ro‘yxati',
            onTap: () => _open(context, _RiskyPage(initialCurrency: currency)),
          ),
          _ReportEntry(
            icon: Icons.people_alt_outlined,
            color: context.colors.warning,
            title: 'Mijozlar bo‘yicha',
            subtitle: 'Mijoz bo‘yicha muddatli to‘lov hisoboti',
            onTap: () =>
                _open(context, _PartnersPage(initialCurrency: currency)),
          ),
        ],
      ),
    ),
  );
}

class _CurrencyReportPage extends StatefulWidget {
  const _CurrencyReportPage({
    required this.title,
    required this.builder,
    this.initialCurrency = 1,
  });
  final String title;
  final Widget Function(int currency) builder;
  final int initialCurrency;
  @override
  State<_CurrencyReportPage> createState() => _CurrencyReportPageState();
}

class _CurrencyReportPageState extends State<_CurrencyReportPage> {
  late int _currency = widget.initialCurrency;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.background,
    appBar: AppBar(
      centerTitle: true,
      backgroundColor: context.colors.surface,
      title: Text(
        widget.title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: AppSegmentedControl<int>(
            value: _currency,
            segments: const [
              AppSegment(value: 1, label: 'UZS'),
              AppSegment(value: 2, label: 'USD'),
            ],
            onChanged: (value) => setState(() => _currency = value),
          ),
        ),
      ),
    ),
    body: SafeArea(top: false, child: widget.builder(_currency)),
  );
}

/// A keyed loader owns its request, so changing a filter cannot show stale data.
class _ReportLoader<T> extends StatefulWidget {
  const _ReportLoader({super.key, required this.load, required this.builder});
  final Future<ApiResult<T>> Function() load;
  final Widget Function(BuildContext, T, Future<void> Function()) builder;
  @override
  State<_ReportLoader<T>> createState() => _ReportLoaderState<T>();
}

class _ReportLoaderState<T> extends State<_ReportLoader<T>> {
  T? _data;
  String? _error;
  int _request = 0;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() => _error = null);
    final result = await widget.load();
    if (!mounted || request != _request) return;
    result.when(
      success: (data) => setState(() => _data = data),
      failure: (error) => setState(() => _error = error.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return AppErrorState(description: _error, onRetry: _load);
    }
    final data = _data;
    if (data == null) return const AppSkeletonList();
    return widget.builder(context, data, _load);
  }
}

class _ReportList extends StatelessWidget {
  const _ReportList({required this.children, required this.onRefresh});
  final List<Widget> children;
  final Future<void> Function() onRefresh;
  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: onRefresh,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: children,
    ),
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary, required this.currency});
  final InstallmentReportSummary summary;
  final int currency;
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      hasShadow: false,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Metric(
                  label: 'Faol rejalar',
                  value: '${summary.activeCount} ta',
                  icon: Icons.play_circle_outline_rounded,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Metric(
                  label: 'Tugallangan',
                  value: '${summary.completedCount} ta',
                  icon: Icons.check_circle_outline_rounded,
                  color: colors.success,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Metric(
                  label: 'Bekor qilingan',
                  value: '${summary.cancelledCount} ta',
                  icon: Icons.cancel_outlined,
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final given = _AmountTile(
                label: 'Berilgan',
                amount: summary.totalGiven,
                currency: currency,
                color: colors.accentViolet,
                icon: Icons.account_balance_wallet_outlined,
              );
              final paid = _AmountTile(
                label: 'To‘langan',
                amount: summary.totalPaid,
                currency: currency,
                color: colors.success,
                icon: Icons.check_circle_outline_rounded,
              );
              if (constraints.maxWidth < 300 ||
                  MediaQuery.textScalerOf(context).scale(14) > 19) {
                return Column(
                  children: [given, const SizedBox(height: 8), paid],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: given),
                  const SizedBox(width: 8),
                  Expanded(child: paid),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          _AmountTile(
            label: 'Qolgan',
            amount: summary.totalRemaining,
            currency: currency,
            color: colors.warning,
            icon: Icons.hourglass_bottom_rounded,
            wide: true,
          ),
          if (summary.overdueAmount > Decimal.zero) ...[
            const SizedBox(height: 10),
            _AmountTile(
              label: 'Muddati o‘tgan',
              amount: summary.overdueAmount,
              currency: currency,
              color: colors.error,
              icon: Icons.warning_amber_rounded,
              wide: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .07),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withValues(alpha: .15)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: context.colors.textSecondary),
        ),
      ],
    ),
  );
}

class _AmountTile extends StatelessWidget {
  const _AmountTile({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
    required this.icon,
    this.wide = false,
  });
  final String label;
  final Decimal amount;
  final int currency;
  final Color color;
  final IconData icon;
  final bool wide;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .07),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: .16)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _money(amount, currency),
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: wide ? 22 : 17,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    ),
  );
}

class _ReportEntry extends StatelessWidget {
  const _ReportEntry({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: AppCard(
      hasShadow: false,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const SizedBox(width: 12),
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

class _RecoveryPage extends StatelessWidget {
  const _RecoveryPage({required this.initialCurrency});
  final int initialCurrency;
  @override
  Widget build(BuildContext context) => _CurrencyReportPage(
    title: 'Undirish samaradorligi',
    initialCurrency: initialCurrency,
    builder: (currency) => _ReportLoader<RecoveryReport>(
      key: ValueKey(currency),
      load: () => _repository.getRecoveryReport(currency),
      builder: (context, report, reload) => _ReportList(
        onRefresh: reload,
        children: [
          AppCard(
            child: Column(
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: (report.recoveryRate / 100)
                              .clamp(0, 1)
                              .toDouble(),
                          strokeWidth: 12,
                          color: context.colors.success,
                          backgroundColor: context.colors.surfaceSecondary,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${report.recoveryRate}%',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Undirilgan',
                            style: TextStyle(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  report.ratingLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                _MoneyRow(
                  label: 'Berilgan',
                  amount: report.totalGiven ?? Decimal.zero,
                  currency: currency,
                ),
                _MoneyRow(
                  label: 'Undirilgan',
                  amount: report.recoveredAmount,
                  currency: currency,
                  color: context.colors.success,
                ),
                _MoneyRow(
                  label: 'Qolgan',
                  amount: report.totalRemaining ?? Decimal.zero,
                  currency: currency,
                ),
                _MoneyRow(
                  label: 'Muddati o‘tgan',
                  amount: report.overdueAmount,
                  currency: currency,
                  color: context.colors.error,
                ),
                Text(
                  'Kechikish darajasi: ${report.overdueRate}%',
                  style: TextStyle(color: context.colors.error, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'To‘lov holatlari',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          for (final status in ['paid', 'partial', 'overdue', 'pending'])
            _ReportEntry(
              icon: Icons.receipt_long_outlined,
              color: _statusColor(context, status),
              title: _statusLabel(status),
              subtitle: '${report.byItems[status] ?? 0} ta to‘lov',
              onTap: () => _open(
                context,
                _ItemsPage(currency: currency, status: status),
              ),
            ),
        ],
      ),
    ),
  );
}

String _statusLabel(String status) => switch (status) {
  'paid' => 'To‘langan',
  'partial' => 'Qisman to‘langan',
  'overdue' => 'Muddati o‘tgan',
  _ => 'Kutilmoqda',
};
Color _statusColor(BuildContext context, String status) => switch (status) {
  'paid' => context.colors.success,
  'partial' => context.colors.info,
  'overdue' => context.colors.error,
  _ => context.colors.textTertiary,
};

class _ForecastPage extends StatefulWidget {
  const _ForecastPage({required this.initialCurrency});
  final int initialCurrency;
  @override
  State<_ForecastPage> createState() => _ForecastPageState();
}

class _ForecastPageState extends State<_ForecastPage> {
  int _days = 30;
  DateTimeRange? _range;
  @override
  Widget build(BuildContext context) {
    final from = _range?.start ?? DateUtils.dateOnly(DateTime.now());
    final to = _range?.end ?? from.add(Duration(days: _days));
    return _CurrencyReportPage(
      title: 'Kutilayotgan to‘lovlar',
      initialCurrency: widget.initialCurrency,
      builder: (currency) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AppSegmentedControl<int>(
                  value: _range == null ? _days : -1,
                  segments: const [
                    AppSegment(value: 30, label: '30 kun'),
                    AppSegment(value: 60, label: '60 kun'),
                    AppSegment(value: 90, label: '90 kun'),
                  ],
                  onChanged: (days) => setState(() {
                    _days = days;
                    _range = null;
                  }),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.date_range_rounded, size: 18),
                  label: Text(
                    '${AppDateFormatter.display(from)} – ${AppDateFormatter.display(to)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      initialDateRange: DateTimeRange(start: from, end: to),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(DateTime.now().year + 10, 12, 31),
                    );
                    if (picked != null && mounted) {
                      setState(() => _range = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _ReportLoader<InstallmentForecast>(
              key: ValueKey('$currency-$from-$to'),
              load: () => _repository.getInstallmentForecast(
                currencyTypeId: currency,
                dateFrom: from,
                dateTo: to,
              ),
              builder: (context, report, reload) => _ReportList(
                onRefresh: reload,
                children: [
                  _AmountTile(
                    label: 'Kutilayotgan summa',
                    amount: report.expectedAmount,
                    currency: currency,
                    color: context.colors.accentViolet,
                    icon: Icons.calendar_month_rounded,
                    wide: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _Metric(
                          label: 'To‘lovlar',
                          value: '${report.itemsCount} ta',
                          icon: Icons.receipt_long_outlined,
                          color: context.colors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Metric(
                          label: 'Mijozlar',
                          value: '${report.partnersCount} ta',
                          icon: Icons.people_outline,
                          color: context.colors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyPage extends StatefulWidget {
  const _MonthlyPage({required this.initialCurrency});
  final int initialCurrency;
  @override
  State<_MonthlyPage> createState() => _MonthlyPageState();
}

class _MonthlyPageState extends State<_MonthlyPage> {
  int _year = DateTime.now().year;
  @override
  Widget build(BuildContext context) => _CurrencyReportPage(
    title: 'Oylik dinamika',
    initialCurrency: widget.initialCurrency,
    builder: (currency) => Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Oldingi yil',
                onPressed: () => setState(() => _year--),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                '$_year',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                tooltip: 'Keyingi yil',
                onPressed: () => setState(() => _year++),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        Expanded(
          child: _ReportLoader<List<MonthlyInstallmentStat>>(
            key: ValueKey('$currency-$_year'),
            load: () => _repository.getMonthlyInstallments(
              year: _year,
              currencyTypeId: currency,
            ),
            builder: (context, items, reload) => _ReportList(
              onRefresh: reload,
              children: [
                _AmountTile(
                  label: 'Jami to‘lovlar',
                  amount: items.fold(
                    Decimal.zero,
                    (sum, item) => sum + item.amount,
                  ),
                  currency: currency,
                  color: context.colors.primary,
                  icon: Icons.bar_chart_rounded,
                  wide: true,
                ),
                const SizedBox(height: 16),
                if (items.isNotEmpty)
                  AppCard(
                    child: SizedBox(
                      height: 210,
                      child: BarChart(
                        BarChartData(
                          barGroups: [
                            for (var i = 0; i < items.length; i++)
                              BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: items[i].amount.toDouble(),
                                    color: context.colors.primary,
                                    width: 10,
                                  ),
                                ],
                              ),
                          ],
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < 0 || index >= items.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      items[index].month,
                                      style: const TextStyle(fontSize: 9),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  const AppEmptyState(
                    title: 'Ma’lumot yo‘q',
                    icon: Icons.bar_chart_rounded,
                  ),
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      hasShadow: false,
                      child: Column(
                        children: [
                          _MoneyRow(
                            label: item.month,
                            amount: item.amount,
                            currency: currency,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${item.paymentsCount} ta to‘lov',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _RiskyPage extends StatelessWidget {
  const _RiskyPage({required this.initialCurrency});
  final int initialCurrency;
  @override
  Widget build(BuildContext context) => _CurrencyReportPage(
    title: 'Muammoli mijozlar',
    initialCurrency: initialCurrency,
    builder: (currency) => _ReportLoader<List<RiskyPartner>>(
      key: ValueKey(currency),
      load: () => _repository.getRiskyPartners(currency),
      builder: (context, items, reload) => _ReportList(
        onRefresh: reload,
        children: [
          if (items.isEmpty)
            const AppEmptyState(
              title: 'Muammoli mijozlar yo‘q',
              icon: Icons.check_circle_outline_rounded,
            ),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                hasShadow: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.partnerName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          item.riskLevel == 'high'
                              ? 'Yuqori xavf'
                              : item.riskLevel == 'medium'
                              ? 'O‘rta xavf'
                              : 'Past xavf',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: item.riskLevel == 'high'
                                ? context.colors.error
                                : context.colors.warning,
                          ),
                        ),
                      ],
                    ),
                    if (item.phone.isNotEmpty)
                      Text(
                        item.phone,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      '${item.overdueItems} ta kechikkan to‘lov · O‘rtacha ${item.averageDelayDays} kun',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    _MoneyRow(
                      label: 'Muddati o‘tgan',
                      amount: item.overdueAmount ?? Decimal.zero,
                      currency: currency,
                      color: context.colors.error,
                    ),
                    _MoneyRow(
                      label: 'Qolgan',
                      amount: item.totalRemaining ?? Decimal.zero,
                      currency: currency,
                    ),
                    Text(
                      'Xavf balli: ${item.riskScore}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _PartnersPage extends StatelessWidget {
  const _PartnersPage({required this.initialCurrency});
  final int initialCurrency;
  @override
  Widget build(BuildContext context) => _CurrencyReportPage(
    title: 'Mijozlar bo‘yicha',
    initialCurrency: initialCurrency,
    builder: (currency) => _PagedReport<InstallmentPartnerRanking>(
      key: ValueKey(currency),
      load: (page) => _repository.getInstallmentPartners(currency, page: page),
      itemBuilder: (context, item) => AppCard(
        hasShadow: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              item.partnerName,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            if (item.phone.isNotEmpty)
              Text(
                item.phone,
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.textSecondary,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              '${item.activePlans} ta faol reja',
              style: TextStyle(fontSize: 12, color: context.colors.primary),
            ),
            _MoneyRow(
              label: 'Berilgan',
              amount: item.totalGiven,
              currency: currency,
            ),
            _MoneyRow(
              label: 'To‘langan',
              amount: item.totalPaid ?? Decimal.zero,
              currency: currency,
              color: context.colors.success,
            ),
            _MoneyRow(
              label: 'Qolgan',
              amount: item.remaining,
              currency: currency,
            ),
            if (item.lastPaymentAt != null)
              Text(
                'Oxirgi to‘lov: ${item.lastPaymentAt}',
                style: TextStyle(
                  fontSize: 11,
                  color: context.colors.textSecondary,
                ),
              ),
            if (item.totalGiven > Decimal.zero) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ((item.totalPaid ?? Decimal.zero) / item.totalGiven)
                      .toDouble()
                      .clamp(0, 1),
                  color: context.colors.success,
                  backgroundColor: context.colors.surfaceSecondary,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
            ],
            if (item.overdue > Decimal.zero)
              _MoneyRow(
                label: 'Muddati o‘tgan',
                amount: item.overdue,
                currency: currency,
                color: context.colors.error,
              ),
          ],
        ),
      ),
    ),
  );
}

class _ItemsPage extends StatelessWidget {
  const _ItemsPage({required this.currency, required this.status});
  final int currency;
  final String status;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_statusLabel(status))),
    body: SafeArea(
      child: _PagedReport<InstallmentReportItem>(
        load: (page) => _repository.getInstallmentReportItems(
          currencyTypeId: currency,
          status: status,
          page: page,
        ),
        itemBuilder: (context, item) => AppCard(
          hasShadow: false,
          onTap: item.planId <= 0
              ? null
              : () => context.push(RoutePaths.installmentDetail(item.planId)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                item.partnerName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.number}-qism${item.dueDate == null ? '' : ' · ${AppDateFormatter.display(item.dueDate!)}'}',
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.textSecondary,
                ),
              ),
              _MoneyRow(
                label: 'Summa',
                amount: item.amount,
                currency: currency,
              ),
              _MoneyRow(
                label: 'To‘langan',
                amount: item.paidAmount,
                currency: currency,
                color: context.colors.success,
              ),
              _MoneyRow(
                label: 'Qolgan',
                amount: item.remaining,
                currency: currency,
              ),
              Text(
                item.statusLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: _statusColor(context, status),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _PagedReport<T> extends StatefulWidget {
  const _PagedReport({
    super.key,
    required this.load,
    required this.itemBuilder,
  });
  final Future<ApiResult<SimplePage<T>>> Function(int page) load;
  final Widget Function(BuildContext, T) itemBuilder;
  @override
  State<_PagedReport<T>> createState() => _PagedReportState<T>();
}

class _PagedReportState<T> extends State<_PagedReport<T>> {
  final List<T> _items = [];
  int _page = 0;
  int _request = 0;
  bool _hasMore = true;
  bool _loading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    if (!reset && (_loading || !_hasMore)) return;
    final request = ++_request;
    final page = reset ? 1 : _page + 1;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await widget.load(page);
    if (!mounted || request != _request) return;
    setState(() {
      _loading = false;
      result.when(
        success: (data) {
          if (reset) _items.clear();
          _items.addAll(data.items);
          _page = page;
          _hasMore = data.hasNext;
        },
        failure: (error) => _error = error.message,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_page == 0 && _loading) return const AppSkeletonList();
    if (_page == 0 && _error != null) {
      return AppErrorState(
        description: _error,
        onRetry: () => _load(reset: true),
      );
    }
    return _ReportList(
      onRefresh: () => _load(reset: true),
      children: [
        if (_items.isEmpty)
          const AppEmptyState(
            title: 'Ma’lumot yo‘q',
            icon: Icons.receipt_long_outlined,
          ),
        for (final item in _items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: widget.itemBuilder(context, item),
          ),
        if (_hasMore)
          Center(
            child: _loading
                ? const CircularProgressIndicator()
                : TextButton(
                    onPressed: () => _load(),
                    child: Text(
                      _error == null ? 'Yana yuklash' : 'Qayta urinish',
                    ),
                  ),
          ),
      ],
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.amount,
    required this.currency,
    this.color,
  });
  final String label;
  final Decimal amount;
  final int currency;
  final Color? color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _money(amount, currency),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color ?? context.colors.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );
}
