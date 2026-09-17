import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/cards/app_kpi_card.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../../../core/widgets/typography/money_text.dart';
import '../../data/partner_report_models.dart';
import '../../data/reports_repository.dart';

/// Hamkor bo'yicha detal hisobot — V2, grafiklar bilan (MOBILE_APP_TZ.md 12.2).
class PartnerDetailReportPage extends StatefulWidget {
  const PartnerDetailReportPage({super.key, required this.partnerId, required this.partnerName});

  final int partnerId;
  final String partnerName;

  @override
  State<PartnerDetailReportPage> createState() => _PartnerDetailReportPageState();
}

class _PartnerDetailReportPageState extends State<PartnerDetailReportPage> {
  PartnerDetailReport? _report;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _report = null;
      _error = null;
    });
    final result = await getIt<ReportsRepository>().getPartnerDetailReport(widget.partnerId);
    if (!mounted) return;
    result.when(success: (r) => setState(() => _report = r), failure: (f) => setState(() => _error = f.message));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.partnerName)),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_error != null) return AppErrorState(title: 'Yuklab bo\'lmadi', description: _error, onRetry: _load);
    final report = _report;
    if (report == null) return const AppSkeletonList();

    final colors = context.colors;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Row(
            children: [
              Expanded(
                child: AppKpiCard(label: 'Balans', value: report.balance.toString(), icon: Icons.account_balance_wallet_outlined),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppKpiCard(
                  label: 'Operatsiyalar',
                  value: '${report.operationsCount}',
                  icon: Icons.swap_horiz_rounded,
                  isZero: report.operationsCount == 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text('Kirim'), MoneyText(report.income, colorOverride: colors.success)],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text('Chiqim'), MoneyText(report.expense, colorOverride: colors.error)],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (report.monthlyStatistics.isNotEmpty) ...[
            Text('So\'nggi 3 oy', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    barGroups: [
                      for (var i = 0; i < report.monthlyStatistics.length; i++)
                        BarChartGroupData(x: i, barRods: [
                          BarChartRodData(toY: report.monthlyStatistics[i].income.toDouble(), color: colors.success, width: 10),
                          BarChartRodData(toY: report.monthlyStatistics[i].expense.toDouble(), color: colors.error, width: 10),
                        ]),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= report.monthlyStatistics.length) return const SizedBox.shrink();
                            return Text(report.monthlyStatistics[i].label, style: const TextStyle(fontSize: 10));
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
          if (report.balanceDynamics.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('So\'nggi 7 kun — balans', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < report.balanceDynamics.length; i++)
                            FlSpot(i.toDouble(), report.balanceDynamics[i].balance.toDouble()),
                        ],
                        isCurved: true,
                        color: colors.primary,
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= report.balanceDynamics.length) return const SizedBox.shrink();
                            return Text(report.balanceDynamics[i].label, style: const TextStyle(fontSize: 9));
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
        ],
      ),
    );
  }
}
