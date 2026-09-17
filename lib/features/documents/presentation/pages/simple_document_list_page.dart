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

/// Ish turlari / Lavozimlar uchun umumiy CRUD ekrani — bir xil naqsh
/// (MOBILE_APP_TZ.md 11-bo'lim: "barcha ma'lumotnomalarda bir xil CRUD").
class SimpleDocumentListPage extends StatelessWidget {
  const SimpleDocumentListPage({
    super.key,
    required this.title,
    required this.entityLabel,
    required this.cubit,
  });

  final String title;
  final String entityLabel;
  final SimpleDocumentCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit..load(),
      child: _View(title: title, entityLabel: entityLabel),
    );
  }
}

class _View extends StatelessWidget {
  const _View({required this.title, required this.entityLabel});
  final String title;
  final String entityLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: BlocBuilder<SimpleDocumentCubit, SimpleDocumentState>(
        builder: (context, state) {
          return switch (state) {
            SimpleDocumentLoading() => const AppSkeletonList(),
            SimpleDocumentError(:final failure) =>
              AppErrorState(failure: failure, onRetry: () => context.read<SimpleDocumentCubit>().load()),
            SimpleDocumentLoaded(:final items) => items.isEmpty
                ? AppEmptyState(
                    title: '$entityLabel topilmadi',
                    actionLabel: '$entityLabel qo\'shish',
                    onAction: () => _openForm(context),
                  )
                : RefreshIndicator(
                    onRefresh: () => context.read<SimpleDocumentCubit>().load(),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) => _DocumentTile(item: items[i], entityLabel: entityLabel),
                    ),
                  ),
          };
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: Text(entityLabel),
      ),
    );
  }

  void _openForm(BuildContext context) => showDocumentFormSheet(context, entityLabel: entityLabel);
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.item, required this.entityLabel});
  final SimpleDocument item;
  final String entityLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      onTap: item.isDeleted
          ? null
          : () => showDocumentFormSheet(context, entityLabel: entityLabel, editing: item),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: item.isDeleted ? colors.textTertiary : colors.textPrimary,
                      ),
                ),
                if (item.description != null && item.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(item.description!, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
                  ),
                if (item.isDeleted)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: AppStatusChip(label: 'O\'chirilgan', tone: AppStatusChipTone.neutral),
                  ),
              ],
            ),
          ),
          if (item.isDeleted)
            AppButton.text(
              label: 'Tiklash',
              onPressed: () => context.read<SimpleDocumentCubit>().submitRestore(item.id),
            )
          else
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: colors.error),
              onPressed: () async {
                final confirmed = await showAppConfirmationSheet(
                  context,
                  title: '$entityLabel o\'chirilsinmi?',
                  description: 'Bu amalni keyin qaytarib bo\'lmaydi.',
                );
                if (confirmed && context.mounted) {
                  final error = await context.read<SimpleDocumentCubit>().submitDelete(item.id);
                  if (error != null && context.mounted) AppSnackbar.error(context, error.message);
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
  required String entityLabel,
  SimpleDocument? editing,
}) {
  final cubit = context.read<SimpleDocumentCubit>();
  final nameController = TextEditingController(text: editing?.name);
  final descriptionController = TextEditingController(text: editing?.description);
  String? error;

  return showAppBottomSheet<void>(
    context,
    title: editing == null ? '$entityLabel qo\'shish' : '$entityLabel tahrirlash',
    child: StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: nameController, label: 'Nomi', errorText: error),
            const SizedBox(height: AppSpacing.md),
            AppTextField(controller: descriptionController, label: 'Tavsif (ixtiyoriy)', maxLines: 2, minLines: 1),
          ],
        ),
      ),
    ),
    stickyAction: Builder(
      builder: (sheetContext) => AppButton.primary(
        label: 'Saqlash',
        onPressed: () async {
          final name = nameController.text.trim();
          if (name.isEmpty) return;
          final failure = editing == null
              ? await cubit.submitCreate(name, descriptionController.text.trim())
              : await cubit.submitUpdate(editing.id, name, descriptionController.text.trim());
          if (failure != null) {
            if (sheetContext.mounted) AppSnackbar.error(sheetContext, failure.message);
            return;
          }
          if (sheetContext.mounted) Navigator.of(sheetContext).pop();
        },
      ),
    ),
  );
}
