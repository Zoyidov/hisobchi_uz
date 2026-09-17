import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/phone_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_phone_field.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../data/staff_repository.dart';
import '../cubit/staff_create_cubit.dart';
import '../widgets/permission_group_list.dart';

/// Xodim qo'shish — 3 qadam (MOBILE_APP_TZ.md 15.1).
class StaffCreatePage extends StatelessWidget {
  const StaffCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StaffCreateCubit(getIt<StaffRepository>())..loadPermissionGroups(),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xodim qo\'shish')),
      body: SafeArea(
        child: BlocConsumer<StaffCreateCubit, StaffCreateState>(
          listener: (context, state) {
            if (state.success) {
              AppSnackbar.success(context, 'Xodim qo\'shildi');
              Navigator.of(context).pop();
            } else if (state.error != null) {
              AppSnackbar.error(context, state.error!.message);
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: _StepIndicator(step: state.step),
                ),
                Expanded(
                  child: switch (state.step) {
                    0 => const _PhoneStep(),
                    1 => const _OtpStep(),
                    _ => const _DetailsStep(),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final labels = ['Telefon', 'SMS Kod', 'Ma\'lumotlar'];

    return Row(
      children: List.generate(3, (i) {
        final active = i <= step;
        final current = i == step;
        return Expanded(
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: current
                      ? colors.primary
                      : active
                          ? colors.primary.withValues(alpha: 0.2)
                          : colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: current ? colors.primary : colors.borderSubtle,
                  ),
                ),
                alignment: Alignment.center,
                child: active && !current
                    ? Icon(Icons.check_rounded, size: 16, color: colors.primary)
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: current
                              ? Colors.white
                              : active
                                  ? colors.primary
                                  : colors.textTertiary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
              ),
              const SizedBox(height: 6),
              Text(
                labels[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: current ? FontWeight.w600 : FontWeight.w400,
                  color: current
                      ? colors.textPrimary
                      : active
                          ? colors.textSecondary
                          : colors.textTertiary,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _PhoneStep extends StatefulWidget {
  const _PhoneStep();
  @override
  State<_PhoneStep> createState() => _PhoneStepState();
}

class _PhoneStepState extends State<_PhoneStep> {
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StaffCreateCubit>().state;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPhoneField(controller: _phoneController, label: 'Xodim telefoni', onChanged: (_) => setState(() {})),
          const SizedBox(height: AppSpacing.lg),
          AppButton.primary(
            label: 'Davom etish',
            isLoading: state.isLoading,
            onPressed: PhoneFormatter.isValid(_phoneController.text)
                ? () => context.read<StaffCreateCubit>().submitPhone(_phoneController.text)
                : null,
          ),
        ],
      ),
    );
  }
}

class _OtpStep extends StatefulWidget {
  const _OtpStep();
  @override
  State<_OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<_OtpStep> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = context.watch<StaffCreateCubit>().state;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(PhoneFormatter.toDisplay(state.phone), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          PinCodeTextField(
            appContext: context,
            length: 4,
            controller: _controller,
            autoDisposeControllers: false,
            autoFocus: true,
            keyboardType: TextInputType.number,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: AppRadius.mediumRadius,
              fieldHeight: 56,
              fieldWidth: 52,
              activeColor: colors.primary,
              selectedColor: colors.primary,
              inactiveColor: colors.border,
              activeFillColor: colors.surfaceSecondary,
              selectedFillColor: colors.surfaceSecondary,
              inactiveFillColor: colors.surfaceSecondary,
            ),
            onChanged: (_) {},
            onCompleted: (code) => context.read<StaffCreateCubit>().submitOtp(code),
          ),
          if (state.isLoading) const Padding(padding: EdgeInsets.only(top: 16), child: Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}

class _DetailsStep extends StatefulWidget {
  const _DetailsStep();
  @override
  State<_DetailsStep> createState() => _DetailsStepState();
}

class _DetailsStepState extends State<_DetailsStep> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StaffCreateCubit>();
    final state = context.watch<StaffCreateCubit>().state;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(controller: _nameController, label: 'Ism'),
          const SizedBox(height: AppSpacing.md),
          AppTextField(controller: _passwordController, label: 'Parol', obscureText: true),
          const SizedBox(height: AppSpacing.lg),
          Text('Ruxsatlar', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          PermissionGroupList(
            groups: state.permissionGroups,
            selected: state.selectedPermissions,
            onToggle: cubit.togglePermission,
            onToggleCategory: cubit.toggleAllInCategory,
          ),
          AppButton.primary(
            label: 'Saqlash',
            isLoading: state.isLoading,
            onPressed: () {
              final nameError = Validators.required(_nameController.text);
              final passwordError = Validators.password(_passwordController.text);
              if (nameError != null || passwordError != null) {
                AppSnackbar.error(context, nameError ?? passwordError!);
                return;
              }
              cubit.submitDetails(name: _nameController.text.trim(), password: _passwordController.text);
            },
          ),
        ],
      ),
    );
  }
}
