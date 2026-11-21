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
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../../../core/widgets/inputs/app_search_field.dart';
import '../../../../core/widgets/lists/app_paged_list_view.dart';
import '../../../../core/utils/formatters/money_formatter.dart';
import '../../data/partner_models.dart';
import '../../data/partners_repository.dart';
import '../cubit/partners_cubit.dart';
import '../widgets/export_excel_helper.dart';
import '../widgets/partner_filter_sort_sheets.dart';
import '../../../../core/icons/app_icons.dart';

part '../widgets/partner_list_card.dart';

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
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<PartnersCubit, PagedListState<Partner>>(
          builder: (context, state) {
            final cubit = context.read<PartnersCubit>();
            final narrowed = cubit.search.isNotEmpty || cubit.hasActiveFilter;
            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  primary: false,
                  backgroundColor: colors.background,
                  toolbarHeight: 78,
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
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -.7,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Mijozlaringiz va hisob-kitoblar',
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
                            icon: const Icon(AppIcons.add, size: 24),
                          ),
                        ),
                      ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 2, 20, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppSearchField(
                            onChanged: cubit.updateSearch,
                            hint: 'Ism yoki telefon',
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
                            minimumSize: const Size(44, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => downloadAndShareExcel(
                            context,
                            download: () => getIt<PartnersRepository>()
                                .exportPartnersExcel(),
                            fileName: 'mijozlar.xlsx',
                          ),
                          icon: const Icon(AppIcons.download, size: 22),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          tooltip: 'Saralash: ${_sortLabel(cubit.sort)}',
                          style: IconButton.styleFrom(
                            backgroundColor: colors.surfaceSecondary,
                            minimumSize: const Size(44, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
                            child: const Icon(AppIcons.tune, size: 22),
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
                      color: colors.background,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SizedBox(
                          height:
                              MediaQuery.textScalerOf(context).scale(14) + 34,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                          ? AppIcons.partners
                                          : AppIcons.dot,
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
                                  alpha: 1,
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
                                  borderRadius: BorderRadius.circular(12),
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
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: AppPagedListView<Partner>(
                    loadingMore: const _PartnerPaginationSkeleton(),
                    state: state,
                    padding: const EdgeInsets.fromLTRB(20, 2, 20, 110),
                    onLoadMore: cubit.loadMore,
                    onRefresh: cubit.refresh,
                    onRetry: cubit.loadFirst,
                    emptyIcon: narrowed ? AppIcons.search : AppIcons.partners,
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
