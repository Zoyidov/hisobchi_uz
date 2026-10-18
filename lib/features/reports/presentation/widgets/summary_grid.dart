import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters/money_formatter.dart';

class SummaryGrid extends StatelessWidget {
  const SummaryGrid({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.operationsCount,
    required this.currency,
    this.onIncomeTap,
    this.onExpenseTap,
  });
  final Decimal totalIncome;
  final Decimal totalExpense;
  final int operationsCount;
  final String currency;
  final VoidCallback? onIncomeTap;
  final VoidCallback? onExpenseTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final income = _SummaryCard(
          title: 'Jami kirim',
          amount: totalIncome,
          currency: currency,
          icon: Icons.trending_down_rounded,
          color: context.colors.success,
          onTap: onIncomeTap,
        );
        final expense = _SummaryCard(
          title: 'Jami chiqim',
          amount: totalExpense,
          currency: currency,
          icon: Icons.trending_up_rounded,
          color: context.colors.error,
          onTap: onExpenseTap,
        );
        if (constraints.maxWidth < 310 ||
            MediaQuery.textScalerOf(context).scale(14) > 19) {
          return Column(
            children: [income, const SizedBox(height: 10), expense],
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
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.currency,
    required this.icon,
    required this.color,
    this.onTap,
  });
  final String title;
  final Decimal amount;
  final String currency;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: context.colors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: context.colors.border),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 19),
                ),
                const Spacer(),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.colors.textTertiary,
                    size: 19,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              MoneyFormatter.groupDigits(amount),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              currency,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
