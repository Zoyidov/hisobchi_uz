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
import '../../../../core/widgets/misc/app_segmented_control.dart';
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

/// Tab C: Xarajatlar (MOBILE_APP_TZ.md 10.4-C).
class ProjectCostsTab extends StatelessWidget {
  const ProjectCostsTab({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectCostsCubit(getIt<ProjectsRepository>(), projectId)..load(),
      child: _View(projectId: projectId),
    );
  }
}

class _View extends StatelessWidget {
  const _View({required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectCostsCubit, ListState<ProjectCost>>(
      builder: (context, state) {
        return Stack(
          children: [
            switch (state) {
              ListLoading() => const AppSkeletonList(),
              ListError(:final failure) =>
                AppErrorState(failure: failure, onRetry: () => context.read<ProjectCostsCubit>().load()),
              ListLoaded(:final items) => items.isEmpty
                  ? const AppEmptyState(title: 'Xarajatlar yo\'q', icon: Icons.trending_down_rounded)
                  : RefreshIndicator(
                      onRefresh: () => context.read<ProjectCostsCubit>().load(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 80),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, i) {
                          final cost = items[i];
                          return AppCard(
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: context.colors.error.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.arrow_upward_rounded, color: context.colors.error, size: 20),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cost.costTypeName,
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 2),
                                      MoneyText(cost.summa, currencyTypeId: cost.currencyTypeId, colorOverride: context.colors.error, size: MoneySize.list),
                                      if (cost.workerName != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Text('Ishchi: ${cost.workerName}', style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
                                        ),
                                      if (cost.description != null && cost.description!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Text(cost.description!, style: TextStyle(color: context.colors.textSecondary, fontSize: 13)),
                                        ),
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
                onPressed: () => _showCostForm(context, projectId),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }
}

void _showCostForm(BuildContext context, int projectId) {
  final cubit = context.read<ProjectCostsCubit>();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  var currencyTypeId = 1;
  int? costTypeId;
  String? costTypeName;
  bool isWorkerJoin = false;
  int? workerId;
  String? workerName;
  List<int> fileIds = [];

  showAppBottomSheet<void>(
    context,
    title: 'Xarajat qo\'shish',
    heightFactor: 0.85,
    child: StatefulBuilder(
      builder: (context, setState) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () async {
                final result = await getIt<DocumentsRepository>().getCostTypes();
                final types = result.dataOrNull ?? <CostType>[];
                if (!context.mounted) return;
                final selected = await showAppSelectionSheet<CostType>(
                  context,
                  title: 'Xarajat turini tanlang',
                  items: types.map((t) => AppSelectionItem(value: t, label: t.name)).toList(),
                );
                if (selected != null) {
                  setState(() {
                    costTypeId = selected.id;
                    costTypeName = selected.name;
                    isWorkerJoin = selected.isWorkerJoin;
                    if (!isWorkerJoin) workerId = null;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Xarajat turi'),
                child: Text(costTypeName ?? 'Tanlanmagan'),
              ),
            ),
            if (isWorkerJoin) ...[
              const SizedBox(height: AppSpacing.md),
              InkWell(
                onTap: () async {
                  final result = await getIt<DocumentsRepository>().getWorkers(notInProjectId: null);
                  final workers = result.dataOrNull ?? <Worker>[];
                  if (!context.mounted) return;
                  final selected = await showAppSelectionSheet<Worker>(
                    context,
                    title: 'Ishchini tanlang',
                    items: workers.map((w) => AppSelectionItem(value: w, label: w.name)).toList(),
                  );
                  if (selected != null) {
                    setState(() {
                      workerId = selected.id;
                      workerName = selected.name;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Ishchi'),
                  child: Text(workerName ?? 'Tanlanmagan'),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            AppSegmentedControl<int>(
              value: currencyTypeId,
              segments: const [AppSegment(value: 1, label: 'UZS'), AppSegment(value: 2, label: 'USD')],
              onChanged: (v) => setState(() => currencyTypeId = v),
            ),
            const SizedBox(height: AppSpacing.md),
            AppMoneyField(controller: amountController, currencyLabel: currencyTypeId == 1 ? 'UZS' : 'USD'),
            const SizedBox(height: AppSpacing.md),
            AppTextField(controller: descriptionController, label: 'Izoh (ixtiyoriy)', maxLines: 2, minLines: 1),
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
          if (costTypeId == null || amountController.text.isEmpty) {
            AppSnackbar.error(sheetContext, 'Xarajat turi va summani kiriting');
            return;
          }
          final result = await getIt<ProjectsRepository>().createCost(
            projectId: projectId,
            costTypeId: costTypeId!,
            currencyTypeId: currencyTypeId,
            summa: Decimal.parse(amountController.text),
            description: descriptionController.text.trim(),
            workerId: workerId,
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
