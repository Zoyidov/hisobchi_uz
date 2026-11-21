import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/buttons/app_floating_action.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/chips/app_status_chip.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../../../../core/widgets/sheets/app_confirmation_sheet.dart';
import '../../../../core/widgets/states/app_empty_state.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../data/document_models.dart';
import '../../data/documents_repository.dart';
import '../cubit/cost_type_cubit.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/localization/app_localization_extension.dart';

/// Xarajat turlari (MOBILE_APP_TZ.md 11-bo'lim).
class CostTypesPage extends StatelessWidget {
  const CostTypesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CostTypeCubit(getIt<DocumentsRepository>())..load(),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.docCostTypes),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: const Size(0, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
              onPressed: () => _openForm(context),
              icon: const Icon(AppIcons.add, size: 15),
              label: Text(
                context.l10n.commonAdd,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<CostTypeCubit, CostTypeState>(
        builder: (context, state) {
          return switch (state) {
            CostTypeLoading() => const AppSkeletonList(),
            CostTypeError(:final failure) => AppErrorState(
              failure: failure,
              onRetry: () => context.read<CostTypeCubit>().load(),
            ),
            CostTypeLoaded(:final items) =>
              items.isEmpty
                  ? AppEmptyState(
                      title: context.l10n.docCostTypeNotFound,
                      actionLabel: context.l10n.docCostTypeAdd,
                      onAction: () => _openForm(context),
                    )
                  : RefreshIndicator(
                      onRefresh: () => context.read<CostTypeCubit>().load(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md,
                          110,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, i) => _Tile(item: items[i]),
                      ),
                    ),
          };
        },
      ),
      floatingActionButton: AppFloatingAction(
        heroTag: 'cost_types_create_fab',
        onPressed: () => _openForm(context),
        icon: AppIcons.add,
        label: context.l10n.docCostTypeAdd,
      ),
    );
  }

  void _openForm(BuildContext context) => _showCostTypeForm(context);
}

class _Tile extends StatelessWidget {
  const _Tile({required this.item});
  final CostType item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      onTap: item.isDeleted || item.isSystem
          ? null
          : () => _showCostTypeForm(context, editing: item),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.titleSmall),
                if (item.description != null && item.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      item.description!,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(
                    spacing: 6,
                    children: [
                      if (item.isWorkerJoin)
                        AppStatusChip(
                          label: context.l10n.docWorkerAssigned,
                          tone: AppStatusChipTone.info,
                        ),
                      if (item.isSystem)
                        AppStatusChip(
                          label: context.l10n.docSystem,
                          tone: AppStatusChipTone.neutral,
                        ),
                      if (item.isDeleted)
                        AppStatusChip(
                          label: context.l10n.commonDeleted,
                          tone: AppStatusChipTone.neutral,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (item.isDeleted)
            AppButton.text(
              label: context.l10n.commonRestore,
              onPressed: () =>
                  context.read<CostTypeCubit>().submitRestore(item.id),
            )
          else if (!item.isSystem)
            IconButton(
              icon: Icon(AppIcons.delete, color: colors.error),
              onPressed: () async {
                final confirmed = await showAppConfirmationSheet(
                  context,
                  title: context.l10n.docCostTypeDeleteConfirm,
                  description: context.l10n.commonIrreversible,
                );
                if (confirmed && context.mounted) {
                  final error = await context
                      .read<CostTypeCubit>()
                      .submitDelete(item.id);
                  if (error != null && context.mounted) {
                    AppSnackbar.error(context, error.message);
                  }
                }
              },
            ),
        ],
      ),
    );
  }
}

void _showCostTypeForm(BuildContext context, {CostType? editing}) {
  final cubit = context.read<CostTypeCubit>();
  final nameController = TextEditingController(text: editing?.name);
  final descriptionController = TextEditingController(
    text: editing?.description,
  );
  var isWorkerJoin = editing?.isWorkerJoin ?? false;

  showAppBottomSheet<void>(
    context,
    title: editing == null
        ? context.l10n.docCostTypeAdd
        : context.l10n.docCostTypeEdit,
    child: StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: nameController,
              label: context.l10n.commonName,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: descriptionController,
              label: context.l10n.commonDescriptionOptional,
              maxLines: 2,
              minLines: 1,
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.docWorkerAssigned),
              value: isWorkerJoin,
              onChanged: (v) => setState(() => isWorkerJoin = v),
            ),
          ],
        ),
      ),
    ),
    stickyAction: Builder(
      builder: (sheetContext) => AppButton.primary(
        label: context.l10n.commonSave,
        onPressed: () async {
          final name = nameController.text.trim();
          if (name.isEmpty) return;
          final failure = editing == null
              ? await cubit.submitCreate(
                  name,
                  descriptionController.text.trim(),
                  isWorkerJoin,
                )
              : await cubit.submitUpdate(
                  editing.id,
                  name,
                  descriptionController.text.trim(),
                  isWorkerJoin,
                );
          if (failure != null) {
            if (sheetContext.mounted) {
              AppSnackbar.error(sheetContext, failure.message);
            }
            return;
          }
          if (sheetContext.mounted) Navigator.of(sheetContext).pop();
        },
      ),
    ),
  );
}
