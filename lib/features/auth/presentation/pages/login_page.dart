import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/services/device_info_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/phone_formatter.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../auth_navigation.dart';
import '../cubit/login_cubit.dart';

/// Parol bilan kirish (MOBILE_APP_TZ.md 5.6).
class LoginPage extends StatelessWidget {
  const LoginPage({super.key, required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(getIt<AuthRepository>(), getIt<DeviceInfoService>()),
      child: _LoginView(phone: phone),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView({required this.phone});
  final String phone;

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kirish')),
      body: SafeArea(
        child: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              AuthNavigation.completeAuthAndOfferPincode(context, state.token);
            } else if (state is LoginFailed) {
              AppSnackbar.error(context, state.failure.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is LoginSubmitting;
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.phone_iphone_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Telefon raqami',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              PhoneFormatter.toDisplay(widget.phone),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    controller: _passwordController,
                    label: 'Parol',
                    obscureText: _obscure,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppButton.text(
                      label: 'Parolni unutdingizmi?',
                      onPressed: () =>
                          context.push(RoutePaths.forgotPassword, extra: {'phone': widget.phone}),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton.primary(
                    label: 'Kirish',
                    isLoading: isLoading,
                    onPressed: _passwordController.text.isEmpty
                        ? null
                        : () => context
                            .read<LoginCubit>()
                            .submit(phone: widget.phone, password: _passwordController.text),
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
