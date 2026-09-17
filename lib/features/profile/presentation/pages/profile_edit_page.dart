import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../core/cubits/user_cubit.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/phone_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_grouped_section.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_phone_field.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';

/// Shaxsiy ma'lumotlar — ism, parol, telefon (MOBILE_APP_TZ.md 17.2).
class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late final _nameController = TextEditingController(text: context.read<UserCubit>().currentUserOrNull?.name);
  bool _savingName = false;

  Future<void> _saveName() async {
    final error = Validators.required(_nameController.text);
    if (error != null) {
      AppSnackbar.error(context, error);
      return;
    }
    setState(() => _savingName = true);
    final result = await getIt<AuthRepository>().updateProfileName(_nameController.text.trim());
    if (!mounted) return;
    setState(() => _savingName = false);
    result.when(
      success: (_) {
        AppSnackbar.success(context, 'Saqlandi');
        context.read<UserCubit>().loadMe();
      },
      failure: (f) => AppSnackbar.error(context, f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserCubit>().currentUserOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Shaxsiy ma\'lumotlar')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppTextField(controller: _nameController, label: 'Ism'),
          const SizedBox(height: AppSpacing.sm),
          AppButton.secondary(label: 'Ismni saqlash', isLoading: _savingName, onPressed: _saveName, expand: false),
          const SizedBox(height: AppSpacing.xl),
          AppGroupedSection(
            margin: EdgeInsets.zero,
            children: [
              AppGroupedTile(
                icon: Icons.lock_outline_rounded,
                label: 'Parolni o\'zgartirish',
                onTap: () => _showChangePassword(context),
              ),
              AppGroupedTile(
                icon: Icons.phone_iphone_rounded,
                label: 'Telefonni o\'zgartirish',
                value: user != null ? PhoneFormatter.toDisplay(user.phone) : null,
                onTap: () => _showChangePhone(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePassword(BuildContext context) async {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    String? error;

    await showAppBottomSheet<void>(
      context,
      title: 'Parolni o\'zgartirish',
      child: StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(controller: oldController, label: 'Eski parol', obscureText: true, errorText: error),
              const SizedBox(height: AppSpacing.md),
              AppTextField(controller: newController, label: 'Yangi parol', obscureText: true),
            ],
          ),
        ),
      ),
      stickyAction: Builder(
        builder: (sheetContext) => AppButton.primary(
          label: 'Saqlash',
          onPressed: () async {
            final passwordError = Validators.password(newController.text);
            if (passwordError != null) {
              AppSnackbar.error(sheetContext, passwordError);
              return;
            }
            final result = await getIt<AuthRepository>().updatePassword(
              oldPassword: oldController.text,
              newPassword: newController.text,
            );
            if (!sheetContext.mounted) return;
            result.when(
              success: (_) {
                AppSnackbar.success(sheetContext, 'Saqlandi');
                Navigator.of(sheetContext).pop();
              },
              failure: (f) => AppSnackbar.error(sheetContext, f.message),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showChangePhone(BuildContext context) async {
    final phoneController = TextEditingController();
    await showAppBottomSheet<void>(
      context,
      title: 'Yangi telefon raqam',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: AppPhoneField(controller: phoneController, label: 'Yangi telefon'),
      ),
      stickyAction: Builder(
        builder: (sheetContext) => AppButton.primary(
          label: 'Davom etish',
          onPressed: () async {
            if (!PhoneFormatter.isValid(phoneController.text)) return;
            final result = await getIt<AuthRepository>().verifyNewPhone(phoneController.text);
            if (!sheetContext.mounted) return;
            result.when(
              success: (page) async {
                Navigator.of(sheetContext).pop();
                await getIt<AuthRepository>().sendOtp(phoneController.text);
                if (!context.mounted) return;
                final otpCode = await _askOtpCode(context, phoneController.text);
                if (otpCode == null || !context.mounted) return;
                final confirmResult = await getIt<AuthRepository>().confirmNewPhone(
                  phone: phoneController.text,
                  otpCode: otpCode,
                );
                if (!context.mounted) return;
                confirmResult.when(
                  success: (_) {
                    AppSnackbar.success(context, 'Telefon raqam yangilandi');
                    context.read<UserCubit>().loadMe();
                  },
                  failure: (f) => AppSnackbar.error(context, f.message),
                );
              },
              failure: (f) => AppSnackbar.error(sheetContext, f.message),
            );
          },
        ),
      ),
    );
  }

  Future<String?> _askOtpCode(BuildContext context, String phone) {
    final controller = TextEditingController();
    return showAppBottomSheet<String>(
      context,
      title: 'Tasdiqlash kodi',
      subtitle: PhoneFormatter.toDisplay(phone),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        child: PinCodeTextField(
          appContext: context,
          length: 4,
          controller: controller,
          autoFocus: true,
          keyboardType: TextInputType.number,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: AppRadius.mediumRadius,
            fieldHeight: 56,
            fieldWidth: 52,
            activeColor: context.colors.primary,
            selectedColor: context.colors.primary,
            inactiveColor: context.colors.border,
            activeFillColor: context.colors.surfaceSecondary,
            selectedFillColor: context.colors.surfaceSecondary,
            inactiveFillColor: context.colors.surfaceSecondary,
          ),
          onChanged: (_) {},
          onCompleted: (code) => Navigator.of(context).pop(code),
        ),
      ),
    );
  }
}
