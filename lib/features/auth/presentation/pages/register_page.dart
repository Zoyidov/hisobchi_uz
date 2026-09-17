import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/services/device_info_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/phone_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../auth_navigation.dart';
import '../cubit/register_cubit.dart';

/// Ro'yxatdan o'tish — ism + parol (MOBILE_APP_TZ.md 5.5).
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key, required this.phone, required this.verifyToken});

  final String phone;
  final String verifyToken;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(getIt<AuthRepository>(), getIt<DeviceInfoService>()),
      child: _RegisterView(phone: phone, verifyToken: verifyToken),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView({required this.phone, required this.verifyToken});
  final String phone;
  final String verifyToken;

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  Map<String, String> _fieldErrors = {};

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ro\'yxatdan o\'tish')),
      body: SafeArea(
        child: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is RegisterSuccess) {
              AuthNavigation.completeAuthAndOfferPincode(context, state.token);
            } else if (state is RegisterValidationError) {
              setState(() => _fieldErrors = state.fieldErrors);
            } else if (state is RegisterFailed) {
              AppSnackbar.error(context, state.failure.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is RegisterSubmitting;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(PhoneFormatter.toDisplay(widget.phone),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _nameController,
                      label: 'Ism',
                      textCapitalization: TextCapitalization.words,
                      errorText: _fieldErrors['name'],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _passwordController,
                      label: 'Parol',
                      obscureText: _obscure,
                      errorText: _fieldErrors['password'],
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _confirmController,
                      label: 'Parolni takrorlang',
                      obscureText: _obscure,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton.primary(
                      label: 'Ro\'yxatdan o\'tish',
                      isLoading: isLoading,
                      onPressed: () => _submit(context),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    final nameError = Validators.required(_nameController.text);
    final passwordError = Validators.password(_passwordController.text);
    final confirmError = Validators.passwordConfirm(_confirmController.text, _passwordController.text);
    setState(() {
      _fieldErrors = {
        if (nameError != null) 'name': nameError,
        if (passwordError != null) 'password': passwordError,
        if (confirmError != null) 'confirm': confirmError,
      };
    });
    if (_fieldErrors.isNotEmpty) return;

    context.read<RegisterCubit>().submit(
          name: _nameController.text.trim(),
          phone: widget.phone,
          password: _passwordController.text,
          verifyToken: widget.verifyToken,
        );
  }
}
