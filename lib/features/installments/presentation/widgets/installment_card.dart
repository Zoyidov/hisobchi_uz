import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/chips/app_status_chip.dart';
import '../../../../core/widgets/misc/app_progress_bar.dart';
import '../../../../core/widgets/typography/money_text.dart';
import '../../data/installment_models.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/localization/app_localization_extension.dart';

/// `InstallmentCard` — business component (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 26,
/// MOBILE_APP_TZ.md 9.3).
class InstallmentCard extends StatelessWidget {
  const InstallmentCard({
    super.key,
    required this.plan,
    required this.onTap,
    this.showPartnerName = false,
  });

  final InstallmentPlan plan;
  final VoidCallback onTap;
  final bool showPartnerName;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (tone, _) = switch (plan.status) {
      InstallmentPlanStatus.active => (
        AppStatusChipTone.info,
        context.l10n.installmentStatusActive,
      ),
      InstallmentPlanStatus.completed => (
        AppStatusChipTone.success,
        context.l10n.installmentStatusClosed,
      ),
      InstallmentPlanStatus.cancelled => (
        AppStatusChipTone.neutral,
        context.l10n.commonCancelled,
      ),
    };

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showPartnerName) ...[
                      Text(
                        plan.partnerName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                    ],
                    MoneyText(
                      plan.totalAmount,
                      currencyTypeId: plan.currencyTypeId,
                      size: MoneySize.card,
                    ),
                  ],
                ),
              ),
              AppStatusChip(label: plan.statusLabel, tone: tone),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppProgressBar(value: plan.progress, height: 6),
          const SizedBox(height: AppSpacing.sm + 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.commonPaid,
                        style: TextStyle(
                          color: colors.textTertiary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      MoneyText(
                        plan.paidAmount,
                        currencyTypeId: plan.currencyTypeId,
                        size: MoneySize.list,
                        colorOverride: colors.success,
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 26, color: colors.divider),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.commonRemaining,
                        style: TextStyle(
                          color: colors.textTertiary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      MoneyText(
                        plan.remaining,
                        currencyTypeId: plan.currencyTypeId,
                        size: MoneySize.list,
                        colorOverride: colors.error,
                      ),
                    ],
                  ),
                ),
                Text(
                  context.l10n.installmentPartsCountShort(plan.itemsCount),
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
