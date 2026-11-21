import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters/money_formatter.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/localization/app_localization_extension.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.currency,
    required this.operationsCount,
  });
  final Decimal balance;
  final String currency;
  final int operationsCount;

  @override
  Widget build(BuildContext context) {
    final tint = balance < Decimal.zero
        ? context.colors.error
        : context.colors.success;
    final subtitle = balance < Decimal.zero
        ? context.l10n.reportClientDebt
        : balance > Decimal.zero
        ? context.l10n.reportClientCredit
        : context.l10n.reportAccountClosed;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint, Color.lerp(tint, context.colors.textPrimary, .16)!],
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: tint.withValues(alpha: .18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: context.colors.onPrimary.withValues(alpha: .16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  balance < Decimal.zero ? AppIcons.income : AppIcons.expense,
                  size: 22,
                  color: context.colors.onPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.l10n.reportCurrentBalance,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.colors.onPrimary,
                  ),
                ),
              ),
              Text(
                currency,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: context.colors.onPrimary.withValues(alpha: .85),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            MoneyFormatter.groupDigits(balance),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: context.colors.onPrimary,
              letterSpacing: -.6,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.colors.onPrimary.withValues(alpha: .9),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                AppIcons.exchange,
                size: 16,
                color: context.colors.onPrimary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  context.l10n.reportOperationsCount(operationsCount),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.onPrimary,
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
