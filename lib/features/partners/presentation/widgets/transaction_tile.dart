import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/typography/money_text.dart';
import '../../data/partner_models.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/localization/app_localization_extension.dart';

/// `TransactionCard` — business component (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 25,
/// MOBILE_APP_TZ.md 8.6).
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.wallet,
    required this.onTap,
    this.compact = false,
  });

  final bool compact;
  final Wallet wallet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isExpense = wallet.isExpense;
    final color = wallet.isCancelled
        ? colors.textTertiary
        : (isExpense ? colors.error : colors.success);

    return AppCard(
      onTap: onTap,
      hasShadow: !compact,
      padding: EdgeInsets.all(compact ? 10 : AppSpacing.md),
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: compact ? 32 : 40,
            height: compact ? 32 : 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              isExpense ? AppIcons.arrowUp : AppIcons.arrowDown,
              color: color,
              size: compact ? 16 : 20,
            ),
          ),
          SizedBox(width: compact ? 10 : AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isExpense
                            ? context.l10n.commonExpense
                            : context.l10n.commonIncome,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                          decoration: wallet.isCancelled
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    if (wallet.createdAt != null)
                      Text(
                        AppDateFormatter.relative(
                          wallet.createdAt!,
                          context.l10n,
                        ),
                        style: TextStyle(
                          color: colors.textTertiary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
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
                    size: compact ? MoneySize.list : MoneySize.card,
                    colorOverride: isExpense ? colors.error : colors.success,
                  ),
                ),
                if (wallet.description != null &&
                    wallet.description!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    wallet.description!,
                    maxLines: compact ? 2 : null,
                    overflow: compact ? TextOverflow.ellipsis : null,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
                if (wallet.returnDate != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.info.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      context.l10n.walletReturnShort(
                        AppDateFormatter.display(wallet.returnDate!),
                      ),
                      style: TextStyle(
                        color: colors.info,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (wallet.isCancelled) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      wallet.cancelReason != null
                          ? '${context.l10n.commonCancelled}: ${wallet.cancelReason}'
                          : context.l10n.commonCancelled,
                      style: TextStyle(
                        color: colors.error,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (wallet.performedByName != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    context.l10n.walletEnteredBy(wallet.performedByName!),
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
