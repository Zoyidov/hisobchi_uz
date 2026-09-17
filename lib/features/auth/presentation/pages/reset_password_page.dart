import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../auth_navigation.dart';
import '../cubit/reset_password_cubit.dart';

/// Yangi parol o'rnatish — javobda token keladi (MOBILE_APP_TZ.md 5.7).
class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key, required this.phone, required this.otpCode});

  final String phone;
  final String otpCode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ResetPasswordCubit(getIt<AuthRepository>()),
      child: _ResetPasswordView(phone: phone, otpCode: otpCode),
    );
  }
}

class _ResetPasswordView extends StatefulWidget {
  const _ResetPasswordView({required this.phone, required this.otpCode});
  final String phone;
  final String otpCode;

  @override
  State<_ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<_ResetPasswordView> {
  final _passwordController = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yangi parol')),
      body: SafeArea(
        child: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
          listener: (context, state) {
            if (state is ResetPasswordSuccess) {
              AuthNavigation.completeAuthAndOfferPincode(context, state.token);
            } else if (state is ResetPasswordFailed) {
              AppSnackbar.error(context, state.failure.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is ResetPasswordSubmitting;
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    controller: _passwordController,
                    label: 'Yangi parol',
                    obscureText: _obscure,
                    autofocus: true,
                    errorText: _error,
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton.primary(
                    label: 'Saqlash',
                    isLoading: isLoading,
                    onPressed: () {
                      final error = Validators.password(_passwordController.text);
                      setState(() => _error = error);
                      if (error != null) return;
                      context.read<ResetPasswordCubit>().submit(
                            phone: widget.phone,
                            otpCode: widget.otpCode,
                            password: _passwordController.text,
                          );
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
