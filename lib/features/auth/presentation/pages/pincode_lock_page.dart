import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../core/cubits/auth_cubit.dart';
import '../../../../core/cubits/user_cubit.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../auth_navigation.dart';
import '../cubit/pincode_lock_cubit.dart';

/// PIN bilan qulflash ekrani — 5 xato urinishdan keyin parolga majburiy
/// o'tkaziladi (MOBILE_APP_TZ.md 5.8).
class PincodeLockPage extends StatelessWidget {
  const PincodeLockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PincodeLockCubit(getIt<SecureStorageService>()),
      child: const _PincodeLockView(),
    );
  }
}

class _PincodeLockView extends StatefulWidget {
  const _PincodeLockView();

  @override
  State<_PincodeLockView> createState() => _PincodeLockViewState();
}

class _PincodeLockViewState extends State<_PincodeLockView> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PincodeLockCubit>().tryBiometrics();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onUnlocked() async {
    await context.read<UserCubit>().loadMe();
    if (!mounted) return;
    AuthNavigation.goToNextAfterPincode(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<PincodeLockCubit, PincodeLockState>(
          listener: (context, state) {
            if (state is PincodeLockUnlocked) {
              _onUnlocked();
            } else if (state is PincodeLockWrong) {
              _controller.clear();
            } else if (state is PincodeLockExhausted) {
              context.read<AuthCubit>().logout().then((_) {
                if (context.mounted) context.go(RoutePaths.phone);
              });
            }
          },
          builder: (context, state) {
            return Padding(
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
                      child: Icon(Icons.lock_rounded, size: 30, color: colors.primary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'PIN kodni kiriting',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PinCodeTextField(
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
                      inactiveColor: state is PincodeLockWrong ? colors.error : colors.border.withValues(alpha: 0.8),
                      activeFillColor: colors.surface,
                      selectedFillColor: colors.surface,
                      inactiveFillColor: colors.surfaceSecondary.withValues(alpha: 0.6),
                    ),
                    onChanged: (_) {},
                    onCompleted: (code) => context.read<PincodeLockCubit>().verify(code),
                  ),
                  if (state is PincodeLockWrong) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Noto\'g\'ri PIN. Qolgan urinishlar: ${state.remainingAttempts}',
                      style: TextStyle(color: colors.error, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: AppButton.text(
                      label: 'Face ID / Fingerprint orqali kirish',
                      onPressed: () => context.read<PincodeLockCubit>().tryBiometrics(),
                    ),
                  ),
                  const Spacer(flex: 2),
                  AppButton.text(
                    label: 'Parol bilan kirish',
                    onPressed: () async {
                      await context.read<AuthCubit>().logout();
                      if (context.mounted) context.go(RoutePaths.phone);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
