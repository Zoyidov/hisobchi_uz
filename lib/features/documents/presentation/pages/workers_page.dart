import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/phone_formatter.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/chips/app_status_chip.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_phone_field.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/media/app_avatar.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../../../../core/widgets/sheets/app_confirmation_sheet.dart';
import '../../../../core/widgets/sheets/app_selection_sheet.dart';
import '../../../../core/widgets/states/app_empty_state.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../data/document_models.dart';
import '../../data/documents_repository.dart';
import '../cubit/workers_cubit.dart';

/// Ishchilar (MOBILE_APP_TZ.md 11-bo'lim).
class WorkersPage extends StatelessWidget {
  const WorkersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WorkersCubit(getIt<DocumentsRepository>())..load(),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ishchilar')),
      body: BlocBuilder<WorkersCubit, WorkersState>(
        builder: (context, state) {
          return switch (state) {
            WorkersLoading() => const AppSkeletonList(),
            WorkersError(:final failure) =>
              AppErrorState(failure: failure, onRetry: () => context.read<WorkersCubit>().load()),
            WorkersLoaded(:final items, :final positions) => items.isEmpty
                ? AppEmptyState(
                    title: 'Ishchi topilmadi',
                    actionLabel: 'Ishchi qo\'shish',
                    onAction: () => _showWorkerForm(context, positions: positions),
                  )
                : RefreshIndicator(
                    onRefresh: () => context.read<WorkersCubit>().load(),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) => _Tile(item: items[i], positions: positions),
                    ),
                  ),
          };
        },
      ),
      floatingActionButton: BlocBuilder<WorkersCubit, WorkersState>(
        builder: (context, state) {
          final positions = state is WorkersLoaded ? state.positions : <SimpleDocument>[];
          return FloatingActionButton.extended(
            onPressed: () => _showWorkerForm(context, positions: positions),
            icon: const Icon(Icons.add),
            label: const Text('Ishchi'),
          );
        },
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.item, required this.positions});
  final Worker item;
  final List<SimpleDocument> positions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      onTap: item.isDeleted ? null : () => _showWorkerForm(context, positions: positions, editing: item),
      child: Row(
        children: [
          AppAvatar(name: item.name, size: 44),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.titleSmall),
                Text(PhoneFormatter.toDisplay(item.phone), style: TextStyle(color: colors.textSecondary, fontSize: 13)),
                if (item.positionName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: AppStatusChip(label: item.positionName!, tone: AppStatusChipTone.info),
                  ),
                if (item.isDeleted)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: AppStatusChip(label: 'O\'chirilgan', tone: AppStatusChipTone.neutral),
                  ),
              ],
            ),
          ),
          if (item.isDeleted)
            AppButton.text(label: 'Tiklash', onPressed: () => context.read<WorkersCubit>().submitRestore(item.id))
          else
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: colors.error),
              onPressed: () async {
                final confirmed = await showAppConfirmationSheet(
                  context,
                  title: 'Ishchi o\'chirilsinmi?',
                  description: 'Bu amalni keyin qaytarib bo\'lmaydi.',
                );
                if (confirmed && context.mounted) {
                  final error = await context.read<WorkersCubit>().submitDelete(item.id);
                  if (error != null && context.mounted) AppSnackbar.error(context, error.message);
                }
              },
            ),
        ],
      ),
    );
  }
}

void _showWorkerForm(BuildContext context, {required List<SimpleDocument> positions, Worker? editing}) {
  final cubit = context.read<WorkersCubit>();
  final nameController = TextEditingController(text: editing?.name);
  final phoneController = TextEditingController(text: editing?.phone);
  final additionalPhoneController = TextEditingController(text: editing?.additionalPhone);
  final descriptionController = TextEditingController(text: editing?.description);
  var positionId = editing?.positionId;

  showAppBottomSheet<void>(
    context,
    title: editing == null ? 'Ishchi qo\'shish' : 'Ishchini tahrirlash',
    heightFactor: 0.85,
    child: StatefulBuilder(
      builder: (context, setState) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: nameController, label: 'Ism'),
            const SizedBox(height: AppSpacing.md),
            AppPhoneField(controller: phoneController, label: 'Telefon'),
            const SizedBox(height: AppSpacing.md),
            AppPhoneField(controller: additionalPhoneController, label: 'Qo\'shimcha telefon'),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: () async {
                final selected = await showAppSelectionSheet<int?>(
                  context,
                  title: 'Lavozimni tanlang',
                  selectedValue: positionId,
                  items: positions.map((p) => AppSelectionItem(value: p.id, label: p.name)).toList(),
                );
                if (selected != null) setState(() => positionId = selected);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Lavozim'),
                child: Text(
                  positions.where((p) => p.id == positionId).map((p) => p.name).firstOrNull ?? 'Tanlanmagan',
                ),
              ),
            ),
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
          if (name.isEmpty || !PhoneFormatter.isValid(phoneController.text)) return;
          final failure = editing == null
              ? await cubit.submitCreate(
                  name: name,
                  phone: phoneController.text,
                  additionalPhone: additionalPhoneController.text,
                  positionId: positionId,
                  description: descriptionController.text.trim(),
                )
              : await cubit.submitUpdate(
                  editing.id,
                  name: name,
                  phone: phoneController.text,
                  additionalPhone: additionalPhoneController.text,
                  positionId: positionId,
                  description: descriptionController.text.trim(),
                );
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
