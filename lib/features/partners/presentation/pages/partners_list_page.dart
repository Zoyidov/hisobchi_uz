import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_permission.dart';
import '../../../../core/cubits/owner_context_cubit.dart';
import '../../../../core/cubits/user_cubit.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/paging/paged_list_cubit.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters/phone_formatter.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/inputs/app_search_field.dart';
import '../../../../core/widgets/lists/app_paged_list_view.dart';
import '../../../../core/widgets/media/app_avatar.dart';
import '../../../../core/utils/formatters/money_formatter.dart';
import '../../data/partner_models.dart';
import '../../data/partners_repository.dart';
import '../cubit/partners_cubit.dart';
import '../widgets/export_excel_helper.dart';
import '../widgets/partner_filter_sort_sheets.dart';

class PartnersListPage extends StatelessWidget {
  const PartnersListPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => PartnersCubit(getIt<PartnersRepository>())..loadFirst(),
    child: const _PartnersListView(),
  );
}

class _PartnersListView extends StatelessWidget {
  const _PartnersListView();

  Future<void> _create(BuildContext context) async {
    await context.push(RoutePaths.partnerCreate);
    if (context.mounted) await context.read<PartnersCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserCubit>().currentUserOrNull;
    final owner = context.watch<OwnerContextCubit>().state;
    final canCreate =
        user?.hasPermission(AppPermission.partnersCreate, owner) ?? false;
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Hamkorlar',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, size: 22),
            tooltip: 'Excel yuklash',
            onPressed: () => downloadAndShareExcel(
              context,
              download: () => getIt<PartnersRepository>().exportPartnersExcel(),
              fileName: 'hamkorlar.xlsx',
            ),
          ),
          if (canCreate)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton.filled(
                tooltip: 'Hamkor qo‘shish',
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => _create(context),
                icon: const Icon(Icons.add_rounded),
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: BlocBuilder<PartnersCubit, PagedListState<Partner>>(
            builder: (context, state) {
              final cubit = context.read<PartnersCubit>();
              final narrowed = cubit.search.isNotEmpty || cubit.hasActiveFilter;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppSearchField(
                            onChanged: cubit.updateSearch,
                            hint: 'Ism yoki telefon orqali qidirish',
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          tooltip: 'Saralash: ${_sortLabel(cubit.sort)}',
                          style: IconButton.styleFrom(
                            backgroundColor: colors.surfaceSecondary,
                            minimumSize: const Size(48, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {
                            final selected = await showPartnerSortSheet(
                              context,
                              cubit.sort,
                            );
                            if (selected != null && context.mounted) {
                              cubit.updateSort(selected);
                            }
                          },
                          icon: Badge(
                            isLabelVisible:
                                cubit.sort != PartnerSort.lastActivity,
                            smallSize: 7,
                            child: const Icon(
                              Icons.swap_vert_rounded,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.textScalerOf(context).scale(14) + 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: PartnerStatusFilter.values.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final filter = PartnerStatusFilter.values[index];
                        final selected = cubit.status == filter;
                        return ChoiceChip(
                          label: Text(_filterLabel(filter)),
                          selected: selected,
                          showCheckmark: false,
                          selectedColor: colors.primaryContainer,
                          backgroundColor: colors.surface,
                          side: BorderSide(
                            color: selected
                                ? colors.primary.withValues(alpha: .25)
                                : colors.border,
                          ),
                          labelStyle: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: selected
                                    ? colors.primary
                                    : colors.textSecondary,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (_) {
                            if (!selected) cubit.updateStatus(filter);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: AppPagedListView<Partner>(
                      state: state,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                      onLoadMore: cubit.loadMore,
                      onRefresh: cubit.refresh,
                      onRetry: cubit.loadFirst,
                      emptyIcon: narrowed
                          ? Icons.search_off_rounded
                          : Icons.people_outline_rounded,
                      emptyTitle: 'Hamkorlar topilmadi',
                      emptyDescription: narrowed
                          ? 'Qidiruvni yoki tanlangan filtrni o‘zgartirib ko‘ring.'
                          : 'Hamkor qo‘shib, hisob-kitoblarni yuritishni boshlang.',
                      emptyAction: !narrowed && canCreate
                          ? 'Hamkor qo‘shish'
                          : null,
                      onEmptyAction: !narrowed && canCreate
                          ? () => _create(context)
                          : null,
                      itemBuilder: (context, partner, index) =>
                          _PartnerListCard(
                            key: ValueKey(partner.id),
                            partner: partner,
                            onTap: () async {
                              await context.push(
                                RoutePaths.partnerDetail(partner.id),
                              );
                              if (context.mounted) await cubit.refresh();
                            },
                          ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

String _filterLabel(PartnerStatusFilter filter) => switch (filter) {
  PartnerStatusFilter.all => 'Barchasi',
  PartnerStatusFilter.creditor => 'Haqdorlar',
  PartnerStatusFilter.debtor => 'Qarzdorlar',
  PartnerStatusFilter.overdueDebtor => 'Muddati o‘tgan',
};

String _sortLabel(PartnerSort sort) => switch (sort) {
  PartnerSort.lastActivity => 'Oxirgi faollik',
  PartnerSort.debtorUzs => 'Qarzdor · UZS',
  PartnerSort.debtorUsd => 'Qarzdor · USD',
  PartnerSort.creditorUzs => 'Haqdor · UZS',
  PartnerSort.creditorUsd => 'Haqdor · USD',
};

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
    return AppCard(
      onTap: partner.isDeleted ? null : onTap,
      hasShadow: false,
      padding: const EdgeInsets.all(14),
      border: Border.all(color: colors.borderSubtle),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final showAvatar =
                  constraints.maxWidth >= 310 &&
                  MediaQuery.textScalerOf(context).scale(14) < 22;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showAvatar) ...[
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Opacity(
                        opacity: partner.isDeleted ? .5 : 1,
                        child: AppAvatar(name: partner.name, size: 38),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          partner.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -.2,
                                color: partner.isDeleted
                                    ? colors.textTertiary
                                    : colors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          PhoneFormatter.toDisplay(partner.phone),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: constraints.maxWidth * (showAvatar ? .44 : .48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!partner.isDeleted && hasBalance) ...[
                          if (partner.balanceUzs != Decimal.zero)
                            _Amount(
                              amount: partner.balanceUzs,
                              currency: 1,
                              signed: true,
                            ),
                          if (partner.balanceUzs != Decimal.zero &&
                              partner.balanceUsd != Decimal.zero)
                            const SizedBox(height: 3),
                          if (partner.balanceUsd != Decimal.zero)
                            _Amount(
                              amount: partner.balanceUsd,
                              currency: 2,
                              signed: true,
                            ),
                          const SizedBox(height: 6),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            label,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          if (!partner.isDeleted && hasInstallments) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: colors.divider),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 14,
                  color: colors.textTertiary,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Bo‘lib to‘lash',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (partner.installmentRemainingUzs > Decimal.zero)
                        _Amount(
                          amount: partner.installmentRemainingUzs,
                          currency: 1,
                          color: colors.info,
                          small: true,
                        ),
                      if (partner.installmentRemainingUsd > Decimal.zero)
                        _Amount(
                          amount: partner.installmentRemainingUsd,
                          currency: 2,
                          color: colors.info,
                          small: true,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
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
                : Theme.of(context).textTheme.titleSmall)
            ?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -.2,
              color:
                  color ??
                  (signed
                      ? amountColor(context, amount.toDouble())
                      : context.colors.textPrimary),
            ),
  );
}
