import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/states/app_empty_state.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../../partners/data/partner_models.dart';
import '../../data/installments_repository.dart';
import '../cubit/partner_installments_cubit.dart';
import 'installment_card.dart';

/// Hamkor kartochkasidagi "Bo'lib to'lash" tabi (MOBILE_APP_TZ.md 8.5, 9.9).
class PartnerInstallmentsTab extends StatelessWidget {
  const PartnerInstallmentsTab({super.key, required this.partner});

  final Partner partner;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PartnerInstallmentsCubit(getIt<InstallmentsRepository>(), partner.id)..load(),
      child: _View(partner: partner),
    );
  }
}

class _View extends StatelessWidget {
  const _View({required this.partner});
  final Partner partner;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PartnerInstallmentsCubit, PartnerInstallmentsState>(
      builder: (context, state) {
        return switch (state) {
          PartnerInstallmentsLoading() => const AppSkeletonList(),
          PartnerInstallmentsError(:final failure) =>
            AppErrorState(failure: failure, onRetry: () => context.read<PartnerInstallmentsCubit>().load()),
          PartnerInstallmentsLoaded(:final plans) => plans.isEmpty
              ? AppEmptyState(
                  title: 'Bo\'lib to\'lash rejasi yo\'q',
                  description: 'Katta summani qismlarga bo\'lib to\'lash uchun reja yarating.',
                  icon: Icons.calendar_view_month_rounded,
                  actionLabel: 'Reja yaratish',
                  onAction: () => _create(context),
                )
              : RefreshIndicator(
                  onRefresh: () => context.read<PartnerInstallmentsCubit>().refresh(),
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      AppButton.secondary(
                        label: '+ Reja yaratish',
                        expand: true,
                        onPressed: () => _create(context),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      for (final plan in plans)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: InstallmentCard(
                            plan: plan,
                            onTap: () async {
                              await context.push(RoutePaths.installmentDetail(plan.id));
                              if (context.mounted) context.read<PartnerInstallmentsCubit>().refresh();
                            },
                          ),
                        ),
                    ],
                  ),
                ),
        };
      },
    );
  }

  Future<void> _create(BuildContext context) async {
    await context.push(RoutePaths.installmentCreate(partner.id), extra: partner);
    if (context.mounted) context.read<PartnerInstallmentsCubit>().refresh();
  }
}
