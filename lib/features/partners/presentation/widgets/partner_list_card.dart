part of '../pages/partners_list_page.dart';

class _PartnerListCard extends StatelessWidget {
  const _PartnerListCard({
    super.key,
    required this.partner,
    required this.onTap,
  });
  final Partner partner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final phoneDigits = partner.phone.replaceAll(RegExp(r'[^0-9]'), '');
    final phone = phoneDigits.length == 12 && phoneDigits.startsWith('998')
        ? phoneDigits.substring(3)
        : phoneDigits;
    final (label, accent) = partner.isDeleted
        ? ('O‘chirilgan', colors.textTertiary)
        : switch (partner.status) {
            PartnerBalanceStatus.creditor => ('Haqdor', colors.success),
            PartnerBalanceStatus.debtor => ('Qarzdor', colors.error),
            PartnerBalanceStatus.closed => ('Yopiq', colors.textSecondary),
          };
    final hasBalance =
        partner.balanceUzs != Decimal.zero ||
        partner.balanceUsd != Decimal.zero;
    final hasInstallments =
        partner.installmentRemainingUzs > Decimal.zero ||
        partner.installmentRemainingUsd > Decimal.zero;
    final initials = partner.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p.characters.first)
        .join()
        .toUpperCase();
    final menu = partner.isDeleted
        ? const SizedBox(width: 12)
        : PopupMenuButton<String>(
            tooltip: 'Mijoz amallari',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 224, maxWidth: 280),
            color: colors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 8,
            shadowColor: colors.textPrimary.withValues(alpha: .12),
            position: PopupMenuPosition.under,
            offset: const Offset(-8, 4),
            menuPadding: const EdgeInsets.all(6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: colors.borderSubtle),
            ),
            icon: Icon(AppIcons.more, size: 19, color: colors.textTertiary),
            onSelected: (value) {
              if (value == 'detail') {
                onTap();
              } else {
                _contact(context, value);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'tel',
                height: 52,
                child: _PartnerMenuAction(
                  icon: AppIcons.call,
                  label: 'Qo‘ng‘iroq qilish',
                  color: colors.success,
                ),
              ),
              PopupMenuItem(
                value: 'sms',
                height: 52,
                child: _PartnerMenuAction(
                  icon: AppIcons.message,
                  label: 'SMS yozish',
                  color: colors.info,
                ),
              ),
              const PopupMenuDivider(height: 10),
              PopupMenuItem(
                value: 'detail',
                height: 52,
                child: _PartnerMenuAction(
                  icon: AppIcons.user,
                  label: 'Tafsilotlarni ochish',
                  color: colors.primary,
                ),
              ),
            ],
          );
    final identity = Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            initials.isEmpty ? '?' : initials,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colors.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                partner.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                PhoneFormatter.toDisplay(phone).replaceFirst('+998 ', ''),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    final amounts = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!hasBalance)
          _Amount(amount: Decimal.zero, currency: partner.mainCurrencyTypeId),
        if (partner.balanceUzs != Decimal.zero)
          _Amount(amount: partner.balanceUzs, currency: 1, signed: true),
        if (partner.balanceUsd != Decimal.zero)
          _Amount(amount: partner.balanceUsd, currency: 2, signed: true),
      ],
    );
    final status = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: accent,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
    final longAmount = [
      partner.balanceUzs,
      partner.balanceUsd,
    ].any((v) => MoneyFormatter.groupDigits(v).length > 14);
    return AppCard(
      onTap: partner.isDeleted ? null : onTap,
      hasShadow: false,
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      color: Theme.of(context).brightness == Brightness.dark
          ? colors.surfaceSecondary
          : colors.surface,
      border: Border.all(color: colors.border.withValues(alpha: .65)),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked =
                  constraints.maxWidth < 325 ||
                  longAmount ||
                  MediaQuery.textScalerOf(context).scale(14) > 19;
              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(child: identity),
                        SizedBox(width: 44, height: 44, child: menu),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          status,
                          const SizedBox(width: 12),
                          Expanded(child: amounts),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(flex: 6, child: identity),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [amounts, const SizedBox(height: 4), status],
                    ),
                  ),
                  SizedBox(width: 44, height: 44, child: menu),
                ],
              );
            },
          ),
          if (hasInstallments) ...[
            Padding(
              padding: const EdgeInsets.only(top: 9, bottom: 7, right: 8),
              child: Divider(height: 1, color: colors.divider),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked =
                    constraints.maxWidth < 325 ||
                    longAmount ||
                    MediaQuery.textScalerOf(context).scale(14) > 19;
                return Padding(
                  padding: EdgeInsets.only(right: stacked ? 10 : 44),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(AppIcons.calendar, size: 13, color: colors.info),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Bo‘lib to‘lash',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontSize: 10,
                                color: colors.textSecondary,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (partner.installmentRemainingUzs > Decimal.zero)
                              _Amount(
                                amount: partner.installmentRemainingUzs,
                                currency: 1,
                                small: true,
                                color: colors.info,
                              ),
                            if (partner.installmentRemainingUsd > Decimal.zero)
                              _Amount(
                                amount: partner.installmentRemainingUsd,
                                currency: 2,
                                small: true,
                                color: colors.info,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _contact(BuildContext context, String scheme) async {
    final digits = partner.phone.replaceAll(RegExp(r'[^0-9]'), '');
    final phone = digits.length == 9 ? '998$digits' : digits;
    final opened =
        phone.isNotEmpty &&
        await launchUrl(Uri(scheme: scheme, path: '+$phone'));
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telefon ilovasini ochib bo‘lmadi')),
      );
    }
  }
}

class _PartnerMenuAction extends StatelessWidget {
  const _PartnerMenuAction({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Icon(AppIcons.chevronRight, size: 16, color: context.colors.textTertiary),
    ],
  );
}

class _Amount extends StatelessWidget {
  const _Amount({
    required this.amount,
    required this.currency,
    this.signed = false,
    this.small = false,
    this.color,
  });
  final Decimal amount;
  final int currency;
  final bool signed;
  final bool small;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    signed
        ? MoneyFormatter.formatSigned(amount, currencyTypeId: currency)
        : MoneyFormatter.format(amount, currencyTypeId: currency),
    textAlign: TextAlign.right,
    style:
        (small
                ? Theme.of(context).textTheme.labelMedium
                : Theme.of(context).textTheme.labelLarge)
            ?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -.2,
              color:
                  color ??
                  (signed
                      ? amountColor(context, amount.toDouble())
                      : context.colors.textPrimary),
            ),
  );
}

class _PartnerPaginationSkeleton extends StatelessWidget {
  const _PartnerPaginationSkeleton();

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Mijozlar yuklanmoqda',
    child: Column(
      children: [
        for (var i = 0; i < 2; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == 0 ? 8 : 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  context.colors.surfaceSecondary.withValues(alpha: .55),
                  context.colors.surface,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.borderSubtle),
              ),
              child: const Row(
                children: [
                  AppSkeletonBox(
                    width: 36,
                    height: 36,
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FractionallySizedBox(
                          widthFactor: .75,
                          child: AppSkeletonBox(height: 14),
                        ),
                        SizedBox(height: 7),
                        FractionallySizedBox(
                          widthFactor: .95,
                          child: AppSkeletonBox(height: 10),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AppSkeletonBox(height: 14),
                        SizedBox(height: 7),
                        FractionallySizedBox(
                          widthFactor: .45,
                          child: AppSkeletonBox(height: 10),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 22),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
