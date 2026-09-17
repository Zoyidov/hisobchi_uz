import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/paged_result.dart';
import '../../../../core/paging/paged_list_cubit.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/lists/app_paged_list_view.dart';
import '../../../../core/widgets/typography/money_text.dart';
import '../../data/partner_report_models.dart';

class _DetailCubit extends PagedListCubit<PartnerReportDetailItem> {
  _DetailCubit(this._fetcher);

  final Future<ApiResult<SimplePage<PartnerReportDetailItem>>> Function(int page) _fetcher;

  @override
  Future<ApiResult<SimplePage<PartnerReportDetailItem>>> fetchPage(int page) => _fetcher(page);
}

/// KPI karta bosilganda ochiladigan umumiy hisobot detali
/// (MOBILE_APP_TZ.md 12.1: "Detal: simplePaginate: hamkorlar ro'yxati balans bilan").
class ReportDetailListPage extends StatelessWidget {
  const ReportDetailListPage({
    super.key,
    required this.title,
    required this.fetcher,
    required this.currencyTypeId,
  });

  final String title;
  final Future<ApiResult<SimplePage<PartnerReportDetailItem>>> Function(int page) fetcher;
  final int currencyTypeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _DetailCubit(fetcher)..loadFirst(),
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: BlocBuilder<_DetailCubit, PagedListState<PartnerReportDetailItem>>(
          builder: (context, state) {
            final cubit = context.read<_DetailCubit>();
            return AppPagedListView<PartnerReportDetailItem>(
              state: state,
              onLoadMore: cubit.loadMore,
              onRefresh: cubit.refresh,
              onRetry: cubit.loadFirst,
              emptyIcon: Icons.people_outline_rounded,
              emptyTitle: 'Ma\'lumot topilmadi',
              padding: const EdgeInsets.all(AppSpacing.md),
              itemBuilder: (context, item, index) => AppCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(item.partnerName)),
                    MoneyText(item.balance, currencyTypeId: currencyTypeId, signed: true),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
