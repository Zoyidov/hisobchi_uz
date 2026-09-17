import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/cubits/user_cubit.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/cards/app_grouped_section.dart';
import '../../../../core/widgets/sheets/app_selection_sheet.dart';

/// Til, mavzu, pincode (E_HISOB_FLUTTER_UI_UX_TZ.md 63-bo'lim).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;

    return Scaffold(
      appBar: AppBar(title: const Text('Sozlamalar')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
        children: [
          AppGroupedSection(
            children: [
              AppGroupedTile(
                icon: Icons.language_rounded,
                label: 'Til',
                value: locale.languageCode == 'ru' ? 'Русский' : 'O\'zbek',
                onTap: () async {
                  final selected = await showAppSelectionSheet<Locale>(
                    context,
                    title: 'Til',
                    selectedValue: locale,
                    items: const [
                      AppSelectionItem(value: Locale('uz'), label: 'O\'zbek'),
                      AppSelectionItem(value: Locale('ru'), label: 'Русский'),
                    ],
                  );
                  if (selected != null && context.mounted) {
                    context.read<LocaleCubit>().setLocale(selected);
                  }
                },
              ),
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
              AppGroupedTile(
                icon: Icons.pin_outlined,
                label: 'Pincode',
                onTap: () => context.push(RoutePaths.pincodeSetup),
              ),
            ],
          ),
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
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hisobni o\'chirish'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Barcha hamkorlar, tranzaksiyalar, loyihalar va hisobotlar o\'chiriladi. Bu amalni qaytarib bo\'lmaydi.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'O\'CHIRISH deb yozing'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Bekor qilish')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim().toUpperCase() == 'O\'CHIRISH'),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final result = await getIt<AuthRepository>().deleteAccount();
    if (!context.mounted) return;
    result.when(
      success: (_) async {
        await getIt<SecureStorageService>().clearAll();
        if (!context.mounted) return;
        context.read<UserCubit>().clear();
        context.go(RoutePaths.phone);
      },
      failure: (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
    );
  }
}
