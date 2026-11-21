import 'package:flutter/material.dart';

import '../../../core/widgets/sheets/app_selection_sheet.dart';
import '../data/currency.dart';
import '../../../core/localization/app_localization_extension.dart';

/// Currency uchun dropdown o'rniga bottom sheet (E_HISOB_FLUTTER_UI_UX_TZ.md 2, 23).
Future<Currency?> showCurrencySelectionSheet(
  BuildContext context, {
  required List<Currency> currencies,
  required int selectedId,
}) {
  return showAppSelectionSheet<Currency>(
    context,
    title: context.l10n.currencySelectTitle,
    selectedValue: currencies.firstWhere(
      (c) => c.id == selectedId,
      orElse: () => currencies.first,
    ),
    items: currencies
        .map((c) => AppSelectionItem(value: c, label: c.name))
        .toList(),
  );
}
