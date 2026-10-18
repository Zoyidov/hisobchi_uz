import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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
      backgroundColor: colors.surface,
      body: SafeArea(
        child: BlocBuilder<PartnersCubit, PagedListState<Partner>>(
          builder: (context, state) {
            final cubit = context.read<PartnersCubit>();
            final narrowed = cubit.search.isNotEmpty || cubit.hasActiveFilter;
            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  primary: false,
                  backgroundColor: colors.surface,
                  toolbarHeight: 94,
                  automaticallyImplyLeading: false,
                  titleSpacing: 20,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  surfaceTintColor: Colors.transparent,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mijozlar',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.8,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Jami mijozlaringiz ro‘yxati',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    if (canCreate)
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Center(
                          child: IconButton.filled(
                            tooltip: 'Yangi mijoz qo‘shish',
                            style: IconButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: Colors.white,
                              fixedSize: const Size(44, 44),
                              padding: const EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _create(context),
                            icon: const Icon(Icons.add_rounded, size: 24),
                          ),
                        ),
                      ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
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
                          tooltip: 'Excel hisobotni yuklab olish',
                          style: IconButton.styleFrom(
                            backgroundColor: colors.success.withValues(
                              alpha: .1,
                            ),
                            foregroundColor: colors.success,
                            minimumSize: const Size(48, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => downloadAndShareExcel(
                            context,
                            download: () => getIt<PartnersRepository>()
                                .exportPartnersExcel(),
                            fileName: 'mijozlar.xlsx',
                          ),
                          icon: const Icon(
                            Icons.file_download_outlined,
                            size: 22,
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
                            child: const Icon(Icons.tune_rounded, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PartnerFilterHeader(
                    height: MediaQuery.textScalerOf(context).scale(14) + 42,
                    child: ColoredBox(
                      color: colors.surface,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SizedBox(
                          height:
                              MediaQuery.textScalerOf(context).scale(14) + 34,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: PartnerStatusFilter.values.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final filter = PartnerStatusFilter.values[index];
                              final selected = cubit.status == filter;
                              return ChoiceChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      filter == PartnerStatusFilter.all
                                          ? Icons.people_outline_rounded
                                          : Icons.circle,
                                      size: filter == PartnerStatusFilter.all
                                          ? 17
                                          : 8,
                                      color: selected
                                          ? Colors.white
                                          : filter ==
                                                PartnerStatusFilter.creditor
                                          ? colors.success
                                          : colors.error,
                                    ),
                                    const SizedBox(width: 7),
                                    Text(_filterLabel(filter)),
                                  ],
                                ),
                                selected: selected,
                                showCheckmark: false,
                                selectedColor: colors.primary,
                                backgroundColor: colors.surface.withValues(
                                  alpha: .9,
                                ),
                                side: BorderSide(
                                  color: selected
                                      ? colors.primary.withValues(alpha: .25)
                                      : colors.border,
                                ),
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: selected
                                          ? Colors.white
                                          : colors.textSecondary,
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                onSelected: (_) {
                                  if (!selected) cubit.updateStatus(filter);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 840),
                  child: AppPagedListView<Partner>(
                    state: state,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                    onLoadMore: cubit.loadMore,
                    onRefresh: cubit.refresh,
                    onRetry: cubit.loadFirst,
                    emptyIcon: narrowed
                        ? Icons.search_off_rounded
                        : Icons.people_outline_rounded,
                    emptyTitle: 'Mijozlar topilmadi',
                    emptyDescription: narrowed
                        ? 'Qidiruvni yoki tanlangan filtrni o‘zgartirib ko‘ring.'
                        : 'Hamkor qo‘shib, hisob-kitoblarni yuritishni boshlang.',
                    emptyAction: !narrowed && canCreate
                        ? 'Hamkor qo‘shish'
                        : null,
                    onEmptyAction: !narrowed && canCreate
                        ? () => _create(context)
                        : null,
                    itemBuilder: (context, partner, index) => _PartnerListCard(
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
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PartnerFilterHeader extends SliverPersistentHeaderDelegate {
  _PartnerFilterHeader({required this.height, required this.child});
  final double height;
  final Widget child;

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => child;
  @override
  bool shouldRebuild(covariant _PartnerFilterHeader oldDelegate) =>
      oldDelegate.height != height || oldDelegate.child != child;
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
            PartnerBalanceStatus.creditor => ('Faol', colors.success),
            PartnerBalanceStatus.debtor => ('Qarzdor', colors.error),
            PartnerBalanceStatus.closed => ('Yopiq', colors.textSecondary),
          };
    final hasBalance =
        partner.balanceUzs != Decimal.zero ||
        partner.balanceUsd != Decimal.zero;
    final hasInstallments =
        partner.installmentRemainingUzs > Decimal.zero ||
        partner.installmentRemainingUsd > Decimal.zero;
    return Stack(
      children: [
        AppCard(
          onTap: partner.isDeleted ? null : onTap,
          hasShadow: false,
          padding: const EdgeInsets.fromLTRB(10, 10, 2, 10),
          color: Color.alphaBlend(
            colors.surfaceSecondary.withValues(alpha: .55),
            colors.surface,
          ),
          border: Border.all(color: colors.borderSubtle),
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              AppAvatar(name: partner.name, size: 36),
              const SizedBox(width: 9),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      PhoneFormatter.toDisplay(partner.phone),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!hasBalance)
                      _Amount(
                        amount: Decimal.zero,
                        currency: partner.mainCurrencyTypeId,
                      ),
                    if (partner.balanceUzs != Decimal.zero)
                      _Amount(
                        amount: partner.balanceUzs,
                        currency: 1,
                        signed: true,
                      ),
                    if (partner.balanceUsd != Decimal.zero)
                      _Amount(
                        amount: partner.balanceUsd,
                        currency: 2,
                        signed: true,
                      ),
                    const SizedBox(height: 3),
                    Text(
                      '● $label',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: accent,
                        fontSize: 10,
                      ),
                    ),
                    if (hasInstallments) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Bo‘lib to‘lash',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.info,
                          fontSize: 10,
                        ),
                      ),
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
                  ],
                ),
              ),
              if (!partner.isDeleted)
                PopupMenuButton<String>(
                  tooltip: 'Mijoz amallari',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 224,
                    maxWidth: 280,
                  ),
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
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 19,
                    color: colors.textTertiary,
                  ),
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
                        icon: Icons.call_rounded,
                        label: 'Qo‘ng‘iroq qilish',
                        color: colors.success,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'sms',
                      height: 52,
                      child: _PartnerMenuAction(
                        icon: Icons.sms_rounded,
                        label: 'SMS yozish',
                        color: colors.info,
                      ),
                    ),
                    const PopupMenuDivider(height: 10),
                    PopupMenuItem(
                      value: 'detail',
                      height: 52,
                      child: _PartnerMenuAction(
                        icon: Icons.person_outline_rounded,
                        label: 'Tafsilotlarni ochish',
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          top: 12,
          bottom: 12,
          width: 3,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
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
      Icon(
        Icons.chevron_right_rounded,
        size: 16,
        color: context.colors.textTertiary,
      ),
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
