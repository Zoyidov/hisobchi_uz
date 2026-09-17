import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isExpense ? Icons.arrow_upward : Icons.arrow_downward, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isExpense ? 'Chiqim' : 'Kirim',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    decoration: wallet.isCancelled ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Opacity(
                  opacity: wallet.isCancelled ? 0.5 : 1,
                  child: MoneyText(
                    wallet.summa,
                    currencyTypeId: wallet.currencyTypeId,
                    signed: true,
                    colorOverride: isExpense ? colors.error : colors.success,
                  ),
                ),
                if (wallet.description != null && wallet.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(wallet.description!, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
                ],
                if (wallet.returnDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Qaytarish: ${AppDateFormatter.display(wallet.returnDate!)}',
                    style: TextStyle(color: colors.info, fontSize: 12),
                  ),
                ],
                if (wallet.isCancelled) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Bekor qilingan${wallet.cancelReason != null ? ': ${wallet.cancelReason}' : ''}',
                    style: TextStyle(color: colors.error, fontSize: 12),
                  ),
                ],
                if (wallet.performedByName != null) ...[
                  const SizedBox(height: 4),
                  Text('${wallet.performedByName} kiritdi', style: TextStyle(color: colors.textTertiary, fontSize: 11)),
                ],
              ],
            ),
          ),
          if (wallet.createdAt != null)
            Text(AppDateFormatter.relative(wallet.createdAt!, isRussian: false),
                style: TextStyle(color: colors.textTertiary, fontSize: 11)),
        ],
      ),
    );
  }
}
