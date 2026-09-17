import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/injector.dart';
import '../../../core/events/data_refresh_bus.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/paged_result.dart';
import '../../../core/paging/paged_list_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../core/widgets/chips/app_status_chip.dart';
import '../../../core/widgets/lists/app_paged_list_view.dart';
import '../../../core/widgets/typography/money_text.dart';
import '../../partners/presentation/pages/wallet_form_page.dart';
import '../data/dashboard_models.dart';
import '../data/dashboard_repository.dart';

class PartnerDueDatesCubit extends PagedListCubit<PartnerDueItem> {
  PartnerDueDatesCubit(this._repository, this.type) {
    _refreshSub = getIt<DataRefreshBus>().events.listen((event) {
      if (event is WalletsChangedEvent || event is PartnersChangedEvent) {
        refresh();
      }
    });
  }

  final DashboardRepository _repository;
  final DueDateType type;
  StreamSubscription<DataChangeEvent>? _refreshSub;

  @override
  Future<void> close() {
    _refreshSub?.cancel();
    return super.close();
  }

  @override
  Future<ApiResult<SimplePage<PartnerDueItem>>> fetchPage(int page) =>
      _repository.getPartnerDueDates(type, page: page);
}

class InstallmentDueDatesCubit extends PagedListCubit<InstallmentDueItem> {
  InstallmentDueDatesCubit(this._repository, this.type) {
    _refreshSub = getIt<DataRefreshBus>().events.listen((event) {
      if (event is InstallmentsChangedEvent || event is WalletsChangedEvent) {
        refresh();
      }
    });
  }

  final DashboardRepository _repository;
  final DueDateType type;
  StreamSubscription<DataChangeEvent>? _refreshSub;

  @override
  Future<void> close() {
    _refreshSub?.cancel();
    return super.close();
  }

  @override
  Future<ApiResult<SimplePage<InstallmentDueItem>>> fetchPage(int page) =>
      _repository.getInstallmentDueDates(type, page: page);
}

String _titleFor(DueDateType type) => switch (type) {
      DueDateType.qarzExpired => 'Muddati o\'tgan qarzlar',
      DueDateType.qarzToday => 'Bugun muddati',
      DueDateType.qarz3Days => '3 kun ichida',
      DueDateType.installmentExpired => 'Muddati o\'tgan (bo\'lib to\'lash)',
      DueDateType.installmentToday => 'Bugun (bo\'lib to\'lash)',
      DueDateType.installment3Days => '3 kun ichida (bo\'lib to\'lash)',
    };

/// Dashboard kartasi bosilganda ochiladigan detal ro'yxat (MOBILE_APP_TZ.md 7.2).
class DueDatesPage extends StatelessWidget {
  const DueDatesPage({super.key, required this.type});

  final DueDateType type;

  @override
  Widget build(BuildContext context) {
    if (type.isInstallment) {
      return BlocProvider(
        create: (_) => InstallmentDueDatesCubit(getIt<DashboardRepository>(), type)..loadFirst(),
        child: _InstallmentDueView(type: type),
      );
    }
    return BlocProvider(
      create: (_) => PartnerDueDatesCubit(getIt<DashboardRepository>(), type)..loadFirst(),
      child: _PartnerDueView(type: type),
    );
  }
}

class _PartnerDueView extends StatelessWidget {
  const _PartnerDueView({required this.type});
  final DueDateType type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titleFor(type))),
      body: BlocBuilder<PartnerDueDatesCubit, PagedListState<PartnerDueItem>>(
        builder: (context, state) {
          final cubit = context.read<PartnerDueDatesCubit>();
          return AppPagedListView<PartnerDueItem>(
            state: state,
            onLoadMore: cubit.loadMore,
            onRefresh: cubit.refresh,
            onRetry: cubit.loadFirst,
            emptyIcon: Icons.check_circle_outline_rounded,
            emptyTitle: 'Bu bo\'limda ma\'lumot yo\'q',
            itemBuilder: (context, item, index) => AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.partnerName, style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 4),
                        MoneyText(item.remainingAmount, currencyTypeId: item.currencyTypeId, size: MoneySize.list),
                        const SizedBox(height: 4),
                        AppStatusChip(
                          label: item.status,
                          tone: (item.daysOverdue ?? 0) > 0 ? AppStatusChipTone.error : AppStatusChipTone.warning,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.call_rounded, color: context.colors.primary),
                        onPressed: () => launchUrl(Uri.parse('tel:${item.partnerPhone}')),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline_rounded, color: context.colors.success),
                        onPressed: () async {
                          final res = await showWalletFormSheet(context, type: 'debt', partnerId: item.partnerId);
                          if (res != null && context.mounted) {
                            context.read<PartnerDueDatesCubit>().refresh();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InstallmentDueView extends StatelessWidget {
  const _InstallmentDueView({required this.type});
  final DueDateType type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titleFor(type))),
      body: BlocBuilder<InstallmentDueDatesCubit, PagedListState<InstallmentDueItem>>(
        builder: (context, state) {
          final cubit = context.read<InstallmentDueDatesCubit>();
          return AppPagedListView<InstallmentDueItem>(
            state: state,
            onLoadMore: cubit.loadMore,
            onRefresh: cubit.refresh,
            onRetry: cubit.loadFirst,
            emptyIcon: Icons.check_circle_outline_rounded,
            emptyTitle: 'Bu bo\'limda ma\'lumot yo\'q',
            itemBuilder: (context, item, index) => AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.partnerName, style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 4),
                        MoneyText(item.remaining, size: MoneySize.list),
                        const SizedBox(height: 4),
                        AppStatusChip(
                          label: item.statusLabel,
                          tone: (item.daysOverdue ?? 0) > 0 ? AppStatusChipTone.error : AppStatusChipTone.warning,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.call_rounded, color: context.colors.primary),
                    onPressed: () => launchUrl(Uri.parse('tel:${item.partnerPhone}')),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
