import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters/money_formatter.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/media/app_file_attachment.dart';
import '../../../partners/data/partner_models.dart';
import '../../data/installment_models.dart';
import '../../data/installments_repository.dart';
import '../cubit/installment_create_cubit.dart';
import '../widgets/installment_form_widgets.dart';

/// The legacy installment flow, adapted to the application's semantic theme.
class InstallmentWizardPage extends StatelessWidget {
  const InstallmentWizardPage({super.key, required this.partner});
  final Partner partner;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => InstallmentCreateCubit(
      getIt<InstallmentsRepository>(),
      partnerId: partner.id,
      currencyTypeId: partner.mainCurrencyTypeId,
    ),
    child: _WizardView(partner: partner),
  );
}

class _WizardView extends StatelessWidget {
  const _WizardView({required this.partner});
  final Partner partner;

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<InstallmentCreateCubit, InstallmentCreateState>(
        listenWhen: (previous, current) =>
            previous.createdPlan != current.createdPlan ||
            previous.submitError != current.submitError,
        listener: (context, state) {
          if (state.createdPlan != null) {
            AppSnackbar.success(context, 'Reja yaratildi');
            context.pop(state.createdPlan);
          } else if (state.submitError != null) {
            AppSnackbar.error(context, state.submitError!.message);
          }
        },
        builder: (context, state) {
          final cubit = context.read<InstallmentCreateCubit>();
          return PopScope(
            canPop: state.step == 0 && !state.isSubmitting,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop && !state.isSubmitting && state.step > 0) {
                cubit.previousStep();
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  'Muddatli to‘lov',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                leading: IconButton(
                  tooltip: 'Orqaga',
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: state.isSubmitting
                      ? null
                      : () {
                          if (state.step > 0) {
                            cubit.previousStep();
                          } else {
                            context.pop();
                          }
                        },
                ),
              ),
              body: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: IndexedStack(
                            index: state.step,
                            children: [
                              _BasicInfoStep(partner: partner),
                              const _ScheduleTypeStep(),
                              const _DistributionStep(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _WizardFooter(state: state),
                  ],
                ),
              ),
            ),
          );
        },
      );
}

class _StepBody extends StatelessWidget {
  const _StepBody({
    required this.step,
    required this.title,
    required this.children,
  });
  final int step;
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    padding: EdgeInsets.fromLTRB(
      MediaQuery.sizeOf(context).width < 360 ? 16 : 24,
      16,
      MediaQuery.sizeOf(context).width < 360 ? 16 : 24,
      24,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepIndicator(step: step),
        const SizedBox(height: 22),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    ),
  );
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});
  final int step;
  @override
  Widget build(BuildContext context) => Semantics(
    label: '${step + 1}-bosqich, jami 3 bosqich',
    child: Row(
      children: List.generate(3, (index) {
        final active = index <= step;
        final color = active
            ? context.colors.primary
            : context.colors.textTertiary;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < 2 ? 8 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 6,
                  decoration: BoxDecoration(
                    color: active
                        ? context.colors.primary
                        : context.colors.border,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: index == step
                        ? [
                            BoxShadow(
                              color: context.colors.primary.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ['Ma’lumotlar', 'Grafik turi', 'Taqsimot'][index],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    ),
  );
}

class _WizardFooter extends StatelessWidget {
  const _WizardFooter({required this.state});
  final InstallmentCreateState state;
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstallmentCreateCubit>();
    final finalStep = state.step == 2;
    final enabled =
        !state.isSubmitting &&
        !state.isUploading &&
        (!finalStep || state.step2ValidationError == null);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.borderSubtle)),
        boxShadow: [
          BoxShadow(
            color: context.colors.overlay.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 552),
          child: Row(
            children: [
              if (state.step > 0) ...[
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: context.colors.border),
                    ),
                    onPressed: state.isSubmitting ? null : cubit.previousStep,
                    child: Text(
                      'Orqaga',
                      style: TextStyle(
                        fontFamily: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.fontFamily,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 3,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: finalStep
                        ? context.colors.success
                        : context.colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: !enabled
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();
                          if (state.step == 0 &&
                              (state.totalAmount == null ||
                                  state.totalAmount! <= Decimal.zero)) {
                            AppSnackbar.error(context, 'Summani kiriting');
                            return;
                          }
                          if (finalStep) {
                            cubit.submit();
                          } else {
                            cubit.nextStep();
                          }
                        },
                  child: state.isSubmitting || state.isUploading
                      ? const SizedBox(
                          width: 21,
                          height: 21,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          finalStep ? 'Saqlash' : 'Davom etish',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BasicInfoStep extends StatefulWidget {
  const _BasicInfoStep({required this.partner});
  final Partner partner;
  @override
  State<_BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<_BasicInfoStep> {
  late final _noteController = TextEditingController(
    text: context.read<InstallmentCreateCubit>().state.note,
  );
  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstallmentCreateCubit>();
    final state = context.watch<InstallmentCreateCubit>().state;
    final colors = context.colors;
    final name = widget.partner.name.trim();
    return _StepBody(
      step: 0,
      title: '1-bosqich • Asosiy ma’lumotlar',
      children: [
        InstallmentSectionCard(
          accent: colors.primary.withValues(alpha: 0.3),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  name.isEmpty ? '?' : name.characters.first.toUpperCase(),
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const InstallmentFieldLabel('Mijoz'),
                    const SizedBox(height: 4),
                    Text(
                      name.isEmpty ? 'Mijoz' : name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        InstallmentSectionCard(
          accent: colors.primary.withValues(alpha: 0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const InstallmentFieldLabel('Miqdor va valyuta'),
              const SizedBox(height: 5),
              InstallmentAmountInput(
                value: state.totalAmount,
                currency: MoneyFormatter.currencyCode(state.currencyTypeId),
                large: true,
                onChanged: cubit.setTotalAmount,
              ),
              Divider(height: 28, color: colors.divider),
              LayoutBuilder(
                builder: (context, constraints) {
                  final label = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const InstallmentFieldLabel('Valyuta turi'),
                      const SizedBox(height: 4),
                      Text(
                        state.currencyTypeId == 1
                            ? 'O‘zbek so‘mi'
                            : 'AQSH dollari',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  );
                  final selector = _CurrencySelector(
                    value: state.currencyTypeId,
                    onChanged: cubit.setCurrency,
                  );
                  if (constraints.maxWidth < 300 ||
                      MediaQuery.textScalerOf(context).scale(14) > 19) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [label, const SizedBox(height: 12), selector],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: label),
                      const SizedBox(width: 8),
                      selector,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        InstallmentSectionCard(
          label: 'Izoh (ixtiyoriy)',
          child: TextField(
            controller: _noteController,
            minLines: 3,
            maxLines: 5,
            onChanged: cubit.setNote,
            style: TextStyle(fontSize: 14, color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Tafsilotlarni yozishingiz mumkin...',
              hintStyle: TextStyle(fontSize: 13, color: colors.textTertiary),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: 16),
        InstallmentSectionCard(
          label: 'Hujjatlar (ixtiyoriy)',
          child: AppFileAttachment(
            initialFiles: state.files,
            uploadType: 'installment',
            onUploadingChanged: cubit.setUploading,
            onFilesChanged: cubit.setFiles,
          ),
        ),
      ],
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  const _CurrencySelector({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: context.colors.surfaceSecondary,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final id in [1, 2])
          Semantics(
            selected: value == id,
            button: true,
            child: Material(
              color: value == id ? context.colors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              child: InkWell(
                onTap: () => onChanged(id),
                borderRadius: BorderRadius.circular(9),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  child: Text(
                    MoneyFormatter.currencyCode(id),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: value == id
                          ? Theme.of(context).colorScheme.onPrimary
                          : context.colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _ScheduleTypeStep extends StatelessWidget {
  const _ScheduleTypeStep();
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstallmentCreateCubit>();
    final state = context.watch<InstallmentCreateCubit>().state;
    return _StepBody(
      step: 1,
      title: '2-bosqich • Grafik turi',
      children: [
        for (final type in InstallmentScheduleType.values) ...[
          _ScheduleTypeCard(
            type: type,
            selected: state.scheduleType == type,
            onTap: () {
              cubit.setScheduleType(type);
              if (type == InstallmentScheduleType.custom &&
                  cubit.state.customItems.isEmpty) {
                final today = DateUtils.dateOnly(DateTime.now());
                cubit.setCustomItems(
                  List.generate(
                    2,
                    (index) => InstallmentPreviewItem(
                      itemNumber: index + 1,
                      amount: Decimal.zero,
                      dueDate: DateTime(
                        today.year,
                        today.month + index + 1,
                        today.day,
                      ),
                      isAdvance: false,
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ScheduleTypeCard extends StatelessWidget {
  const _ScheduleTypeCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });
  final InstallmentScheduleType type;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final equal = type == InstallmentScheduleType.equal;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: selected ? colors.primary : colors.border,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    equal
                        ? Icons.calculate_rounded
                        : Icons.edit_calendar_rounded,
                    size: 28,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equal ? 'Teng bo‘lib to‘lash' : 'Erkin grafik',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: selected ? colors.primary : colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        equal
                            ? 'Boshlanish sanasi va qismlar sonini belgilang. Tizim har bir qism uchun teng summani avtomatik hisoblaydi.'
                            : 'Har bir qism uchun summa va sanani alohida belgilang. To‘liq moslashuvchanlik va nazorat.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.6,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected ? colors.primary : colors.border,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DistributionStep extends StatelessWidget {
  const _DistributionStep();
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstallmentCreateCubit>();
    final state = context.watch<InstallmentCreateCubit>().state;
    final equal = state.scheduleType == InstallmentScheduleType.equal;
    final currency = MoneyFormatter.currencyCode(state.currencyTypeId);
    return _StepBody(
      step: 2,
      title: equal
          ? '3-bosqich • Teng bo‘lib to‘lash'
          : '3-bosqich • Erkin grafik',
      children: [
        _AdvanceToggle(
          enabled: state.hasAdvance,
          onChanged: cubit.setHasAdvance,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          alignment: Alignment.topCenter,
          child: !state.hasAdvance
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: InstallmentPaymentCard(
                    number: 0,
                    amount: state.advanceAmount,
                    date: state.startDate ?? DateTime.now(),
                    currency: currency,
                    isAdvance: true,
                    onAmountChanged: cubit.setAdvanceAmount,
                    onDateChanged: cubit.setStartDate,
                  ),
                ),
        ),
        const SizedBox(height: 16),
        if (equal) ...[
          _EqualSettings(state: state),
          const SizedBox(height: 20),
          if (state.preview.isNotEmpty) ...[
            InstallmentInfoBox(
              title: 'Taqsimot hisob-kitobi',
              description: _calculation(state),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'To‘lov jadvali',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
                _CountBadge(count: state.preview.length),
              ],
            ),
            const SizedBox(height: 12),
            for (final item in state.preview) ...[
              InstallmentPaymentCard(
                number: item.itemNumber,
                amount: item.amount,
                date: item.dueDate,
                currency: currency,
                isAdvance: item.isAdvance,
              ),
              const SizedBox(height: 12),
            ],
          ],
        ] else
          _CustomItemsEditor(state: state),
        if (state.step2ValidationError != null) ...[
          const SizedBox(height: 12),
          InstallmentInfoBox(
            title: 'Rejani tekshiring',
            description: state.step2ValidationError!,
            color: context.colors.warning,
            icon: Icons.error_outline_rounded,
          ),
        ],
      ],
    );
  }

  String _calculation(InstallmentCreateState state) {
    final total = state.totalAmount ?? Decimal.zero;
    final advance = state.hasAdvance
        ? state.advanceAmount ?? Decimal.zero
        : Decimal.zero;
    final regular = state.preview.where((item) => !item.isAdvance);
    final currency = MoneyFormatter.currencyCode(state.currencyTypeId);
    return 'Jami: ${MoneyFormatter.groupDigits(total)} $currency\n'
        '${state.hasAdvance ? 'Boshlang‘ich to‘lov: ${MoneyFormatter.groupDigits(advance)} $currency\nQolgan: ' : ''}'
        '${MoneyFormatter.groupDigits(total - advance)} $currency ÷ ${state.installmentCount} qism'
        '${regular.isEmpty ? '' : ' = ${MoneyFormatter.groupDigits(regular.first.amount)} $currency/qism'}';
  }
}

class _AdvanceToggle extends StatelessWidget {
  const _AdvanceToggle({required this.enabled, required this.onChanged});
  final bool enabled;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    final tint = enabled ? context.colors.warning : context.colors.primary;
    return InstallmentSectionCard(
      accent: enabled ? tint.withValues(alpha: 0.6) : null,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              enabled ? Icons.payments_rounded : Icons.money_off_rounded,
              color: tint,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Boshlang‘ich to‘lov',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Avans miqdorini belgilash',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            label: 'Boshlang‘ich to‘lov',
            child: Switch(
              value: enabled,
              onChanged: onChanged,
              activeTrackColor: context.colors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _EqualSettings extends StatelessWidget {
  const _EqualSettings({required this.state});
  final InstallmentCreateState state;
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstallmentCreateCubit>();
    final date = InstallmentSectionCard(
      label: state.hasAdvance
          ? 'Birinchi qism sanasi'
          : 'Birinchi to‘lov sanasi',
      child: InstallmentDateButton(
        date: state.startDate ?? DateTime.now(),
        onChanged: cubit.setStartDate,
      ),
    );
    final count = InstallmentSectionCard(
      label: state.hasAdvance ? 'Qolgan qismlar' : 'Qismlar soni',
      child: DropdownButtonFormField<int>(
        initialValue: state.installmentCount,
        decoration: InputDecoration(
          filled: true,
          fillColor: context.colors.surfaceSecondary,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        isExpanded: true,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: context.colors.primary,
        ),
        items: List.generate(
          60,
          (index) => DropdownMenuItem(
            value: index + 1,
            enabled: state.hasAdvance || index > 0,
            child: Text(
              '${index + 1} ta',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        onChanged: (value) {
          if (value != null) cubit.setInstallmentCount(value);
        },
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 310 ||
            MediaQuery.textScalerOf(context).scale(14) > 19) {
          return Column(children: [date, const SizedBox(height: 12), count]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: date),
            const SizedBox(width: 12),
            Expanded(child: count),
          ],
        );
      },
    );
  }
}

class _CustomItemsEditor extends StatelessWidget {
  const _CustomItemsEditor({required this.state});
  final InstallmentCreateState state;
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstallmentCreateCubit>();
    final sum =
        state.customItems.fold(Decimal.zero, (sum, item) => sum + item.amount) +
        (state.hasAdvance ? state.advanceAmount ?? Decimal.zero : Decimal.zero);
    final remaining = (state.totalAmount ?? Decimal.zero) - sum;
    final valid = state.step2ValidationError == null;
    final currency = MoneyFormatter.currencyCode(state.currencyTypeId);
    void update(int index, {Decimal? amount, DateTime? date, String? note}) {
      final items = List.of(cubit.state.customItems);
      if (index >= items.length) return;
      final item = items[index];
      items[index] = InstallmentPreviewItem(
        itemNumber: index + 1,
        amount: amount ?? item.amount,
        dueDate: date ?? item.dueDate,
        isAdvance: false,
        note: note ?? item.note,
      );
      cubit.setCustomItems(items);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InstallmentInfoBox(
          title: valid
              ? 'To‘liq taqsimlandi'
              : remaining < Decimal.zero
              ? 'Summa oshib ketdi'
              : 'Taqsimot qoldi',
          description: valid
              ? 'Jami ${MoneyFormatter.groupDigits(sum)} $currency rejalashtirildi.'
              : remaining < Decimal.zero
              ? '${MoneyFormatter.groupDigits(remaining.abs())} $currency ga kamaytiring.'
              : 'Qolgan: ${MoneyFormatter.groupDigits(remaining)} $currency. Barcha summani taqsimlang.',
          color: valid
              ? context.colors.success
              : remaining < Decimal.zero
              ? context.colors.error
              : context.colors.warning,
          icon: valid
              ? Icons.check_circle_outline_rounded
              : Icons.info_outline_rounded,
        ),
        const SizedBox(height: 16),
        for (var index = 0; index < state.customItems.length; index++) ...[
          InstallmentPaymentCard(
            key: ValueKey('custom-$index'),
            number: index + 1,
            amount: state.customItems[index].amount,
            date: state.customItems[index].dueDate,
            currency: currency,
            note: state.customItems[index].note,
            onAmountChanged: (amount) =>
                update(index, amount: amount ?? Decimal.zero),
            onDateChanged: (date) => update(index, date: date),
            onNoteChanged: (note) => update(index, note: note),
            onDelete: () {
              final items = List.of(cubit.state.customItems)..removeAt(index);
              cubit.setCustomItems(items);
            },
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: context.colors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.add_circle_outline_rounded),
          label: const Text(
            'Yangi qism qo‘shish',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          onPressed: () {
            final items = cubit.state.customItems;
            final today = DateUtils.dateOnly(DateTime.now());
            final date = items.isEmpty
                ? DateTime(today.year, today.month + 1, today.day)
                : DateTime(
                    items.last.dueDate.year,
                    items.last.dueDate.month + 1,
                    items.last.dueDate.day,
                  );
            cubit.setCustomItems([
              ...items,
              InstallmentPreviewItem(
                itemNumber: items.length + 1,
                amount: Decimal.zero,
                dueDate: date,
                isAdvance: false,
              ),
            ]);
          },
        ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: context.colors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      '$count ta',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: context.colors.primary,
      ),
    ),
  );
}
