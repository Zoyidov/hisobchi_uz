import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/cubits/auth_cubit.dart';
import '../../../../core/cubits/owner_context_cubit.dart';
import '../../../../core/cubits/user_cubit.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/cards/app_grouped_section.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/sheets/app_confirmation_sheet.dart';
import '../../../../core/widgets/sheets/app_selection_sheet.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/localization/app_localization_extension.dart';

/// Til, mavzu, pincode boshqaruvi (E_HISOB_FLUTTER_UI_UX_TZ.md 63-bo'lim).
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _hasPincode = false;
  bool _isLoadingPincode = true;

  @override
  void initState() {
    super.initState();
    _checkPincodeStatus();
  }

  Future<void> _checkPincodeStatus() async {
    final pin = await getIt<SecureStorageService>().readPincode();
    if (mounted) {
      setState(() {
        _hasPincode = pin != null && pin.isNotEmpty;
        _isLoadingPincode = false;
      });
    }
  }

  Future<void> _onPincodeToggle(bool value) async {
    if (value) {
      // Yoqish: PIN yaratish sahifasiga o'tadi
      final result = await context.push<bool>(RoutePaths.pincodeSetup);
      await _checkPincodeStatus();
      if (!mounted) return;
      if (result == true || _hasPincode) {
        AppSnackbar.success(context, context.l10n.settingsPinEnabled);
      }
    } else {
      // O'chirish: tasdiqlash dialogi
      final confirmed = await _showDisablePincodeConfirmation();
      if (confirmed != true || !mounted) return;

      final userId = context.read<UserCubit>().currentUserOrNull?.userId;
      await getIt<SecureStorageService>().deletePincode();
      if (userId != null) {
        await getIt<AuthRepository>().updateAppSettings(
          userId: userId,
          pincode: null,
        );
      }
      await _checkPincodeStatus();
      if (mounted) {
        AppSnackbar.success(context, context.l10n.settingsPinDisabled);
      }
    }
  }

  Future<void> _changePincode() async {
    final result = await context.push<bool>(RoutePaths.pincodeSetup);
    await _checkPincodeStatus();
    if (!mounted) return;
    if (result == true) {
      AppSnackbar.success(context, context.l10n.settingsPinUpdated);
    }
  }

  Future<bool?> _showDisablePincodeConfirmation() {
    final colors = context.colors;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(AppIcons.unlock, color: colors.error, size: 24),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                context.l10n.settingsPinDisableTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          context.l10n.settingsPinDisableBody,
          style: TextStyle(
            fontSize: 14,
            color: colors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              context.l10n.commonCancel,
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: context.colors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.settingsPinDisableYes),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.profileSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: [
          // 1. Umumiy sozlamalar (Til, Mavzu)
          _SectionHeader(title: context.l10n.settingsGeneral),
          AppGroupedSection(
            children: [
              AppGroupedTile(
                icon: AppIcons.language,
                label: context.l10n.settingsLanguage,
                value: _languageName(locale),
                onTap: () async {
                  final selected = await showAppSelectionSheet<Locale>(
                    context,
                    title: context.l10n.settingsLanguage,
                    selectedValue: locale,
                    items: [
                      for (final option in LocaleCubit.supportedLocales)
                        AppSelectionItem(
                          value: option,
                          label: _languageName(option),
                        ),
                    ],
                  );
                  if (selected != null && context.mounted) {
                    await context.read<LocaleCubit>().setLocale(selected);
                  }
                },
              ),
              AppGroupedTile(
                icon: AppIcons.darkMode,
                label: context.l10n.settingsTheme,
                value: _themeLabel(themeMode),
                onTap: () async {
                  final selected = await showAppSelectionSheet<ThemeMode>(
                    context,
                    title: context.l10n.settingsTheme,
                    selectedValue: themeMode,
                    items: [
                      AppSelectionItem(
                        value: ThemeMode.light,
                        label: context.l10n.settingsThemeLight,
                      ),
                      AppSelectionItem(
                        value: ThemeMode.dark,
                        label: context.l10n.settingsThemeDark,
                      ),
                      AppSelectionItem(
                        value: ThemeMode.system,
                        label: context.l10n.settingsThemeSystem,
                      ),
                    ],
                  );
                  if (selected != null && context.mounted) {
                    context.read<ThemeCubit>().setThemeMode(selected);
                  }
                },
              ),
            ],
          ),

          // 2. Xavfsizlik (PIN-kod boshqaruvi)
          _SectionHeader(title: context.l10n.settingsSecurity),
          AppGroupedSection(
            children: [
              AppGroupedTile(
                icon: _hasPincode ? AppIcons.lock : AppIcons.unlock,
                iconColor: _hasPincode ? colors.primary : colors.textTertiary,
                label: context.l10n.settingsPinProtect,
                subtitle: _hasPincode
                    ? context.l10n.settingsPinOnSubtitle
                    : context.l10n.settingsPinOffSubtitle,
                showChevron: false,
                trailing: _isLoadingPincode
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Switch.adaptive(
                        value: _hasPincode,
                        activeTrackColor: colors.primary,
                        onChanged: _onPincodeToggle,
                      ),
              ),
              if (_hasPincode) ...[
                AppGroupedTile(
                  icon: AppIcons.password,
                  iconColor: colors.accentViolet,
                  label: context.l10n.settingsPinChange,
                  subtitle: context.l10n.settingsPinChangeSubtitle,
                  onTap: _changePincode,
                ),
              ],
            ],
          ),

          // 3. Xavfli hudud (Hisobni o'chirish)
          _SectionHeader(title: context.l10n.settingsDangerZone),
          AppGroupedSection(
            margin: EdgeInsets.zero,
            children: [
              AppGroupedTile(
                icon: AppIcons.delete,
                label: context.l10n.authDeleteAccount,
                destructive: true,
                showChevron: false,
                onTap: () => _confirmDeleteAccount(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Til nomi o'sha tilning o'zida (endonim) — foydalanuvchi interfeys
  /// tilini tushunmasa ham o'z tilini topa olishi uchun tarjima qilinmaydi.
  static String _languageName(Locale locale) => switch (locale.languageCode) {
    'ru' => 'Русский',
    _ => 'O‘zbekcha',
  };

  String _themeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.light => context.l10n.settingsThemeLight,
    ThemeMode.dark => context.l10n.settingsThemeDark,
    ThemeMode.system => context.l10n.settingsThemeSystem,
  };

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showAppConfirmationSheet(
      context,
      title: context.l10n.authDeleteAccount,
      description: context.l10n.authDeleteAccountConfirmBody,
      confirmLabel: context.l10n.commonYesDelete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    final result = await getIt<AuthRepository>().deleteAccount();
    if (!context.mounted) return;

    final shouldLogout = result.when(
      success: (_) => true,
      failure: (f) => f is AuthFailure,
    );

    if (shouldLogout) {
      await getIt<SecureStorageService>().clearAll();
      if (!context.mounted) return;
      final userCubit = context.read<UserCubit>();
      final ownerContextCubit = context.read<OwnerContextCubit>();
      final authCubit = context.read<AuthCubit>();
      userCubit.clear();
      await ownerContextCubit.reset();
      await authCubit.logout();
      if (context.mounted) {
        context.go(RoutePaths.phone);
        AppSnackbar.success(context, context.l10n.authAccountDeleted);
      }
    } else {
      result.when(
        success: (_) {},
        failure: (f) => AppSnackbar.error(context, f.message),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: colors.textSecondary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
