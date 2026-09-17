import 'package:flutter/material.dart';

import '../../../../core/widgets/sheets/app_selection_sheet.dart';
import '../../data/partner_models.dart';

/// Status filtri backend endpointidan emas, lokal enum orqali beriladi —
/// route conflict sababli (MOBILE_APP_TZ.md 8.2 eslatmasi).
Future<PartnerStatusFilter?> showPartnerFilterSheet(BuildContext context, PartnerStatusFilter current) {
  return showAppSelectionSheet<PartnerStatusFilter>(
    context,
    title: 'Filtr',
    selectedValue: current,
    items: const [
      AppSelectionItem(value: PartnerStatusFilter.all, label: 'Barchasi'),
      AppSelectionItem(value: PartnerStatusFilter.creditor, label: 'Xaqdorlar'),
      AppSelectionItem(value: PartnerStatusFilter.debtor, label: 'Qarzdorlar'),
      AppSelectionItem(value: PartnerStatusFilter.overdueDebtor, label: 'Muddati o\'tgan qarzdorlar'),
    ],
  );
}

Future<PartnerSort?> showPartnerSortSheet(BuildContext context, PartnerSort current) {
  return showAppSelectionSheet<PartnerSort>(
    context,
    title: 'Saralash',
    selectedValue: current,
    items: const [
      AppSelectionItem(value: PartnerSort.lastActivity, label: 'Oxirgi faollik'),
      AppSelectionItem(value: PartnerSort.debtorUzs, label: 'Qarzdor UZS'),
      AppSelectionItem(value: PartnerSort.debtorUsd, label: 'Qarzdor USD'),
      AppSelectionItem(value: PartnerSort.creditorUzs, label: 'Xaqdor UZS'),
      AppSelectionItem(value: PartnerSort.creditorUsd, label: 'Xaqdor USD'),
    ],
  );
}
