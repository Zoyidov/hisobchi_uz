import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/inputs/app_money_field.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../../../../core/widgets/typography/money_text.dart';
import '../../data/installment_models.dart';
import '../../data/installment_scheduler.dart';
import '../../data/installments_repository.dart';

/// To'lov qabul qilish — FIFO preview bilan (MOBILE_APP_TZ.md 9.6).
Future<InstallmentPlan?> showInstallmentPaymentSheet(BuildContext context, InstallmentPlan plan) {
  return showAppBottomSheet<InstallmentPlan>(
    context,
    title: 'To\'lov qabul qilish',
    heightFactor: 0.75,
    child: _PaymentForm(plan: plan),
  );
}

class _PaymentForm extends StatefulWidget {
  const _PaymentForm({required this.plan});
  final InstallmentPlan plan;

  @override
  State<_PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<_PaymentForm> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _paidAt = DateTime.now();
  bool _submitting = false;
  String? _error;

  Decimal get _amount => Decimal.tryParse(_amountController.text.isEmpty ? '0' : _amountController.text) ?? Decimal.zero;

  void _quickFillNextItem() {
    final unpaid = widget.plan.items.where((i) => i.status != InstallmentItemStatus.paid).toList()
      ..sort((a, b) => (a.dueDate ?? DateTime(2100)).compareTo(b.dueDate ?? DateTime(2100)));
    if (unpaid.isEmpty) return;
    _amountController.text = unpaid.first.remaining.toBigInt().toString();
    setState(() {});
  }

  void _quickFillAll() {
    _amountController.text = widget.plan.remaining.toBigInt().toString();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final preview = InstallmentScheduler.previewFifoAllocation(widget.plan.items, _amount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Qolgan:', style: TextStyle(color: colors.textSecondary)),
          MoneyText(widget.plan.remaining, currencyTypeId: widget.plan.currencyTypeId, size: MoneySize.card),
          const SizedBox(height: AppSpacing.md),
          AppMoneyField(
            controller: _amountController,
            currencyLabel: widget.plan.currencyTypeName,
            errorText: _error,
            autofocus: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              ActionChip(label: const Text('Keyingi qism'), onPressed: _quickFillNextItem),
              ActionChip(label: const Text('Barcha qolgan qarz'), onPressed: _quickFillAll),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(controller: _noteController, label: 'Izoh', hint: 'Naqd'),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _paidAt,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _paidAt = picked);
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Sana'),
              child: Text(AppDateFormatter.display(_paidAt)),
            ),
          ),
          if (preview.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(color: colors.info.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ushbu to\'lov:', style: TextStyle(color: colors.info, fontWeight: FontWeight.w600)),
                  for (final line in preview) Text('· $line', style: TextStyle(color: colors.info)),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton.primary(
            label: 'To\'lovni qabul qilish',
            isLoading: _submitting,
            onPressed: () async {
              if (_amount <= Decimal.zero) {
                setState(() => _error = 'Summa 0 dan katta bo\'lishi kerak');
                return;
              }
              if (_amount > widget.plan.remaining) {
                setState(() => _error = 'To\'lov summasi qolgan qarzdan oshib ketmasligi kerak.');
                return;
              }
              setState(() {
                _submitting = true;
                _error = null;
              });
              final result = await getIt<InstallmentsRepository>().makePayment(
                widget.plan.id,
                amount: _amount,
                note: _noteController.text,
                paidAt: _paidAt,
              );
              if (!mounted) return;
              result.when(
                success: (plan) => Navigator.of(context).pop(plan),
                failure: (f) => setState(() {
                  _submitting = false;
                  _error = f.message;
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
