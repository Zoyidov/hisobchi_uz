import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_money_field.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/media/app_file_attachment.dart';
import '../../../../core/widgets/misc/app_segmented_control.dart';
import '../../../../core/widgets/typography/money_text.dart';
import '../../../documents/data/currency.dart';
import '../../../partners/data/partner_models.dart';
import '../../data/installment_models.dart';
import '../../data/installments_repository.dart';
import '../cubit/installment_create_cubit.dart';

/// Reja yaratish — 3 qadamli wizard (MOBILE_APP_TZ.md 9.4).
class InstallmentWizardPage extends StatelessWidget {
  const InstallmentWizardPage({super.key, required this.partner});

  final Partner partner;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InstallmentCreateCubit(
        getIt<InstallmentsRepository>(),
        partnerId: partner.id,
        currencyTypeId: partner.mainCurrencyTypeId,
      ),
      child: _WizardView(partner: partner),
    );
  }
}

class _WizardView extends StatelessWidget {
  const _WizardView({required this.partner});
  final Partner partner;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bo\'lib to\'lash rejasi')),
      body: SafeArea(
        child: BlocConsumer<InstallmentCreateCubit, InstallmentCreateState>(
          listener: (context, state) {
            if (state.createdPlan != null) {
              AppSnackbar.success(context, 'Reja yaratildi');
              context.pop(state.createdPlan);
            } else if (state.submitError != null) {
              AppSnackbar.error(context, state.submitError!.message);
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _StepIndicator(step: state.step),
                ),
                Expanded(
                  child: switch (state.step) {
                    0 => _StepOne(partner: partner),
                    1 => const _StepTwo(),
                    _ => const _StepThree(),
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _WizardFooter(state: state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    final labels = ['Asosiy', 'Grafik', 'Tasdiqlash'];
    return Row(
      children: List.generate(3, (i) {
        final active = i <= step;
        return Expanded(
          child: Column(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: active ? context.colors.primary : context.colors.surfaceSecondary,
                child: Text('${i + 1}', style: TextStyle(color: active ? Colors.white : context.colors.textTertiary, fontSize: 12)),
              ),
              const SizedBox(height: 4),
              Text(labels[i], style: TextStyle(fontSize: 11, color: active ? context.colors.textPrimary : context.colors.textTertiary)),
            ],
          ),
        );
      }),
    );
  }
}

class _WizardFooter extends StatelessWidget {
  const _WizardFooter({required this.state});
  final InstallmentCreateState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstallmentCreateCubit>();
    return Row(
      children: [
        if (state.step > 0)
          Expanded(child: AppButton.secondary(label: 'Orqaga', onPressed: cubit.previousStep)),
        if (state.step > 0) const SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 2,
          child: AppButton.primary(
            label: state.step == 2 ? 'Yaratish' : 'Davom etish',
            isLoading: state.isSubmitting,
            onPressed: () {
              if (state.step == 0) {
                if (state.totalAmount == null || state.totalAmount! <= Decimal.zero) {
                  AppSnackbar.error(context, 'Jami summa kiritilishi shart');
                  return;
                }
                cubit.nextStep();
              } else if (state.step == 1) {
                final error = state.step2ValidationError;
                if (error != null) {
                  AppSnackbar.error(context, error);
                  return;
                }
                cubit.nextStep();
              } else {
                cubit.submit();
              }
            },
          ),
        ),
      ],
    );
  }
}

class _StepOne extends StatefulWidget {
  const _StepOne({required this.partner});
  final Partner partner;

  @override
  State<_StepOne> createState() => _StepOneState();
}

class _StepOneState extends State<_StepOne> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstallmentCreateCubit>();
    final state = context.watch<InstallmentCreateCubit>().state;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Hamkor', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: context.colors.surfaceSecondary, borderRadius: AppRadius.mediumRadius),
            child: Text(widget.partner.name),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Valyuta', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          AppSegmentedControl<int>(
            value: state.currencyTypeId,
            segments: const [AppSegment(value: 1, label: 'UZS'), AppSegment(value: 2, label: 'USD')],
            onChanged: cubit.setCurrency,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppMoneyField(
            controller: _amountController,
            currencyLabel: Currency.defaults.firstWhere((c) => c.id == state.currencyTypeId).name,
            onChanged: (digits) => cubit.setTotalAmount(digits.isEmpty ? null : Decimal.parse(digits)),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(controller: _noteController, label: 'Izoh', maxLines: 2, minLines: 1, onChanged: cubit.setNote),
          const SizedBox(height: AppSpacing.md),
          AppFileAttachment(onFilesChanged: (files) => cubit.setFileIds(files.map((f) => f.id).toList())),
        ],
      ),
    );
  }
}

class _StepTwo extends StatelessWidget {
  const _StepTwo();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstallmentCreateCubit>();
    final state = context.watch<InstallmentCreateCubit>().state;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Grafik turi', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          AppSegmentedControl<InstallmentScheduleType>(
            value: state.scheduleType,
            segments: const [
              AppSegment(value: InstallmentScheduleType.equal, label: 'Teng'),
              AppSegment(value: InstallmentScheduleType.custom, label: 'Erkin'),
            ],
            onChanged: cubit.setScheduleType,
          ),
          const SizedBox(height: AppSpacing.lg),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Avans bor'),
            value: state.hasAdvance,
            onChanged: cubit.setHasAdvance,
          ),
          if (state.hasAdvance) ...[
            const SizedBox(height: AppSpacing.sm),
            _AdvanceField(cubit: cubit, state: state),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (state.scheduleType == InstallmentScheduleType.equal) ...[
            Text('Boshlanish sanasi', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: state.startDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (picked != null) cubit.setStartDate(picked);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: context.colors.surfaceSecondary, borderRadius: AppRadius.mediumRadius),
                child: Text(AppDateFormatter.display(state.startDate ?? DateTime.now())),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Qismlar soni', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => cubit.setInstallmentCount(state.installmentCount - 1),
                ),
                Text('${state.installmentCount}', style: Theme.of(context).textTheme.headlineSmall),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => cubit.setInstallmentCount(state.installmentCount + 1),
                ),
              ],
            ),
          ] else
            _CustomItemsEditor(cubit: cubit, state: state),
        ],
      ),
    );
  }
}

class _AdvanceField extends StatefulWidget {
  const _AdvanceField({required this.cubit, required this.state});
  final InstallmentCreateCubit cubit;
  final InstallmentCreateState state;

  @override
  State<_AdvanceField> createState() => _AdvanceFieldState();
}

class _AdvanceFieldState extends State<_AdvanceField> {
  late final _controller = TextEditingController(text: widget.state.advanceAmount?.toBigInt().toString());

  @override
  Widget build(BuildContext context) {
    return AppMoneyField(
      controller: _controller,
      currencyLabel: Currency.defaults.firstWhere((c) => c.id == widget.state.currencyTypeId).name,
      onChanged: (digits) => widget.cubit.setAdvanceAmount(digits.isEmpty ? null : Decimal.parse(digits)),
    );
  }
}

class _CustomItemsEditor extends StatelessWidget {
  const _CustomItemsEditor({required this.cubit, required this.state});
  final InstallmentCreateCubit cubit;
  final InstallmentCreateState state;

  @override
  Widget build(BuildContext context) {
    final items = state.customItems;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(child: Text('${i + 1}) ${items[i].amount.toBigInt()} · ${AppDateFormatter.display(items[i].dueDate)}')),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    final updated = List.of(items)..removeAt(i);
                    cubit.setCustomItems(updated);
                  },
                ),
              ],
            ),
          ),
        AppButton.secondary(
          label: '+ Qism qo\'shish',
          onPressed: () async {
            final amount = await _promptAmount(context);
            if (amount == null) return;
            if (!context.mounted) return;
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 3650)),
            );
            if (date == null) return;
            cubit.setCustomItems([
              ...items,
              InstallmentPreviewItem(itemNumber: items.length + 1, amount: amount, dueDate: date, isAdvance: false),
            ]);
          },
        ),
      ],
    );
  }

  Future<Decimal?> _promptAmount(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<Decimal>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Qism summasi'),
        content: TextField(controller: controller, keyboardType: TextInputType.number, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
          TextButton(
            onPressed: () {
              final value = Decimal.tryParse(controller.text);
              Navigator.pop(context, value);
            },
            child: const Text('Qo\'shish'),
          ),
        ],
      ),
    );
  }
}

class _StepThree extends StatelessWidget {
  const _StepThree();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<InstallmentCreateCubit>().state;
    final preview = state.preview;
    final currencyLabel = Currency.defaults.firstWhere((c) => c.id == state.currencyTypeId).name;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text('To\'lov grafigi', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        for (final item in preview)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.surfaceSecondary,
              borderRadius: AppRadius.mediumRadius,
            ),
            child: Row(
              children: [
                Text('${item.itemNumber}', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: MoneyText(item.amount, currencyLabel: currencyLabel, size: MoneySize.list)),
                Text(AppDateFormatter.display(item.dueDate)),
                if (item.isAdvance) ...[
                  const SizedBox(width: 6),
                  const Text('Avans', style: TextStyle(fontSize: 11)),
                ],
              ],
            ),
          ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Jami', style: Theme.of(context).textTheme.titleMedium),
            MoneyText(state.totalAmount ?? Decimal.zero, currencyLabel: currencyLabel, size: MoneySize.card),
          ],
        ),
      ],
    );
  }
}
