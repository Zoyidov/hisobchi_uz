import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/phone_formatter.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/chips/app_status_chip.dart';
import '../../../../core/widgets/media/app_avatar.dart';
import '../../../../core/widgets/typography/money_text.dart';
import '../../data/partner_models.dart';

/// `PartnerCard` — business component (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 24,
/// MOBILE_APP_TZ.md 8.2). 0 bo'lgan valyuta ko'rsatilmaydi.
class PartnerCard extends StatelessWidget {
  const PartnerCard({super.key, required this.partner, required this.onTap});

  final Partner partner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (partner.isDeleted) {
      return AppCard(
        child: Row(
          children: [
            Opacity(opacity: 0.5, child: AppAvatar(name: partner.name)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(partner.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: colors.textTertiary)),
                  const AppStatusChip(label: 'O\'chirilgan', tone: AppStatusChipTone.neutral),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final tone = switch (partner.status) {
      PartnerBalanceStatus.creditor => AppStatusChipTone.success,
      PartnerBalanceStatus.debtor => AppStatusChipTone.error,
      PartnerBalanceStatus.closed => AppStatusChipTone.neutral,
    };
    final statusLabel = switch (partner.status) {
      PartnerBalanceStatus.creditor => 'Haqdor',
      PartnerBalanceStatus.debtor => 'Qarzdor',
      PartnerBalanceStatus.closed => 'Yopiq',
    };

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: BorderRadius.circular(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(name: partner.name, size: 48),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        partner.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppStatusChip(label: statusLabel, tone: tone),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  PhoneFormatter.toDisplay(partner.phone),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    if (partner.balanceUzs != Decimal.zero)
                      MoneyText(partner.balanceUzs, currencyTypeId: 1, signed: true, size: MoneySize.list),
                    if (partner.balanceUsd != Decimal.zero)
                      MoneyText(partner.balanceUsd, currencyTypeId: 2, signed: true, size: MoneySize.list),
                  ],
                ),
                if (partner.installmentRemainingUzs > Decimal.zero || partner.installmentRemainingUsd > Decimal.zero) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.info.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 12, color: colors.info),
                        const SizedBox(width: 5),
                        Text('Bo\'lib to\'lash: ', style: TextStyle(color: colors.info, fontSize: 11, fontWeight: FontWeight.w600)),
                        if (partner.installmentRemainingUzs > Decimal.zero)
                          MoneyText(partner.installmentRemainingUzs, currencyTypeId: 1, colorOverride: colors.info, size: MoneySize.list),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, color: colors.textTertiary, size: 20),
        ],
      ),
    );
  }
}
