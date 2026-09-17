import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/phone_formatter.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../cubit/otp_cubit.dart';

/// OTP tasdiqlash — 4 xonali, 60s countdown, auto-submit (MOBILE_APP_TZ.md 5.4).
class OtpPage extends StatelessWidget {
  const OtpPage({super.key, required this.phone, required this.mode});

  final String phone;
  final OtpMode mode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OtpCubit(getIt<AuthRepository>(), phone: phone, mode: mode),
      child: _OtpView(phone: phone, mode: mode),
    );
  }
}

class _OtpView extends StatefulWidget {
  const _OtpView({required this.phone, required this.mode});
  final String phone;
  final OtpMode mode;

  @override
  State<_OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<_OtpView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: BlocConsumer<OtpCubit, OtpState>(
          listener: (context, state) {
            if (state is OtpVerified) {
              if (widget.mode == OtpMode.register) {
                context.push(RoutePaths.register, extra: {'phone': widget.phone, 'verifyToken': state.payload});
              } else {
                context.push(RoutePaths.resetPassword, extra: {'phone': widget.phone, 'otpCode': state.payload});
              }
            } else if (state is OtpInvalid) {
              _controller.clear();
              AppSnackbar.error(context, state.failure.message);
            }
          },
          builder: (context, state) {
            final isVerifying = state is OtpVerifying;
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  Text(PhoneFormatter.toDisplay(widget.phone), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'SMS orqali yuborilgan 4 xonali kodni kiriting',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AbsorbPointer(
                    absorbing: isVerifying,
                    child: PinCodeTextField(
                      appContext: context,
                      length: 4,
                      controller: _controller,
                      autoDisposeControllers: false,
                      autoFocus: true,
                      keyboardType: TextInputType.number,
                      animationType: AnimationType.fade,
                      enableActiveFill: true,
                      textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: AppRadius.mediumRadius,
                        fieldHeight: 60,
                        fieldWidth: 56,
                        borderWidth: 1.5,
                        activeColor: colors.primary,
                        selectedColor: colors.primary,
                        inactiveColor: colors.border.withValues(alpha: 0.8),
                        activeFillColor: colors.surface,
                        selectedFillColor: colors.surface,
                        inactiveFillColor: colors.surfaceSecondary.withValues(alpha: 0.6),
                      ),
                      onChanged: (_) {},
                      onCompleted: (code) => context.read<OtpCubit>().submit(code),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (isVerifying)
                    const Center(child: CircularProgressIndicator())
                  else
                    Center(
                      child: state.secondsRemaining > 0
                          ? Text('Qayta yuborish 00:${state.secondsRemaining.toString().padLeft(2, '0')}')
                          : AppButton.text(
                              label: 'Qayta yuborish',
                              onPressed: () => context.read<OtpCubit>().resend(),
                            ),
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
