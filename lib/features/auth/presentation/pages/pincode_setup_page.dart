import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../core/cubits/user_cubit.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../auth_navigation.dart';
import '../cubit/pincode_setup_cubit.dart';

/// PIN yaratish — login/register'dan keyingi ixtiyoriy taklif ekrani
/// (MOBILE_APP_TZ.md 5.6, 5.8).
class PincodeSetupPage extends StatelessWidget {
  const PincodeSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PincodeSetupCubit(getIt<AuthRepository>(), getIt<SecureStorageService>()),
      child: const _PincodeSetupView(),
    );
  }
}

class _PincodeSetupView extends StatefulWidget {
  const _PincodeSetupView();

  @override
  State<_PincodeSetupView> createState() => _PincodeSetupViewState();
}

class _PincodeSetupViewState extends State<_PincodeSetupView> {
  String? _firstCode;
  String? _error;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onCompleted(String code) {
    if (_firstCode == null) {
      setState(() {
        _firstCode = code;
        _error = null;
        _controller.clear();
      });
      return;
    }
    if (code != _firstCode) {
      setState(() {
        _firstCode = null;
        _error = 'PIN kodlar mos emas';
        _controller.clear();
      });
      return;
    }
    final userId = context.read<UserCubit>().currentUserOrNull?.userId;
    if (userId == null) {
      AuthNavigation.goToNextAfterPincode(context);
      return;
    }
    context.read<PincodeSetupCubit>().save(userId: userId, pincode: code);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: SafeArea(
        child: BlocListener<PincodeSetupCubit, PincodeSetupState>(
          listener: (context, state) {
            if (state is PincodeSetupSuccess) {
              AuthNavigation.goToNextAfterPincode(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Icon(Icons.shield_outlined, size: 32, color: colors.primary),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Ilovani himoyalang',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _firstCode == null ? '4 xonali PIN yarating' : 'PIN kodni takrorlang',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                PinCodeTextField(
                  key: ValueKey(_firstCode),
                  appContext: context,
                  length: 4,
                  controller: _controller,
                  autoDisposeControllers: false,
                  obscureText: true,
                  autoFocus: true,
                  keyboardType: TextInputType.number,
                  enableActiveFill: true,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: AppRadius.mediumRadius,
                    fieldHeight: 60,
                    fieldWidth: 56,
                    borderWidth: 1.5,
                    activeColor: colors.primary,
                    selectedColor: colors.primary,
                    inactiveColor: _error != null ? colors.error : colors.border.withValues(alpha: 0.8),
                    activeFillColor: colors.surface,
                    selectedFillColor: colors.surface,
                    inactiveFillColor: colors.surfaceSecondary.withValues(alpha: 0.6),
                  ),
                  onChanged: (_) {},
                  onCompleted: _onCompleted,
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(_error!, style: TextStyle(color: colors.error), textAlign: TextAlign.center),
                ],
                const Spacer(flex: 2),
                AppButton.text(label: 'Keyinroq', onPressed: () => AuthNavigation.goToNextAfterPincode(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
