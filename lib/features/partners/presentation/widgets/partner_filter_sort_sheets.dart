import 'package:flutter/material.dart';

import '../../../../core/widgets/sheets/app_selection_sheet.dart';
import '../../data/partner_models.dart';
import '../../../../core/localization/app_localization_extension.dart';

/// Status filtri backend endpointidan emas, lokal enum orqali beriladi —
/// route conflict sababli (MOBILE_APP_TZ.md 8.2 eslatmasi).
Future<PartnerStatusFilter?> showPartnerFilterSheet(
  BuildContext context,
  PartnerStatusFilter current,
) {
  return showAppSelectionSheet<PartnerStatusFilter>(
    context,
    title: context.l10n.commonFilter,
    selectedValue: current,
    items: [
      AppSelectionItem(
        value: PartnerStatusFilter.all,
        label: context.l10n.commonAll,
      ),
      AppSelectionItem(
        value: PartnerStatusFilter.creditor,
        label: context.l10n.partnersStatusCreditor,
      ),
      AppSelectionItem(
        value: PartnerStatusFilter.debtor,
        label: context.l10n.partnersStatusDebtor,
      ),
      AppSelectionItem(
        value: PartnerStatusFilter.overdueDebtor,
        label: context.l10n.partnersStatusOverdue,
      ),
    ],
  );
}

Future<PartnerSort?> showPartnerSortSheet(
  BuildContext context,
  PartnerSort current,
) {
  return showAppSelectionSheet<PartnerSort>(
    context,
    title: context.l10n.commonSort,
    selectedValue: current,
    items: [
      AppSelectionItem(
        value: PartnerSort.lastActivity,
        label: context.l10n.partnersSortLastActivity,
      ),
      AppSelectionItem(
        value: PartnerSort.debtorUzs,
        label: context.l10n.partnersSortDebtorUzs,
      ),
      AppSelectionItem(
        value: PartnerSort.debtorUsd,
        label: context.l10n.partnersSortDebtorUsd,
      ),
      AppSelectionItem(
        value: PartnerSort.creditorUzs,
        label: context.l10n.partnersSortCreditorUzs,
      ),
      AppSelectionItem(
        value: PartnerSort.creditorUsd,
        label: context.l10n.partnersSortCreditorUsd,
      ),
    ],
  );
}
