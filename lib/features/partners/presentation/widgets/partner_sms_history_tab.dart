import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/lists/app_paged_list_view.dart';
import '../../data/partner_models.dart';
import '../../data/partners_repository.dart';
import '../../data/sms_models.dart';
import '../cubit/partner_sms_cubit.dart';

/// Tab 3: SMS tarixi (MOBILE_APP_TZ.md 8.9).
class PartnerSmsHistoryTab extends StatelessWidget {
  const PartnerSmsHistoryTab({super.key, required this.partner});

  final Partner partner;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PartnerSmsHistoryCubit(getIt<PartnersRepository>(), partner.id)..loadFirst(),
      child: Builder(
        builder: (context) {
          final cubit = context.watch<PartnerSmsHistoryCubit>();
          return AppPagedListView<SentSms>(
            state: cubit.state,
            onLoadMore: cubit.loadMore,
            onRefresh: cubit.refresh,
            onRetry: cubit.loadFirst,
            emptyIcon: Icons.sms_outlined,
            emptyTitle: 'SMS tarixi bo\'sh',
            itemBuilder: (context, sms, index) => AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    sms.isSuccess ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                    color: sms.isSuccess ? context.colors.success : context.colors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (sms.sentAt != null)
                          Text(AppDateFormatter.displayDateTime(sms.sentAt!),
                              style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(sms.message, maxLines: 3, overflow: TextOverflow.ellipsis),
                      ],
                    ),
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
