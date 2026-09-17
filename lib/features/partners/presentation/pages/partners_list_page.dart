import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_permission.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/paging/paged_list_cubit.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/inputs/app_search_field.dart';
import '../../../../core/widgets/lists/app_paged_list_view.dart';
import '../../../../core/widgets/navigation/permission_guard.dart';
import '../../data/partner_models.dart';
import '../../data/partners_repository.dart';
import '../cubit/partners_cubit.dart';
import '../widgets/export_excel_helper.dart';
import '../widgets/partner_card.dart';
import '../widgets/partner_filter_sort_sheets.dart';

/// Hamkorlar ro'yxati — ilovaning asosiy ekrani (MOBILE_APP_TZ.md 8.2).
class PartnersListPage extends StatelessWidget {
  const PartnersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PartnersCubit(getIt<PartnersRepository>())..loadFirst(),
      child: const _PartnersListView(),
    );
  }
}

class _PartnersListView extends StatelessWidget {
  const _PartnersListView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<PartnersCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hamkorlar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () => downloadAndShareExcel(
              context,
              download: () => getIt<PartnersRepository>().exportPartnersExcel(),
              fileName: 'hamkorlar.xlsx',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
            child: Row(
              children: [
                Expanded(child: AppSearchField(onChanged: cubit.updateSearch, hint: 'Ism, telefon bo\'yicha qidirish')),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      final selected = await showPartnerFilterSheet(context, cubit.status);
                      if (selected != null) cubit.updateStatus(selected);
                    },
                    icon: Badge(
                      isLabelVisible: cubit.hasActiveFilter,
                      smallSize: 8,
                      child: const Icon(Icons.filter_list_rounded, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      final selected = await showPartnerSortSheet(context, cubit.sort);
                      if (selected != null) cubit.updateSort(selected);
                    },
                    icon: const Icon(Icons.sort_rounded, size: 20),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<PartnersCubit, PagedListState<Partner>>(
              builder: (context, state) {
                return AppPagedListView<Partner>(
                  state: state,
                  onLoadMore: cubit.loadMore,
                  onRefresh: cubit.refresh,
                  onRetry: cubit.loadFirst,
                  emptyIcon: Icons.people_outline_rounded,
                  emptyTitle: 'Hamkorlar topilmadi',
                  emptyDescription: 'Hozircha bu bo\'limda ma\'lumot yo\'q.',
                  emptyAction: 'Hamkor qo\'shish',
                  onEmptyAction: () => context.push(RoutePaths.partnerCreate),
                  itemBuilder: (context, partner, index) => PartnerCard(
                    partner: partner,
                    onTap: () => context.push(RoutePaths.partnerDetail(partner.id)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: PermissionGuard(
        permission: AppPermission.partnersCreate,
        child: FloatingActionButton.extended(
          onPressed: () => context.push(RoutePaths.partnerCreate),
          icon: const Icon(Icons.add),
          label: const Text('Hamkor qo\'shish'),
        ),
      ),
    );
  }
}
