import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_permission.dart';
import '../../../../core/cubits/user_cubit.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/chips/app_status_chip.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/navigation/permission_guard.dart';
import '../../../../core/widgets/navigation/subscription_guard.dart';
import '../../../../core/widgets/sheets/app_confirmation_sheet.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../../../core/widgets/misc/app_progress_bar.dart';
import '../../../../core/widgets/typography/money_text.dart';
import '../../data/installment_models.dart';
import '../../data/installments_repository.dart';
import '../cubit/installment_detail_cubit.dart';
import 'installment_payment_sheet.dart';

/// Reja tafsilotlari (MOBILE_APP_TZ.md 9.5).
class InstallmentDetailPage extends StatelessWidget {
  const InstallmentDetailPage({super.key, required this.planId});

  final int planId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InstallmentDetailCubit(getIt<InstallmentsRepository>(), planId)..load(),
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
        title: const Text('Bo\'lib to\'lash'),
        actions: [
          BlocBuilder<InstallmentDetailCubit, InstallmentDetailState>(
            builder: (context, state) {
              if (state is! InstallmentDetailLoaded) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                onSelected: (value) => _handleMenu(context, value, state.plan),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Tahrirlash')),
                  if (context.read<UserCubit>().currentUserOrNull?.isOwner == true &&
                      state.plan.status == InstallmentPlanStatus.active)
                    const PopupMenuItem(value: 'cancel', child: Text('Bekor qilish')),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<InstallmentDetailCubit, InstallmentDetailState>(
        listener: (context, state) {},
        builder: (context, state) {
          return switch (state) {
            InstallmentDetailLoading() => const AppSkeletonList(),
            InstallmentDetailError(:final failure) =>
              AppErrorState(failure: failure, onRetry: () => context.read<InstallmentDetailCubit>().load()),
            InstallmentDetailLoaded(:final plan) => _Loaded(plan: plan),
          };
        },
      ),
    );
  }

  void _handleMenu(BuildContext context, String action, InstallmentPlan plan) async {
    if (action == 'cancel') {
      final confirmed = await showAppConfirmationSheet(
        context,
        title: 'Rejani bekor qilish',
        description: 'Bu amalni keyin qaytarib bo\'lmaydi.',
      );
      if (!confirmed || !context.mounted) return;
      final error = await context.read<InstallmentDetailCubit>().cancelPlan();
      if (error != null && context.mounted) AppSnackbar.error(context, error.message);
    }
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.plan});
  final InstallmentPlan plan;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return RefreshIndicator(
      onRefresh: () => context.read<InstallmentDetailCubit>().refresh(),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(plan.partnerName, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          MoneyText(plan.totalAmount, currencyTypeId: plan.currencyTypeId, size: MoneySize.display),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              MoneyText(plan.paidAmount, currencyTypeId: plan.currencyTypeId, size: MoneySize.list, colorOverride: colors.success),
              const SizedBox(width: 4),
              const Text('to\'langan'),
              const SizedBox(width: AppSpacing.md),
              MoneyText(plan.remaining, currencyTypeId: plan.currencyTypeId, size: MoneySize.list, colorOverride: colors.error),
              const SizedBox(width: 4),
              const Text('qolgan'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppProgressBar(value: plan.progress),
          const SizedBox(height: AppSpacing.sm),
          _statusChip(plan.status, plan.statusLabel),
          if (plan.note != null && plan.note!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(plan.note!, style: TextStyle(color: colors.textSecondary)),
          ],
          const SizedBox(height: AppSpacing.xl),
          Text('To\'lov grafigi', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          for (final item in plan.items) _ScheduleTile(item: item, currencyTypeId: plan.currencyTypeId),
          const SizedBox(height: AppSpacing.xl),
          if (plan.status == InstallmentPlanStatus.active)
            PermissionGuard(
              permission: AppPermission.installmentsPayment,
              child: SubscriptionActionGuard(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppButton.primary(
                    label: 'To\'lov qabul qilish',
                    onPressed: () async {
                      final updated = await showInstallmentPaymentSheet(context, plan);
                      if (updated != null && context.mounted) {
                        context.read<InstallmentDetailCubit>().refresh();
                      }
                    },
                  ),
                ),
              ),
            ),
          AppButton.secondary(
            label: 'To\'lovlar tarixi',
            onPressed: () => context.push(RoutePaths.installmentPaymentHistory(plan.id), extra: plan.currencyTypeId),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(InstallmentPlanStatus status, String label) {
    final tone = switch (status) {
      InstallmentPlanStatus.active => AppStatusChipTone.info,
      InstallmentPlanStatus.completed => AppStatusChipTone.success,
      InstallmentPlanStatus.cancelled => AppStatusChipTone.neutral,
    };
    return AppStatusChip(label: label, tone: tone);
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({required this.item, required this.currencyTypeId});
  final InstallmentItem item;
  final int currencyTypeId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (tone, label) = switch (item.status) {
      InstallmentItemStatus.paid => (AppStatusChipTone.success, item.statusLabel),
      InstallmentItemStatus.partial => (AppStatusChipTone.info, item.statusLabel),
      InstallmentItemStatus.overdue => (AppStatusChipTone.error, item.statusLabel),
      InstallmentItemStatus.near => (AppStatusChipTone.warning, item.statusLabel),
      InstallmentItemStatus.pending => (AppStatusChipTone.neutral, item.statusLabel),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: item.status == InstallmentItemStatus.overdue ? colors.error : colors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: colors.surfaceSecondary,
            child: Text('${item.itemNumber}', style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MoneyText(item.amount, currencyTypeId: currencyTypeId, size: MoneySize.list),
                if (item.dueDate != null)
                  Text(
                    '${item.dueDate!.day.toString().padLeft(2, '0')}.${item.dueDate!.month.toString().padLeft(2, '0')}.${item.dueDate!.year}'
                    '${item.isAdvance ? ' · Avans' : ''}',
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                  ),
              ],
            ),
          ),
          AppStatusChip(label: label, tone: tone),
        ],
      ),
    );
  }
}
