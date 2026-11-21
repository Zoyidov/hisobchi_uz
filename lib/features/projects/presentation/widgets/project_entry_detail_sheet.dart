import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/domain/entities/app_file.dart';
import '../../../../core/widgets/media/app_file_preview.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../core/utils/formatters/money_formatter.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../../data/project_models.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/localization/app_localization_extension.dart';

Future<void> showProjectIncomeDetail(
  BuildContext context,
  ProjectIncome income,
) => _show(
  context,
  expense: false,
  id: income.id,
  amount: income.summa,
  currency: income.currencyTypeName,
  createdAt: income.createdAt,
  description: income.description,
  files: income.files,
);

Future<void> showProjectCostDetail(BuildContext context, ProjectCost cost) =>
    _show(
      context,
      expense: true,
      id: cost.id,
      amount: cost.summa,
      currency: cost.currencyTypeName,
      createdAt: cost.createdAt,
      description: cost.description,
      files: cost.files,
      costType: cost.costTypeName,
      worker: cost.workerName,
    );

Future<void> _show(
  BuildContext context, {
  required bool expense,
  required int id,
  required Decimal amount,
  required String currency,
  DateTime? createdAt,
  String? description,
  String? costType,
  String? worker,
  List<AppFile> files = const [],
}) async {
  final colors = context.colors;
  final accent = expense ? colors.error : colors.success;
  await showAppBottomSheet<void>(
    context,
    title: expense
        ? context.l10n.entryCostDetails
        : context.l10n.entryIncomeDetails,
    heightFactor: .75,
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: .13),
                  accent.withValues(alpha: .04),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Icon(
                    expense ? AppIcons.expense : AppIcons.income,
                    color: accent,
                    size: 22,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  MoneyFormatter.format(amount, currencyLabel: currency),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  expense
                      ? context.l10n.entryProjectCost
                      : context.l10n.entryProjectIncome,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            hasShadow: false,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Column(
              children: [
                _DetailRow(
                  label: context.l10n.entryOperation,
                  value: '#$id',
                  icon: AppIcons.receipt,
                ),
                if (createdAt != null) ...[
                  Divider(height: 24, color: colors.divider),
                  _DetailRow(
                    label: context.l10n.commonDate,
                    value: AppDateFormatter.displayDateTime(createdAt),
                    icon: AppIcons.clock,
                  ),
                ],
                if (costType?.isNotEmpty == true) ...[
                  Divider(height: 24, color: colors.divider),
                  _DetailRow(
                    label: context.l10n.costType,
                    value: costType!,
                    icon: AppIcons.category,
                  ),
                ],
                if (worker?.isNotEmpty == true) ...[
                  Divider(height: 24, color: colors.divider),
                  _DetailRow(
                    label: context.l10n.costWorkerLabel,
                    value: worker!,
                    icon: AppIcons.user,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            hasShadow: false,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.commonNote,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.xs),
                SelectableText(
                  description?.trim().isNotEmpty == true
                      ? description!.trim()
                      : context.l10n.entryNoNote,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (files.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            AppFilePreview(files: files),
          ],
        ],
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 18, color: context.colors.textTertiary),
      const SizedBox(width: AppSpacing.xs),
      Expanded(
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Flexible(
        child: SelectableText(
          value,
          textAlign: TextAlign.right,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}
