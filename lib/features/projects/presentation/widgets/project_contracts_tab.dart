import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_money_field.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/media/app_file_attachment.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../../../../core/widgets/sheets/app_selection_sheet.dart';
import '../../../../core/widgets/states/app_empty_state.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../../../core/widgets/typography/money_text.dart';
import '../../../documents/data/document_models.dart';
import '../../../documents/data/documents_repository.dart';
import '../../data/project_models.dart';
import '../../data/projects_repository.dart';
import '../cubit/project_subtabs_cubit.dart';

/// Tab A: Shartnomalar (MOBILE_APP_TZ.md 10.4-A).
class ProjectContractsTab extends StatelessWidget {
  const ProjectContractsTab({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectContractsCubit(getIt<ProjectsRepository>(), projectId)..load(),
      child: _View(projectId: projectId),
    );
  }
}

class _View extends StatelessWidget {
  const _View({required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectContractsCubit, ListState<ProjectContract>>(
      builder: (context, state) {
        return Stack(
          children: [
            switch (state) {
              ListLoading() => const AppSkeletonList(),
              ListError(:final failure) =>
                AppErrorState(failure: failure, onRetry: () => context.read<ProjectContractsCubit>().load()),
              ListLoaded(:final items) => items.isEmpty
                  ? const AppEmptyState(title: 'Shartnomalar yo\'q', icon: Icons.description_outlined)
                  : RefreshIndicator(
                      onRefresh: () => context.read<ProjectContractsCubit>().load(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 80),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, i) {
                          final c = items[i];
                          return AppCard(
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: context.colors.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.description_outlined, color: context.colors.primary, size: 20),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.workTypeName,
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      if (c.description.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Text(c.description, style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
                                        ),
                                      const SizedBox(height: 4),
                                      MoneyText(c.summa, size: MoneySize.list),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            },
            Positioned(
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: FloatingActionButton(
                heroTag: null,
                onPressed: () => _showContractForm(context, projectId),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }
}

void _showContractForm(BuildContext context, int projectId) {
  final cubit = context.read<ProjectContractsCubit>();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  int? workTypeId;
  List<int> fileIds = [];

  showAppBottomSheet<void>(
    context,
    title: 'Shartnoma qo\'shish',
    heightFactor: 0.75,
    child: StatefulBuilder(
      builder: (context, setState) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () async {
                final workTypesResult = await getIt<DocumentsRepository>().getWorkTypes();
                final workTypes = workTypesResult.dataOrNull ?? <SimpleDocument>[];
                if (!context.mounted) return;
                final selected = await showAppSelectionSheet<int>(
                  context,
                  title: 'Ish turini tanlang',
                  selectedValue: workTypeId,
                  items: workTypes.map((w) => AppSelectionItem(value: w.id, label: w.name)).toList(),
                );
                if (selected != null) setState(() => workTypeId = selected);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Ish turi'),
                child: Text(workTypeId == null ? 'Tanlanmagan' : 'Tanlandi'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(controller: descriptionController, label: 'Tavsif', maxLines: 3, minLines: 2),
            const SizedBox(height: AppSpacing.md),
            AppMoneyField(controller: amountController, currencyLabel: ''),
            const SizedBox(height: AppSpacing.md),
            AppFileAttachment(onFilesChanged: (files) => fileIds = files.map((f) => f.id).toList()),
          ],
        ),
      ),
    ),
    stickyAction: Builder(
      builder: (sheetContext) => AppButton.primary(
        label: 'Saqlash',
        onPressed: () async {
          if (workTypeId == null || descriptionController.text.trim().isEmpty || amountController.text.isEmpty) {
            AppSnackbar.error(sheetContext, 'Barcha maydonlarni to\'ldiring');
            return;
          }
          final result = await getIt<ProjectsRepository>().createContract(
            projectId: projectId,
            workTypeId: workTypeId!,
            description: descriptionController.text.trim(),
            summa: Decimal.parse(amountController.text),
            fileIds: fileIds.isEmpty ? null : fileIds,
          );
          result.when(
            success: (_) {
              cubit.load();
              if (sheetContext.mounted) Navigator.of(sheetContext).pop();
            },
            failure: (f) => AppSnackbar.error(sheetContext, f.message),
          );
        },
      ),
    ),
  );
}
