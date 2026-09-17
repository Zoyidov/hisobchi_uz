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
import '../../../../core/widgets/states/app_empty_state.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../../../core/widgets/typography/money_text.dart';
import '../../data/project_models.dart';
import '../../data/projects_repository.dart';
import '../cubit/project_subtabs_cubit.dart';

/// Tab B: Daromadlar (MOBILE_APP_TZ.md 10.4-B).
class ProjectIncomesTab extends StatelessWidget {
  const ProjectIncomesTab({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectIncomesCubit(getIt<ProjectsRepository>(), projectId)..load(),
      child: _View(projectId: projectId),
    );
  }
}

class _View extends StatelessWidget {
  const _View({required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectIncomesCubit, ListState<ProjectIncome>>(
      builder: (context, state) {
        return Stack(
          children: [
            switch (state) {
              ListLoading() => const AppSkeletonList(),
              ListError(:final failure) =>
                AppErrorState(failure: failure, onRetry: () => context.read<ProjectIncomesCubit>().load()),
              ListLoaded(:final items) => items.isEmpty
                  ? const AppEmptyState(title: 'Daromadlar yo\'q', icon: Icons.trending_up_rounded)
                  : RefreshIndicator(
                      onRefresh: () => context.read<ProjectIncomesCubit>().load(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 80),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, i) {
                          final income = items[i];
                          return AppCard(
                            child: Row(
                              children: [
                                Icon(Icons.arrow_downward_rounded, color: context.colors.success),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      MoneyText(income.summa, currencyTypeId: income.currencyTypeId, colorOverride: context.colors.success),
                                      if (income.description != null && income.description!.isNotEmpty)
                                        Text(income.description!, style: TextStyle(color: context.colors.textSecondary, fontSize: 13)),
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
              child: FloatingActionButton(onPressed: () => _showIncomeForm(context, projectId), child: const Icon(Icons.add)),
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

  showAppBottomSheet<void>(
    context,
    title: 'Daromad qo\'shish',
    heightFactor: 0.7,
    child: StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
          if (amountController.text.isEmpty) return;
          final result = await getIt<ProjectsRepository>().createIncome(
            projectId: projectId,
            currencyTypeId: currencyTypeId,
            summa: Decimal.parse(amountController.text),
            description: descriptionController.text.trim(),
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
