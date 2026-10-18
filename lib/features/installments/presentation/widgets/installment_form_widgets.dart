import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../core/utils/formatters/money_formatter.dart';

/// Shared visual language for the three installment creation steps.
class InstallmentSectionCard extends StatelessWidget {
  const InstallmentSectionCard({
    super.key,
    required this.child,
    this.label,
    this.accent,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final String? label;
  final Color? accent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (label != null) ...[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: context.colors.textSecondary,
            ),
          ),
        ),
      ],
      Container(
        padding: padding,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accent ?? context.colors.border,
            width: accent == null ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: context.colors.overlay.withValues(alpha: 0.035),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    ],
  );
}

class InstallmentFieldLabel extends StatelessWidget {
  const InstallmentFieldLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: context.colors.textSecondary,
      letterSpacing: 0.3,
    ),
  );
}

/// Local formatter: grouped amounts with up to two decimal places.
class _AmountFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(' ', '').replaceAll(',', '.');
    if (!RegExp(r'^\d{0,15}(\.\d{0,2})?$').hasMatch(raw)) return oldValue;
    final parts = raw.split('.');
    final text =
        '${MoneyFormatter.liveGroup(parts.first)}${parts.length > 1 ? '.${parts.last}' : ''}';
    final digitsAfter = newValue.text
        .substring(newValue.selection.end.clamp(0, newValue.text.length))
        .replaceAll(' ', '')
        .length;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: (text.length - digitsAfter).clamp(0, text.length),
      ),
    );
  }
}

class InstallmentAmountInput extends StatefulWidget {
  const InstallmentAmountInput({
    super.key,
    required this.value,
    required this.currency,
    required this.onChanged,
    this.large = false,
    this.semanticLabel = 'Summa',
  });
  final Decimal? value;
  final String currency;
  final ValueChanged<Decimal?> onChanged;
  final bool large;
  final String semanticLabel;
  @override
  State<InstallmentAmountInput> createState() => _InstallmentAmountInputState();
}

class _InstallmentAmountInputState extends State<InstallmentAmountInput> {
  late final _controller = TextEditingController(text: _text(widget.value));
  String _text(Decimal? value) => value == null || value == Decimal.zero
      ? ''
      : MoneyFormatter.groupDigits(value).replaceAll(',', '.');
  @override
  void didUpdateWidget(covariant InstallmentAmountInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final current = Decimal.tryParse(_controller.text.replaceAll(' ', ''));
    if (current != widget.value &&
        !(current == null && widget.value == Decimal.zero)) {
      _controller.text = _text(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (widget.large) ...[
        Icon(
          Icons.account_balance_wallet_rounded,
          size: 22,
          color: context.colors.primary,
        ),
        const SizedBox(width: 12),
      ],
      Expanded(
        child: Semantics(
          label: widget.semanticLabel,
          child: TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [_AmountFormatter()],
            style: TextStyle(
              fontSize: widget.large ? 26 : 17,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(color: context.colors.textTertiary),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (text) =>
                widget.onChanged(Decimal.tryParse(text.replaceAll(' ', ''))),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        widget.currency,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: context.colors.textSecondary,
        ),
      ),
    ],
  );
}

class InstallmentDateButton extends StatelessWidget {
  const InstallmentDateButton({super.key, required this.date, this.onChanged});
  final DateTime date;
  final ValueChanged<DateTime>? onChanged;
  @override
  Widget build(BuildContext context) => Material(
    color: context.colors.surfaceSecondary,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onChanged == null
          ? null
          : () async {
              FocusScope.of(context).unfocus();
              final today = DateUtils.dateOnly(DateTime.now());
              final selected = DateUtils.dateOnly(date);
              final picked = await showDatePicker(
                context: context,
                initialDate: selected.isBefore(today) ? today : selected,
                firstDate: today,
                lastDate: DateTime(today.year + 10, 12, 31),
              );
              if (picked != null && context.mounted) onChanged!(picked);
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: context.colors.primary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                AppDateFormatter.display(date),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class InstallmentInfoBox extends StatelessWidget {
  const InstallmentInfoBox({
    super.key,
    required this.title,
    required this.description,
    this.color,
    this.icon = Icons.info_outline_rounded,
  });
  final String title;
  final String description;
  final Color? color;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.colors.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tint.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: tint),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: tint,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InstallmentPaymentCard extends StatefulWidget {
  const InstallmentPaymentCard({
    super.key,
    required this.number,
    required this.amount,
    required this.date,
    required this.currency,
    this.isAdvance = false,
    this.note,
    this.onAmountChanged,
    this.onDateChanged,
    this.onNoteChanged,
    this.onDelete,
  });
  final int number;
  final Decimal? amount;
  final DateTime date;
  final String currency;
  final bool isAdvance;
  final String? note;
  final ValueChanged<Decimal?>? onAmountChanged;
  final ValueChanged<DateTime>? onDateChanged;
  final ValueChanged<String>? onNoteChanged;
  final VoidCallback? onDelete;
  @override
  State<InstallmentPaymentCard> createState() => _InstallmentPaymentCardState();
}

class _InstallmentPaymentCardState extends State<InstallmentPaymentCard> {
  late final _noteController = TextEditingController(text: widget.note);
  @override
  void didUpdateWidget(covariant InstallmentPaymentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_noteController.text != (widget.note ?? '')) {
      _noteController.text = widget.note ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tint = widget.isAdvance ? colors.warning : colors.primary;
    Widget amountField() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const InstallmentFieldLabel('Summa'),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: widget.onAmountChanged != null
              ? InstallmentAmountInput(
                  value: widget.amount,
                  currency: widget.currency,
                  onChanged: widget.onAmountChanged!,
                  semanticLabel: widget.isAdvance
                      ? 'Avans summasi'
                      : '${widget.number}-qism summasi',
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    '${MoneyFormatter.groupDigits(widget.amount ?? Decimal.zero)} ${widget.currency}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
        ),
      ],
    );
    Widget dateField() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const InstallmentFieldLabel('To‘lov sanasi'),
        const SizedBox(height: 6),
        InstallmentDateButton(
          date: widget.date,
          onChanged: widget.onDateChanged,
        ),
      ],
    );
    return InstallmentSectionCard(
      accent: widget.isAdvance ? tint.withValues(alpha: 0.6) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.isAdvance ? 'AVANS' : '${widget.number}',
                  style: TextStyle(
                    color: tint,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.isAdvance
                      ? 'Boshlang‘ich to‘lov'
                      : '${widget.number}-qism',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (widget.onDelete != null)
                IconButton(
                  tooltip: 'Qismni olib tashlash',
                  onPressed: widget.onDelete,
                  icon: Icon(
                    Icons.remove_circle_outline_rounded,
                    color: colors.error,
                    size: 22,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 290 ||
                  MediaQuery.textScalerOf(context).scale(14) > 19) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    amountField(),
                    const SizedBox(height: 12),
                    dateField(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: amountField()),
                  const SizedBox(width: 12),
                  Expanded(child: dateField()),
                ],
              );
            },
          ),
          if (widget.onNoteChanged != null) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              onChanged: widget.onNoteChanged,
              maxLines: null,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Izoh (ixtiyoriy)',
                prefixIcon: const Icon(Icons.notes_rounded, size: 18),
                filled: true,
                fillColor: colors.surfaceSecondary,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
