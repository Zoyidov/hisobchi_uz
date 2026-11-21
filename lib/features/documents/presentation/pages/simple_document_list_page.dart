import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
import '../cubit/simple_document_cubit.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/localization/app_localization_extension.dart';

/// Ish turlari / Lavozimlar uchun umumiy CRUD ekrani — bir xil naqsh
/// (MOBILE_APP_TZ.md 11-bo'lim: "barcha ma'lumotnomalarda bir xil CRUD").
class SimpleDocumentListPage extends StatelessWidget {
  const SimpleDocumentListPage({
    super.key,
    required this.kind,
    required this.cubit,
  });

  final SimpleDocumentKind kind;
  final SimpleDocumentCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit..load(),
      child: _View(kind: kind),
    );
  }
}

class _View extends StatelessWidget {
  const _View({required this.kind});
  final SimpleDocumentKind kind;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kind.title(context.l10n))),
      body: BlocBuilder<SimpleDocumentCubit, SimpleDocumentState>(
        builder: (context, state) {
          return switch (state) {
            SimpleDocumentLoading() => const AppSkeletonList(),
            SimpleDocumentError(:final failure) => AppErrorState(
              failure: failure,
              onRetry: () => context.read<SimpleDocumentCubit>().load(),
            ),
            SimpleDocumentLoaded(:final items) =>
              items.isEmpty
                  ? AppEmptyState(
                      title: kind.notFound(context.l10n),
                      actionLabel: kind.add(context.l10n),
                      onAction: () => _openForm(context),
                    )
                  : RefreshIndicator(
                      onRefresh: () =>
                          context.read<SimpleDocumentCubit>().load(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, i) =>
                            _DocumentTile(item: items[i], kind: kind),
                      ),
                    ),
          };
        },
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: 82.0 + MediaQuery.of(context).padding.bottom,
        ),
        child: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => _openForm(context),
          icon: const Icon(AppIcons.add),
          label: Text(kind.add(context.l10n)),
        ),
      ),
    );
  }

  void _openForm(BuildContext context) =>
      showDocumentFormSheet(context, kind: kind);
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.item, required this.kind});
  final SimpleDocument item;
  final SimpleDocumentKind kind;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      onTap: item.isDeleted
          ? null
          : () => showDocumentFormSheet(context, kind: kind, editing: item),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: item.isDeleted
                        ? colors.textTertiary
                        : colors.textPrimary,
                  ),
                ),
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
                if (item.isDeleted)
                  Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: AppStatusChip(
                      label: context.l10n.commonDeleted,
                      tone: AppStatusChipTone.neutral,
                    ),
                  ),
              ],
            ),
          ),
          if (item.isDeleted)
            AppButton.text(
              label: context.l10n.commonRestore,
              onPressed: () =>
                  context.read<SimpleDocumentCubit>().submitRestore(item.id),
            )
          else
            IconButton(
              icon: Icon(AppIcons.delete, color: colors.error),
              onPressed: () async {
                final confirmed = await showAppConfirmationSheet(
                  context,
                  title: kind.deleteConfirm(context.l10n),
                  description: context.l10n.commonIrreversible,
                );
                if (confirmed && context.mounted) {
                  final error = await context
                      .read<SimpleDocumentCubit>()
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

Future<void> showDocumentFormSheet(
  BuildContext context, {
  required SimpleDocumentKind kind,
  SimpleDocument? editing,
}) {
  final cubit = context.read<SimpleDocumentCubit>();
  final nameController = TextEditingController(text: editing?.name);
  final descriptionController = TextEditingController(
    text: editing?.description,
  );
  String? error;

  return showAppBottomSheet<void>(
    context,
    title: editing == null ? kind.add(context.l10n) : kind.edit(context.l10n),
    child: StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: nameController,
              label: context.l10n.commonName,
              errorText: error,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: descriptionController,
              label: context.l10n.commonDescriptionOptional,
              maxLines: 2,
              minLines: 1,
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
                )
              : await cubit.submitUpdate(
                  editing.id,
                  name,
                  descriptionController.text.trim(),
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

/// Oddiy ma'lumotnoma turlari — sahifa matnlari tur bo'yicha to'liq
/// gaplar sifatida lokalizatsiya qilinadi (o'zbek/rus grammatikasi uchun
/// "{nom} qo'shish" kabi yopishtirish ishlatilmaydi).
enum SimpleDocumentKind { workType, position }

extension SimpleDocumentKindL10n on SimpleDocumentKind {
  String title(AppLocalizations l10n) => switch (this) {
    SimpleDocumentKind.workType => l10n.docWorkTypes,
    SimpleDocumentKind.position => l10n.docPositions,
  };

  String notFound(AppLocalizations l10n) => switch (this) {
    SimpleDocumentKind.workType => l10n.docWorkTypeNotFound,
    SimpleDocumentKind.position => l10n.docPositionNotFound,
  };

  String add(AppLocalizations l10n) => switch (this) {
    SimpleDocumentKind.workType => l10n.docWorkTypeAdd,
    SimpleDocumentKind.position => l10n.docPositionAdd,
  };

  String edit(AppLocalizations l10n) => switch (this) {
    SimpleDocumentKind.workType => l10n.docWorkTypeEdit,
    SimpleDocumentKind.position => l10n.docPositionEdit,
  };

  String deleteConfirm(AppLocalizations l10n) => switch (this) {
    SimpleDocumentKind.workType => l10n.docWorkTypeDeleteConfirm,
    SimpleDocumentKind.position => l10n.docPositionDeleteConfirm,
  };
}
