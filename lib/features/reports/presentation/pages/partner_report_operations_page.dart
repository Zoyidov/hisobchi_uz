import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/paged_result.dart';
import '../../../../core/paging/paged_list_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/formatters/phone_formatter.dart';
import '../../../../core/utils/formatters/money_formatter.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/lists/app_paged_list_view.dart';
import '../../data/partner_operation_models.dart';
import 'partner_detail_report_page.dart';

class _OperationsCubit extends PagedListCubit<PartnerOperation> {
  _OperationsCubit(this.fetcher);
  final Future<ApiResult<SimplePage<PartnerOperation>>> Function(int) fetcher;
  @override
  Future<ApiResult<SimplePage<PartnerOperation>>> fetchPage(int page) =>
      fetcher(page);
}

class PartnerReportOperationsPage extends StatelessWidget {
  const PartnerReportOperationsPage({
    super.key,
    required this.title,
    required this.currencyTypeId,
    required this.fetcher,
  });
  final String title;
  final int currencyTypeId;
  final Future<ApiResult<SimplePage<PartnerOperation>>> Function(int) fetcher;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => _OperationsCubit(fetcher)..loadFirst(),
    child: Scaffold(
      appBar: AppBar(title: Text(title)),
      body: BlocBuilder<_OperationsCubit, PagedListState<PartnerOperation>>(
        builder: (context, state) {
          final cubit = context.read<_OperationsCubit>();
          return AppPagedListView<PartnerOperation>(
            state: state,
            onLoadMore: cubit.loadMore,
            onRefresh: cubit.refresh,
            onRetry: cubit.loadFirst,
            emptyIcon: Icons.receipt_long_outlined,
            emptyTitle: 'Operatsiyalar topilmadi',
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, item, index) =>
                _OperationCard(item: item, currencyTypeId: currencyTypeId),
          );
        },
      ),
    ),
  );
}

class _OperationCard extends StatelessWidget {
  const _OperationCard({required this.item, required this.currencyTypeId});
  final PartnerOperation item;
  final int currencyTypeId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final phone = item.partnerPhone?.trim() ?? '';
    final amount = MoneyFormatter.format(
      parseMoney(item.remainingAmount),
      currencyTypeId: currencyTypeId,
    );
    final tint = item.isCredit ? colors.error : colors.success;
    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.partnerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        if (phone.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            PhoneFormatter.toDisplay(PhoneFormatter.toApi(phone)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: colors.textSecondary),
          ),
        ],
      ],
    );
    final balance = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Qolgan',
          style: TextStyle(fontSize: 10, color: colors.textSecondary),
        ),
        const SizedBox(height: 3),
        Text(
          amount,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: tint,
          ),
        ),
      ],
    );
    return AppCard(
      hasShadow: false,
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(16),
      onTap: item.partnerId <= 0
          ? null
          : () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PartnerDetailReportPage(
                  partnerId: item.partnerId,
                  partnerName: item.partnerName,
                ),
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked =
                  constraints.maxWidth < 290 ||
                  amount.length > 18 ||
                  MediaQuery.textScalerOf(context).scale(14) > 19;
              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [identity, const SizedBox(height: 8), balance],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: identity),
                  const SizedBox(width: 12),
                  Expanded(child: balance),
                ],
              );
            },
          ),
          if (item.description?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              item.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
          ],
          const SizedBox(height: 9),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.isCredit
                          ? Icons.north_east_rounded
                          : Icons.south_west_rounded,
                      size: 12,
                      color: tint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.isCredit ? 'Chiqim' : 'Kirim',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: tint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.calendar_today_outlined,
                size: 12,
                color: colors.textTertiary,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  item.dueDate ?? item.createdAt,
                  style: TextStyle(fontSize: 10, color: colors.textSecondary),
                ),
              ),
              if (item.partnerId > 0)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: colors.textTertiary,
                ),
            ],
          ),
          if (item.scheduledAmount != null || item.paidAmount != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 14,
              runSpacing: 4,
              children: [
                if (item.scheduledAmount != null)
                  Text(
                    'Summa: ${MoneyFormatter.format(parseMoney(item.scheduledAmount), currencyTypeId: currencyTypeId)}',
                    style: TextStyle(fontSize: 10, color: colors.textSecondary),
                  ),
                if (item.paidAmount != null)
                  Text(
                    'To‘langan: ${MoneyFormatter.format(parseMoney(item.paidAmount), currencyTypeId: currencyTypeId)}',
                    style: TextStyle(fontSize: 10, color: colors.success),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
