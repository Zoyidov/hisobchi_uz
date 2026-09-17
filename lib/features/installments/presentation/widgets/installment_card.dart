import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/chips/app_status_chip.dart';
import '../../../../core/widgets/misc/app_progress_bar.dart';
import '../../../../core/widgets/typography/money_text.dart';
import '../../data/installment_models.dart';

/// `InstallmentCard` — business component (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 26,
/// MOBILE_APP_TZ.md 9.3).
class InstallmentCard extends StatelessWidget {
  const InstallmentCard({super.key, required this.plan, required this.onTap, this.showPartnerName = false});

  final InstallmentPlan plan;
  final VoidCallback onTap;
  final bool showPartnerName;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (tone, _) = switch (plan.status) {
      InstallmentPlanStatus.active => (AppStatusChipTone.info, 'Faol'),
      InstallmentPlanStatus.completed => (AppStatusChipTone.success, 'Yopilgan'),
      InstallmentPlanStatus.cancelled => (AppStatusChipTone.neutral, 'Bekor qilingan'),
    };

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showPartnerName) ...[
            Text(plan.partnerName, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
          ],
          MoneyText(plan.totalAmount, currencyTypeId: plan.currencyTypeId, size: MoneySize.card),
          const SizedBox(height: AppSpacing.sm),
          AppProgressBar(value: plan.progress),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('To\'langan: ', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
              MoneyText(plan.paidAmount, currencyTypeId: plan.currencyTypeId, size: MoneySize.list, colorOverride: colors.success),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Qolgan: ', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
              MoneyText(plan.remaining, currencyTypeId: plan.currencyTypeId, size: MoneySize.list, colorOverride: colors.error),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${plan.itemsCount} ta qism', style: TextStyle(color: colors.textTertiary, fontSize: 12)),
              AppStatusChip(label: plan.statusLabel, tone: tone),
            ],
          ),
        ],
      ),
    );
  }
}
