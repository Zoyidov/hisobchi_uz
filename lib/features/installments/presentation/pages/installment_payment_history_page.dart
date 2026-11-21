import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/sheets/app_confirmation_sheet.dart';
import '../../../../core/widgets/states/app_empty_state.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../../../core/widgets/typography/money_text.dart';
import '../../data/installment_models.dart';
import '../../data/installments_repository.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/localization/app_localization_extension.dart';

/// To'lovlar tarixi — faqat oxirgi bekor qilinmagan to'lov bekor qilinadi
/// (MOBILE_APP_TZ.md 9.7).
class InstallmentPaymentHistoryPage extends StatefulWidget {
  const InstallmentPaymentHistoryPage({
    super.key,
    required this.planId,
    required this.currencyTypeId,
  });

  final int planId;
  final int currencyTypeId;

  @override
  State<InstallmentPaymentHistoryPage> createState() =>
      _InstallmentPaymentHistoryPageState();
}

class _InstallmentPaymentHistoryPageState
    extends State<InstallmentPaymentHistoryPage> {
  List<InstallmentPaymentRecord>? _payments;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _payments = null;
      _error = null;
    });
    final result = await getIt<InstallmentsRepository>().getPaymentHistory(
      widget.planId,
    );
    if (!mounted) return;
    result.when(
      success: (list) => setState(() => _payments = list),
      failure: (f) => setState(() => _error = f.message),
    );
  }

  int get _lastActiveIndex {
    if (_payments == null) return -1;
    for (var i = 0; i < _payments!.length; i++) {
      if (!_payments![i].isCancelled) return i;
    }
    return -1;
  }

  Future<void> _cancelPayment(int paymentId) async {
    final confirmed = await showAppConfirmationSheet(
      context,
      title: context.l10n.installmentCancelPayment,
      description: context.l10n.commonIrreversible,
    );
    if (!confirmed || !mounted) return;
    final result = await getIt<InstallmentsRepository>().cancelPayment(
      widget.planId,
      paymentId,
    );
    if (!mounted) return;
    result.when(
      success: (_) {
        AppSnackbar.success(context, context.l10n.commonSaved);
        _load();
      },
      failure: (f) => AppSnackbar.error(context, f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.installmentPaymentHistory)),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_error != null) {
      return AppErrorState(
        title: context.l10n.errorLoadShort,
        description: _error,
        onRetry: _load,
      );
    }
    if (_payments == null) return const AppSkeletonList();
    if (_payments!.isEmpty) {
      return AppEmptyState(
        title: context.l10n.installmentNoPayments,
        icon: AppIcons.receipt,
      );
    }

    final colors = context.colors;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _payments!.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          final payment = _payments![i];
          return AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Opacity(
                        opacity: payment.isCancelled ? 0.5 : 1,
                        child: MoneyText(
                          payment.amount,
                          currencyTypeId: widget.currencyTypeId,
                          signed: true,
                          colorOverride: colors.success,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      if (payment.createdAt != null)
                        Text(
                          AppDateFormatter.displayDateTime(payment.createdAt!),
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      if (payment.note != null && payment.note!.isNotEmpty)
                        Text(
                          payment.note!,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      Text(
                        context.l10n.installmentReceivedBy(
                          payment.receivedByName,
                        ),
                        style: TextStyle(
                          color: colors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                      if (payment.isCancelled)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            context.l10n.commonCancelled,
                            style: TextStyle(color: colors.error, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
                if (i == _lastActiveIndex)
                  AppButton.text(
                    label: context.l10n.commonCancel,
                    onPressed: () => _cancelPayment(payment.id),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
