import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/paging/paged_list_cubit.dart';
import '../../../../core/widgets/lists/app_paged_list_view.dart';
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
import '../../../../core/widgets/typography/money_text.dart';
import '../../data/project_models.dart';
import '../../data/projects_repository.dart';
import '../cubit/project_subtabs_cubit.dart';
import 'project_entry_detail_sheet.dart';
import 'project_form_lifetime.dart';

/// Tab B: Daromadlar (MOBILE_APP_TZ.md 10.4-B).
class ProjectIncomesTab extends StatelessWidget {
  const ProjectIncomesTab({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProjectIncomesCubit(getIt<ProjectsRepository>(), projectId)..load(),
      child: _View(projectId: projectId),
    );
  }
}

class _View extends StatelessWidget {
  const _View({required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectIncomesCubit, PagedListState<ProjectIncome>>(
      builder: (context, state) {
        return Stack(
          children: [
            AppPagedListView<ProjectIncome>(
              state: state,
              onLoadMore: context.read<ProjectIncomesCubit>().loadMore,
              onRefresh: context.read<ProjectIncomesCubit>().refresh,
              onRetry: context.read<ProjectIncomesCubit>().loadFirst,
              emptyTitle: 'Daromadlar yo‘q',
              emptyIcon: Icons.trending_up_rounded,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                160,
              ),
              itemBuilder: (context, income, index) {
                return AppCard(
                  onTap: () => showProjectIncomeDetail(context, income),
                  hasShadow: false,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.colors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_downward_rounded,
                          color: context.colors.success,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MoneyText(
                              income.summa,
                              currencyTypeId: income.currencyTypeId,
                              colorOverride: context.colors.success,
                              size: MoneySize.list,
                            ),
                            if (income.description != null &&
                                income.description!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  income.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: context.colors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: context.colors.textTertiary,
                        size: 19,
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              right: AppSpacing.md,
              bottom: 82.0 + MediaQuery.of(context).padding.bottom,
              child: FloatingActionButton(
                heroTag: null,
                onPressed: () => _showIncomeForm(context, projectId),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }
}

void _showIncomeForm(BuildContext context, int projectId) {
  final cubit = context.read<ProjectIncomesCubit>();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  var currencyTypeId = 1;
  List<int> fileIds = [];
  bool filesUploading = false;
  final saving = ValueNotifier(false);

  showAppBottomSheet<void>(
    context,
    title: 'Daromad qo\'shish',
    heightFactor: 0.7,
    child: ProjectFormLifetime(
      resources: [saving, amountController, descriptionController],
      child: ValueListenableBuilder<bool>(
        valueListenable: saving,
        builder: (context, isSaving, child) =>
            AbsorbPointer(absorbing: isSaving, child: child),
        child: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSegmentedControl<int>(
                  value: currencyTypeId,
                  segments: const [
                    AppSegment(value: 1, label: 'UZS'),
                    AppSegment(value: 2, label: 'USD'),
                  ],
                  onChanged: (v) => setState(() => currencyTypeId = v),
                ),
                const SizedBox(height: AppSpacing.md),
                AppMoneyField(
                  controller: amountController,
                  currencyLabel: currencyTypeId == 1 ? 'UZS' : 'USD',
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: descriptionController,
                  label: 'Izoh (ixtiyoriy)',
                  maxLines: 2,
                  minLines: 1,
                ),
                const SizedBox(height: AppSpacing.md),
                AppFileAttachment(
                  onUploadingChanged: (value) => filesUploading = value,
                  uploadType: 'project_income',
                  onFilesChanged: (files) =>
                      fileIds = files.map((f) => f.id).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    stickyAction: ValueListenableBuilder<bool>(
      valueListenable: saving,
      builder: (sheetContext, isSaving, _) => AppButton.primary(
        label: isSaving ? 'Saqlanmoqda…' : 'Saqlash',
        isLoading: isSaving,
        onPressed: () async {
          if (saving.value) return;
          if (filesUploading) {
            AppSnackbar.error(
              sheetContext,
              'Fayl yuklanishini kuting, keyin saqlang.',
            );
            return;
          }

          final amount = Decimal.tryParse(amountController.text);
          if (amount == null || amount <= Decimal.zero) {
            AppSnackbar.error(sheetContext, 'Summa 0 dan katta bo‘lishi kerak');
            return;
          }
          saving.value = true;
          final result = await getIt<ProjectsRepository>().createIncome(
            projectId: projectId,
            currencyTypeId: currencyTypeId,
            summa: amount,
            description: descriptionController.text.trim(),
            fileIds: fileIds.isEmpty ? null : fileIds,
          );
          if (!sheetContext.mounted) return;
          saving.value = false;
          result.when(
            success: (_) {
              if (!cubit.isClosed) cubit.load();
              if (sheetContext.mounted) Navigator.of(sheetContext).pop();
            },
            failure: (f) => AppSnackbar.error(sheetContext, f.message),
          );
        },
      ),
    ),
  );
}
