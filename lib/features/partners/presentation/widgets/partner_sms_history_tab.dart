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
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/localization/app_localization_extension.dart';

/// Tab 3: SMS tarixi (MOBILE_APP_TZ.md 8.9).
class PartnerSmsHistoryTab extends StatefulWidget {
  const PartnerSmsHistoryTab({super.key, required this.partner});

  final Partner partner;

  @override
  State<PartnerSmsHistoryTab> createState() => _PartnerSmsHistoryTabState();
}

class _PartnerSmsHistoryTabState extends State<PartnerSmsHistoryTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (_) =>
          PartnerSmsHistoryCubit(getIt<PartnersRepository>(), widget.partner.id)
            ..loadFirst(),
      child: Builder(
        builder: (context) {
          final cubit = context.watch<PartnerSmsHistoryCubit>();
          return AppPagedListView<SentSms>(
            state: cubit.state,
            onLoadMore: cubit.loadMore,
            onRefresh: cubit.refresh,
            onRetry: cubit.loadFirst,
            emptyIcon: AppIcons.message,
            emptyTitle: context.l10n.partnerSmsHistoryEmpty,
            itemBuilder: (context, sms, index) => AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    sms.isSuccess ? AppIcons.success : AppIcons.error,
                    color: sms.isSuccess
                        ? context.colors.success
                        : context.colors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (sms.sentAt != null)
                          Text(
                            AppDateFormatter.displayDateTime(sms.sentAt!),
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          sms.message,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
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
