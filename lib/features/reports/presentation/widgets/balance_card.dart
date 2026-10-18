import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters/money_formatter.dart';

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
        ? 'Mijoz qarzi'
        : balance > Decimal.zero
        ? 'Mijoz haqqi'
        : 'Hisob yopilgan';
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
        borderRadius: BorderRadius.circular(20),
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
                  color: Colors.white.withValues(alpha: .16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  balance < Decimal.zero
                      ? Icons.south_west_rounded
                      : Icons.north_east_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Joriy balans',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                currency,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: .85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            MoneyFormatter.groupDigits(balance),
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: .9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.sync_alt_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$operationsCount ta operatsiya',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
