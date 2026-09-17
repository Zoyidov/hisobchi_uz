import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/typography/money_text.dart';
import '../../data/partner_models.dart';

/// `TransactionCard` — business component (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 25,
/// MOBILE_APP_TZ.md 8.6).
class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.wallet, required this.onTap});

  final Wallet wallet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isExpense = wallet.isExpense;
    final color = wallet.isCancelled ? colors.textTertiary : (isExpense ? colors.error : colors.success);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: BorderRadius.circular(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isExpense ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isExpense ? 'Chiqim' : 'Kirim',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w600,
                            decoration: wallet.isCancelled ? TextDecoration.lineThrough : null,
                          ),
                    ),
                    if (wallet.createdAt != null)
                      Text(
                        AppDateFormatter.relative(wallet.createdAt!, isRussian: false),
                        style: TextStyle(color: colors.textTertiary, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Opacity(
                  opacity: wallet.isCancelled ? 0.5 : 1,
                  child: MoneyText(
                    wallet.summa,
                    currencyTypeId: wallet.currencyTypeId,
                    signed: true,
                    size: MoneySize.card,
                    colorOverride: isExpense ? colors.error : colors.success,
                  ),
                ),
                if (wallet.description != null && wallet.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    wallet.description!,
                    style: TextStyle(color: colors.textSecondary, fontSize: 13, height: 1.3),
                  ),
                ],
                if (wallet.returnDate != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.info.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Qaytarish: ${AppDateFormatter.display(wallet.returnDate!)}',
                      style: TextStyle(color: colors.info, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                if (wallet.isCancelled) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Bekor qilingan${wallet.cancelReason != null ? ': ${wallet.cancelReason}' : ''}',
                      style: TextStyle(color: colors.error, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                if (wallet.performedByName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${wallet.performedByName} kiritdi',
                    style: TextStyle(color: colors.textTertiary, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
