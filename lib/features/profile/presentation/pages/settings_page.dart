import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/cubits/auth_cubit.dart';
import '../../../../core/cubits/owner_context_cubit.dart';
import '../../../../core/cubits/user_cubit.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/errors/failure.dart';
// import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/cards/app_grouped_section.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/sheets/app_confirmation_sheet.dart';
import '../../../../core/widgets/sheets/app_selection_sheet.dart';

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
        AppSnackbar.success(context, 'PIN-kod muvaffaqiyatli yoqildi');
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
        AppSnackbar.success(context, 'PIN-kod o\'chirildi');
      }
    }
  }

  Future<void> _changePincode() async {
    final result = await context.push<bool>(RoutePaths.pincodeSetup);
    await _checkPincodeStatus();
    if (!mounted) return;
    if (result == true) {
      AppSnackbar.success(context, 'PIN-kod muvaffaqiyatli yangilandi');
    }
  }

  Future<bool?> _showDisablePincodeConfirmation() {
    final colors = context.colors;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_open_rounded, color: colors.error, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'PIN-kodni o\'chirish',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          'Ilovaga kirishda PIN-kod va biometriya so\'ralmaydi. Hisobingiz xavfsizligi kamayishi mumkin.\n\nRostdan ham o\'chirmoqchimisiz?',
          style: TextStyle(fontSize: 14, color: colors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Bekor qilish', style: TextStyle(color: colors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ha, o\'chirilsin'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Sozlamalar')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
        children: [
          // 1. Umumiy sozlamalar (Til, Mavzu)
          const _SectionHeader(title: 'UMUMIY'),
          AppGroupedSection(
            children: [
              // AppGroupedTile(
              //   icon: Icons.language_rounded,
              //   label: 'Til',
              //   value: locale.languageCode == 'ru' ? 'Русский' : 'O\'zbek',
              //   onTap: () async {
              //     final selected = await showAppSelectionSheet<Locale>(
              //       context,
              //       title: 'Til',
              //       selectedValue: locale,
              //       items: const [
              //         AppSelectionItem(value: Locale('uz'), label: 'O\'zbek'),
              //         AppSelectionItem(value: Locale('ru'), label: 'Русский'),
              //       ],
              //     );
              //     if (selected != null && context.mounted) {
              //       context.read<LocaleCubit>().setLocale(selected);
              //     }
              //   },
              // ),
              AppGroupedTile(
                icon: Icons.dark_mode_outlined,
                label: 'Mavzu',
                value: _themeLabel(themeMode),
                onTap: () async {
                  final selected = await showAppSelectionSheet<ThemeMode>(
                    context,
                    title: 'Mavzu',
                    selectedValue: themeMode,
                    items: const [
                      AppSelectionItem(value: ThemeMode.light, label: 'Yorug\''),
                      AppSelectionItem(value: ThemeMode.dark, label: 'Qorong\'i'),
                      AppSelectionItem(value: ThemeMode.system, label: 'Tizim'),
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
          const _SectionHeader(title: 'XAVFSIZLIK'),
          AppGroupedSection(
            children: [
              AppGroupedTile(
                icon: _hasPincode ? Icons.lock_rounded : Icons.lock_open_rounded,
                iconColor: _hasPincode ? colors.primary : colors.textTertiary,
                label: 'PIN-kod bilan himoyalash',
                subtitle: _hasPincode
                    ? 'Ilovaga kirishda PIN-kod va biometriya so\'raladi'
                    : 'Ilovaga kirishda PIN-kod so\'ralmaydi',
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
                  icon: Icons.password_rounded,
                  iconColor: colors.accentViolet,
                  label: 'PIN-kodni o\'zgartirish',
                  subtitle: 'Yangi 4 xonali kod o\'rnatish',
                  onTap: _changePincode,
                ),
              ],
            ],
          ),

          // 3. Xavfli hudud (Hisobni o'chirish)
          const _SectionHeader(title: 'XAVFLI HUDUD'),
          AppGroupedSection(
            margin: EdgeInsets.zero,
            children: [
              AppGroupedTile(
                icon: Icons.delete_outline_rounded,
                label: 'Hisobni o\'chirish',
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

  String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'Yorug\'',
        ThemeMode.dark => 'Qorong\'i',
        ThemeMode.system => 'Tizim',
      };

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showAppConfirmationSheet(
      context,
      title: 'Hisobni o\'chirish',
      description: 'Barcha hamkorlar, tranzaksiyalar, loyihalar va hisobotlar butunlay o\'chiriladi. Bu amalni qaytarib bo\'lmaydi. Rostdan ham hisobingizni o\'chirmoqchimisiz?',
      confirmLabel: 'Ha, o\'chirish',
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
        AppSnackbar.success(context, 'Hisobingiz muvaffaqiyatli o\'chirildi');
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
