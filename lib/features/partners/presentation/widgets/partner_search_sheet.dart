import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/paging/paged_list_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters/phone_formatter.dart';
import '../../../../core/widgets/lists/app_paged_list_view.dart';
import '../../../../core/widgets/media/app_avatar.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../../data/partner_models.dart';
import '../../data/partners_repository.dart';
import '../cubit/partner_selection_cubit.dart';

Future<Partner?> showPartnerSearchSheet(BuildContext context) =>
    showAppBottomSheet<Partner>(
      context,
      title: 'Hamkorni tanlang',
      heightFactor: 0.85,
      child: BlocProvider(
        create: (_) =>
            PartnerSelectionCubit(getIt<PartnersRepository>())..loadFirst(),
        child: const _PartnerSearchList(),
      ),
    );

class _PartnerSearchList extends StatelessWidget {
  const _PartnerSearchList();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PartnerSelectionCubit>();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: cubit.search,
              decoration: const InputDecoration(
                hintText: 'Ism yoki telefon orqali qidirish',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<PartnerSelectionCubit, PagedListState<Partner>>(
              builder: (context, state) =>
                  NotificationListener<ScrollMetricsNotification>(
                    onNotification: (notification) {
                      // A short first page may not fill the viewport yet.
                      if (notification.metrics.maxScrollExtent <= 0) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (context.mounted &&
                              !cubit.isClosed &&
                              cubit.state.failure == null) {
                            cubit.loadMore();
                          }
                        });
                      }
                      return false;
                    },
                    child: AppPagedListView<Partner>(
                      state: state,
                      onLoadMore: cubit.loadMore,
                      onRefresh: cubit.loadFirst,
                      onRetry: cubit.loadFirst,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      emptyTitle: 'Hamkorlar topilmadi',
                      emptyDescription:
                          'Ism yoki telefonni o‘zgartirib qidiring.',
                      emptyIcon: Icons.search_off_rounded,
                      itemBuilder: (context, partner, index) => ListTile(
                        key: ValueKey(partner.id),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        leading: AppAvatar(name: partner.name, size: 40),
                        title: Text(partner.name),
                        subtitle: Text(
                          PhoneFormatter.toDisplay(partner.phone),
                          style: TextStyle(color: context.colors.textSecondary),
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: context.colors.textTertiary,
                        ),
                        onTap: partner.isDeleted
                            ? null
                            : () => Navigator.of(context).pop(partner),
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
