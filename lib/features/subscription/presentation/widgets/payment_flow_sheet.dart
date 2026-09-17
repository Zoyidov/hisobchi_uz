import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/theme/app_colors.dart';
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
    builder: (context) => BlocProvider(
      create: (_) => PaymentFlowCubit(createOrder: createOrder, checkStatus: checkStatus)..start(),
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
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: BlocConsumer<PaymentFlowCubit, PaymentFlowState>(
          listener: (context, state) {
            if (state is PaymentFlowSuccess) {
              Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) Navigator.of(context).pop(true);
              });
            }
          },
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                switch (state) {
                  PaymentFlowCreatingOrder() => Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: AppSpacing.md),
                        const Text('Buyurtma yaratilmoqda...'),
                      ],
                    ),
                  PaymentFlowPolling() => Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: AppSpacing.md),
                        const Text('To\'lov tekshirilmoqda, biroz kuting...'),
                      ],
                    ),
                  PaymentFlowPending(:final orderNumber) => Column(
                      children: [
                        Icon(Icons.hourglass_top_rounded, size: 48, color: colors.warning),
                        const SizedBox(height: AppSpacing.md),
                        const Text('To\'lov tekshirilmoqda, biroz kuting'),
                        const SizedBox(height: AppSpacing.md),
                        AppButton.secondary(
                          label: 'Tekshirish',
                          expand: false,
                          onPressed: () => context.read<PaymentFlowCubit>().checkNow(orderNumber),
                        ),
                      ],
                    ),
                  PaymentFlowSuccess() => Column(
                      children: [
                        Icon(Icons.check_circle, size: 56, color: colors.success),
                        const SizedBox(height: AppSpacing.md),
                        const Text('Muvaffaqiyatli to\'landi!'),
                      ],
                    ),
                  PaymentFlowFailed() => Column(
                      children: [
                        Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
                        const SizedBox(height: AppSpacing.md),
                        const Text('To\'lov amalga oshmadi'),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppButton.secondary(
                              label: 'Yopish',
                              expand: false,
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            AppButton.primary(
                              label: 'Qayta urinish',
                              expand: false,
                              onPressed: () => context.read<PaymentFlowCubit>().start(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  PaymentFlowIdle() => const SizedBox.shrink(),
                },
              ],
            );
          },
        ),
      ),
    );
  }
}
