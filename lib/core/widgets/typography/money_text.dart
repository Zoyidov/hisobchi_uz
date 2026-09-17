import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../utils/formatters/money_formatter.dart';

enum MoneySize { display, card, list }

/// `MoneyText(amount: ..., currency: ...)` → `1 500 000 UZS`
/// (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 115).
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.amount, {
    super.key,
    this.currencyTypeId = 1,
    this.currencyLabel,
    this.signed = false,
    this.size = MoneySize.list,
    this.colorOverride,
  });

  final Decimal amount;
  final int currencyTypeId;
  final String? currencyLabel;
  final bool signed;
  final MoneySize size;
  final Color? colorOverride;

  @override
  Widget build(BuildContext context) {
    final text = signed
        ? MoneyFormatter.formatSigned(amount, currencyTypeId: currencyTypeId, currencyLabel: currencyLabel)
        : MoneyFormatter.format(amount, currencyTypeId: currencyTypeId, currencyLabel: currencyLabel);

    final style = switch (size) {
      MoneySize.display => Theme.of(context).textTheme.displaySmall,
      MoneySize.card => Theme.of(context).textTheme.headlineSmall,
      MoneySize.list => Theme.of(context).textTheme.titleMedium,
    };

    final color = colorOverride ?? (signed ? amountColor(context, amount.toDouble()) : context.colors.textPrimary);

    return Text(text, style: style?.copyWith(color: color, fontWeight: FontWeight.w700));
  }
}
