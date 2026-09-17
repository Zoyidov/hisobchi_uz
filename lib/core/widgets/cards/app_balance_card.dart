import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../utils/formatters/money_formatter.dart';
import 'app_card.dart';

/// UZS/USD balans kartasi — kirim/chiqim/balans (MOBILE_APP_TZ.md 8.5,
/// E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 23, 158).
class AppBalanceCard extends StatelessWidget {
  const AppBalanceCard({
    super.key,
    required this.currencyLabel,
    required this.income,
    required this.expense,
    required this.balance,
    this.installmentRemaining,
  });

  final String currencyLabel;
  final Decimal income;
  final Decimal expense;
  final Decimal balance;
  final Decimal? installmentRemaining;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final balanceNum = balance.toDouble();
    final balColor = amountColor(context, balanceNum);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sof balans',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border.withValues(alpha: 0.6)),
                ),
                child: Text(
                  currencyLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            MoneyFormatter.formatSigned(balance, currencyLabel: currencyLabel),
            style: AppTypography.moneyCard.copyWith(
              color: balColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _flowItem(
                    context,
                    label: 'Kirim',
                    amount: income,
                    icon: Icons.arrow_downward_rounded,
                    color: colors.success,
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: colors.border.withValues(alpha: 0.8),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                Expanded(
                  child: _flowItem(
                    context,
                    label: 'Chiqim',
                    amount: expense,
                    icon: Icons.arrow_upward_rounded,
                    color: colors.error,
                  ),
                ),
              ],
            ),
          ),
          if (installmentRemaining != null && installmentRemaining! > Decimal.zero) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 14, color: colors.info),
                      const SizedBox(width: 6),
                      Text(
                        "Bo'lib to'lash qoldig'i",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.info,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  Text(
                    MoneyFormatter.format(installmentRemaining!, currencyLabel: currencyLabel),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.info,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _flowItem(
    BuildContext context, {
    required String label,
    required Decimal amount,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.colors.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                MoneyFormatter.format(amount, currencyLabel: currencyLabel),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
