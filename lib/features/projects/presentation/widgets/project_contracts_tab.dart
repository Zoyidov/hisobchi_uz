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
import '../../../../core/widgets/states/app_empty_state.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../../../core/widgets/typography/money_text.dart';
import '../../data/project_models.dart';
import '../../data/projects_repository.dart';
import '../cubit/project_subtabs_cubit.dart';
import 'work_type_selection_sheet.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/localization/app_localization_extension.dart';

/// Tab A: Shartnomalar (MOBILE_APP_TZ.md 10.4-A).
class ProjectContractsTab extends StatelessWidget {
  const ProjectContractsTab({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProjectContractsCubit(getIt<ProjectsRepository>(), projectId)..load(),
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
              ListError(:final failure) => AppErrorState(
                failure: failure,
                onRetry: () => context.read<ProjectContractsCubit>().load(),
              ),
              ListLoaded(:final items) =>
                items.isEmpty
                    ? AppEmptyState(
                        title: context.l10n.contractsEmpty,
                        icon: AppIcons.file,
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            context.read<ProjectContractsCubit>().load(),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.md,
                            80,
                          ),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, i) {
                            final c = items[i];
                            return AppCard(
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: context.colors.primary.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.md,
                                      ),
                                    ),
                                    child: Icon(
                                      AppIcons.file,
                                      color: context.colors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.workTypeName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        if (c.description.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 2,
                                            ),
                                            child: Text(
                                              c.description,
                                              style: TextStyle(
                                                color: context
                                                    .colors
                                                    .textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: AppSpacing.xxs),
                                        MoneyText(
                                          c.summa,
                                          size: MoneySize.list,
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
              bottom: 82.0 + MediaQuery.of(context).padding.bottom,
              child: FloatingActionButton(
                heroTag: null,
                onPressed: () => _showContractForm(context, projectId),
                child: const Icon(AppIcons.add),
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<void> _showContractForm(BuildContext context, int projectId) async {
  final cubit = context.read<ProjectContractsCubit>();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  int? workTypeId;
  String? workTypeName;
  List<int> fileIds = [];
  bool filesUploading = false;
  final saving = ValueNotifier(false);
  final descriptionError = ValueNotifier<String?>(null);

  await showAppBottomSheet<void>(
    context,
    title: context.l10n.contractAdd,
    heightFactor: 0.75,
    child: _ContractFormLifetime(
      resources: [
        saving,
        descriptionError,
        descriptionController,
        amountController,
      ],
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
                InkWell(
                  onTap: () async {
                    final selected = await showWorkTypeSelectionSheet(
                      context,
                      selectedId: workTypeId,
                    );
                    if (selected != null && context.mounted) {
                      setState(() {
                        workTypeId = selected.id;
                        workTypeName = selected.name;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: context.l10n.docWorkType,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            workTypeName ?? context.l10n.workTypeSelect,
                          ),
                        ),
                        const Icon(AppIcons.chevronDown, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ValueListenableBuilder<String?>(
                  valueListenable: descriptionError,
                  builder: (context, error, _) => AppTextField(
                    controller: descriptionController,
                    label: context.l10n.commonDescriptionRequired,
                    hint: context.l10n.contractDescriptionHint,
                    errorText: error,
                    onChanged: (_) => descriptionError.value = null,
                    maxLines: 3,
                    minLines: 2,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppMoneyField(controller: amountController, currencyLabel: ''),
                const SizedBox(height: AppSpacing.md),
                AppFileAttachment(
                  onUploadingChanged: (value) => filesUploading = value,
                  uploadType: 'contract',
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
        label: isSaving ? context.l10n.commonSaving : context.l10n.commonSave,
        isLoading: isSaving,
        onPressed: () async {
          if (filesUploading) {
            AppSnackbar.error(sheetContext, context.l10n.fileWaitThenSave);
            return;
          }
          if (saving.value) return;
          if (descriptionController.text.trim().isEmpty) {
            descriptionError.value = context.l10n.contractDescriptionRequired;
            return;
          }
          descriptionError.value = null;
          if (workTypeId == null || amountController.text.isEmpty) {
            AppSnackbar.error(
              sheetContext,
              context.l10n.contractEnterWorkTypeAmount,
            );
            return;
          }
          final amount = Decimal.tryParse(amountController.text);
          if (amount == null || amount <= Decimal.zero) {
            AppSnackbar.error(
              sheetContext,
              context.l10n.validationAmountPositive,
            );
            return;
          }
          saving.value = true;
          final result = await getIt<ProjectsRepository>().createContract(
            projectId: projectId,
            workTypeId: workTypeId!,
            description: descriptionController.text.trim(),
            summa: amount,
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

// Dispose form resources when the closing animation has unmounted the sheet.
class _ContractFormLifetime extends StatefulWidget {
  const _ContractFormLifetime({required this.resources, required this.child});
  final List<ChangeNotifier> resources;
  final Widget child;

  @override
  State<_ContractFormLifetime> createState() => _ContractFormLifetimeState();
}

class _ContractFormLifetimeState extends State<_ContractFormLifetime> {
  @override
  void dispose() {
    for (final resource in widget.resources) {
      resource.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
