import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/localization/app_localization_extension.dart';

class BalanceLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final List<String> labels;
  final String currency;

  const BalanceLineChart({
    super.key,
    required this.spots,
    required this.labels,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: context.colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.reportBalanceDynamics,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.reportNoDataYet,
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      );
    }

    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final barData = LineChartBarData(
      spots: spots,
      isCurved: true,
      color: colors.primary,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: 3.5,
          color: colors.surface,
          strokeWidth: 2,
          strokeColor: colors.primary,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.primary.withValues(alpha: 0.2),
            colors.primary.withValues(alpha: 0.0),
          ],
        ),
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceSecondary : colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.reportBalanceDynamics,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            context.l10n.reportLastOperations(currency),
            style: TextStyle(
              fontSize: 12,
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: colors.border.withValues(alpha: 0.5),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) =>
                          _getLeftTitles(value, meta, colors),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) =>
                          _getBottomTitles(value, meta, colors),
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: colors.border.withValues(alpha: 0.8),
                      width: 1,
                    ),
                    left: BorderSide(
                      color: colors.border.withValues(alpha: 0.8),
                      width: 1,
                    ),
                  ),
                ),
                lineBarsData: [barData],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => colors.inverseSurface,
                    tooltipMargin: 6,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          _formatNumber(spot.y),
                          TextStyle(
                            color: colors.onInverseSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    final absValue = value.abs();
    if (absValue >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (absValue >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  Widget _getBottomTitles(
    double value,
    TitleMeta meta,
    AppColorsExtension colors,
  ) {
    final style = TextStyle(
      color: colors.textTertiary,
      fontWeight: FontWeight.w600,
      fontSize: 10,
    );
    final index = value.toInt();
    if (index >= 0 && index < labels.length) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 8,
        child: Text(labels[index], style: style),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _getLeftTitles(
    double value,
    TitleMeta meta,
    AppColorsExtension colors,
  ) {
    if (value == meta.max) return const SizedBox.shrink();

    final style = TextStyle(
      color: colors.textTertiary,
      fontWeight: FontWeight.w600,
      fontSize: 10,
    );

    String text;
    if (value >= 1000000) {
      text = '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      text = '${(value / 1000).toStringAsFixed(0)}K';
    } else {
      text = value.toStringAsFixed(0);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 6,
      child: Text(text, style: style),
    );
  }
}
