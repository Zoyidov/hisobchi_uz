import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../data/subscription_models.dart';
import '../cubit/payment_flow_cubit.dart';

/// To'lov oqimi ekrani — buyurtma yaratish → tashqi to'lov → polling
/// (MOBILE_APP_TZ.md 13.4).
Future<bool> showPaymentFlowSheet(
  BuildContext context, {
  required Future<ApiResult<PurchaseOrder>> Function() createOrder,
  required Future<ApiResult<OrderStatus>> Function(String) checkStatus,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BlocProvider(
      create: (_) =>
          PaymentFlowCubit(createOrder: createOrder, checkStatus: checkStatus)
            ..start(),
      child: const _PaymentFlowView(),
    ),
  );
  return result ?? false;
}

class _PaymentFlowView extends StatelessWidget {
  const _PaymentFlowView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PopScope(
      canPop: false,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.sheetTop,
          boxShadow: colors.sheetShadow,
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.xl + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.border.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            BlocConsumer<PaymentFlowCubit, PaymentFlowState>(
              listener: (context, state) {
                if (state is PaymentFlowSuccess) {
                  Future.delayed(const Duration(milliseconds: 1400), () {
                    if (context.mounted) Navigator.of(context).pop(true);
                  });
                }
              },
              builder: (context, state) {
                return switch (state) {
                  PaymentFlowCreatingOrder() => _buildLoadingState(
                      context,
                      title: 'Buyurtma shakllantirilmoqda',
                      subtitle:
                          'To\'lov tizimiga xavfsiz ulanish o\'rnatilmoqda...',
                      icon: Icons.shield_outlined,
                    ),
                  PaymentFlowPolling() => _buildLoadingState(
                      context,
                      title: 'To\'lov tekshirilmoqda',
                      subtitle:
                          'To\'lov ilovasida to\'lovni tasdiqlang. Tekshiruv avtomatik davom etmoqda...',
                      icon: Icons.sync_rounded,
                      showCancel: true,
                    ),
                  PaymentFlowPending(:final orderNumber) => _buildPendingState(
                      context,
                      orderNumber: orderNumber,
                    ),
                  PaymentFlowSuccess() => _buildSuccessState(context),
                  PaymentFlowFailed(:final failure) => _buildFailedState(
                      context,
                      errorMessage: failure?.message,
                    ),
                  PaymentFlowIdle() => const SizedBox.shrink(),
                };
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    bool showCancel = false,
  }) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                strokeWidth: 2.8,
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                backgroundColor: colors.primary.withValues(alpha: 0.15),
              ),
            ),
            Icon(
              icon,
              size: 26,
              color: colors.primary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        if (showCancel) ...[
          const SizedBox(height: AppSpacing.xl),
          AppButton.secondary(
            label: 'To\'lovni bekor qilish',
            size: AppButtonSize.medium,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ],
    );
  }

  Widget _buildPendingState(
    BuildContext context, {
    required String orderNumber,
  }) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: colors.warning.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.hourglass_top_rounded,
            size: 38,
            color: colors.warning,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'To\'lov kutilmoqda',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Agar to\'lov ilovasi orqali to\'lovni amalga oshirgan bo\'lsangiz, "Tekshirish" tugmasini bosing',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        if (orderNumber.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Text(
              '№ $orderNumber',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: 'Bekor qilish',
                size: AppButtonSize.medium,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppButton.primary(
                label: 'Tekshirish',
                size: AppButtonSize.medium,
                onPressed: () =>
                    context.read<PaymentFlowCubit>().checkNow(orderNumber),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colors.success.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_rounded,
            size: 48,
            color: colors.success,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Muvaffaqiyatli to\'landi!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.success,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'To\'lov qabul qilindi va xizmatlar yangilandi',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildFailedState(BuildContext context, {String? errorMessage}) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: colors.error.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline_rounded,
            size: 38,
            color: colors.error,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'To\'lov amalga oshmadi',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          errorMessage ?? 'To\'lov bekor qilindi yoki xatolik yuz berdi',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: 'Yopish',
                size: AppButtonSize.medium,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppButton.primary(
                label: 'Qayta urinish',
                size: AppButtonSize.medium,
                onPressed: () => context.read<PaymentFlowCubit>().start(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
