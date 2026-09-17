import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/cubits/auth_cubit.dart';
import '../../../../core/cubits/owner_context_cubit.dart';
import '../../../../core/cubits/user_cubit.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/domain/entities/user_entity.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/services/device_info_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/app_grouped_section.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/media/app_avatar.dart';
import '../../../../core/widgets/navigation/permission_guard.dart';
import '../../../../core/widgets/sheets/app_confirmation_sheet.dart';
import '../../../../core/constants/app_permission.dart';
import 'settings_page.dart';

/// Profil bosh sahifasi — guruhlangan menyu bo'limlari
/// (MOBILE_APP_TZ.md 17-bo'lim, E_HISOB_FLUTTER_UI_UX_TZ.md 61,
/// E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 197: ProfileHeader/Sections/Danger).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserCubit>().currentUserOrNull;
    final ownerContext = context.watch<OwnerContextCubit>().state;
    final colors = context.colors;
    final xZiffler = user?.xZiffler ?? true;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 110),
        children: [
          _Header(user: user, ownerContext: ownerContext),
          if (user != null && !user.isOwner) ...[
            const SizedBox(height: AppSpacing.md),
            AppGroupedSection(
              margin: EdgeInsets.zero,
              children: [
                AppGroupedTile(
                  icon: Icons.storefront_outlined,
                  label: 'O\'z hisobimni ochish',
                  iconColor: colors.primary,
                  onTap: () => _activateOwnAccount(context),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppGroupedSection(
            children: [
              AppGroupedTile(
                icon: Icons.person_outline_rounded,
                label: 'Shaxsiy ma\'lumotlar',
                iconColor: colors.primary,
                onTap: () => context.push(RoutePaths.profileEdit),
              ),
              AppGroupedTile(
                icon: Icons.settings_outlined,
                label: 'Sozlamalar',
                iconColor: const Color(0xFF64748B),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
                ),
              ),
            ],
          ),
          if (xZiffler)
            AppGroupedSection(
              children: [
                AppGroupedTile(
                  icon: Icons.workspace_premium_rounded,
                  label: 'Obuna va tariflar',
                  iconColor: colors.warning,
                  onTap: () => context.push(RoutePaths.profileSubscription),
                ),
                AppGroupedTile(
                  icon: Icons.sms_outlined,
                  label: 'SMS paketlari',
                  iconColor: const Color(0xFF06B6D4),
                  onTap: () => context.push(RoutePaths.profileSms),
                ),
              ],
            ),
          AppGroupedSection(
            children: [
              if (!ownerContext.isStaffMode)
                PermissionGuard(
                  permission: AppPermission.partnersView,
                  child: AppGroupedTile(
                    icon: Icons.groups_rounded,
                    label: 'Xodimlar',
                    iconColor: colors.success,
                    onTap: () => context.push(RoutePaths.profileStaff),
                  ),
                ),
              AppGroupedTile(
                icon: Icons.folder_copy_outlined,
                label: 'Ma\'lumotnomalar',
                iconColor: const Color(0xFFF97316),
                onTap: () => context.push(RoutePaths.profileDocuments),
              ),
              AppGroupedTile(
                icon: Icons.history_rounded,
                label: 'Faollik jurnali',
                iconColor: const Color(0xFF8B5CF6),
                onTap: () => context.push(RoutePaths.profileActivity),
              ),
              AppGroupedTile(
                icon: Icons.notifications_none_rounded,
                label: 'Bildirishnomalar',
                iconColor: const Color(0xFFE11D48),
                onTap: () => context.push(RoutePaths.profileNotifications),
              ),
              AppGroupedTile(
                icon: Icons.currency_exchange_rounded,
                label: 'Valyuta kurslari',
                iconColor: const Color(0xFF0284C7),
                onTap: () => context.push(RoutePaths.profileCurrency),
              ),
            ],
          ),
          AppGroupedSection(
            margin: EdgeInsets.zero,
            children: [
              AppGroupedTile(
                icon: Icons.logout_rounded,
                label: 'Chiqish',
                destructive: true,
                showChevron: false,
                onTap: () => _logout(context),
              ),
            ],
          ),
          const _VersionLabel(),
        ],
      ),
    );
  }

  Future<void> _activateOwnAccount(BuildContext context) async {
    final confirmed = await showAppConfirmationSheet(
      context,
      title: 'O\'z hisobimni ochish',
      description: 'Sizga FREE tarif bilan o\'z biznes hisobingiz ochiladi. Davom etasizmi?',
      confirmLabel: 'Ha, ochish',
      destructive: false,
    );
    if (!confirmed || !context.mounted) return;
    final result = await getIt<AuthRepository>().activateOwnAccount();
    if (!context.mounted) return;
    result.when(
      success: (_) {
        AppSnackbar.success(context, 'Hisobingiz ochildi');
        context.read<UserCubit>().loadMe();
      },
      failure: (f) => AppSnackbar.error(context, f.message),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showAppConfirmationSheet(
      context,
      title: 'Chiqish',
      description: 'Hisobingizdan chiqishni xohlaysizmi?',
      confirmLabel: 'Ha, chiqish',
      destructive: false,
    );
    if (!confirmed || !context.mounted) return;

    final deviceToken = await getIt<DeviceInfoService>().deviceToken;
    await getIt<AuthRepository>().logout(deviceToken);
    await getIt<SecureStorageService>().clearAll();
    if (!context.mounted) return;
    final userCubit = context.read<UserCubit>();
    final ownerContextCubit = context.read<OwnerContextCubit>();
    final authCubit = context.read<AuthCubit>();
    userCubit.clear();
    await ownerContextCubit.reset();
    await authCubit.logout();
    if (context.mounted) context.go(RoutePaths.phone);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user, required this.ownerContext});

  final UserEntity? user;
  final OwnerContext ownerContext;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: colors.border.withValues(alpha: 0.8)),
        boxShadow: colors.cardShadow,
      ),
      child: Row(
        children: [
          AppAvatar(name: user?.name ?? '?', imageUrl: user?.image, size: 60),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user?.name ?? '',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user!.isOwner ? 'Egasi' : 'Xodim',
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  user?.phone ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (ownerContext.isStaffMode)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: InkWell(
                      onTap: () => GoRouter.of(context).go(RoutePaths.accountSelection),
                      borderRadius: AppRadius.pillRadius,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          borderRadius: AppRadius.pillRadius,
                        ),
                        child: Text(
                          '${ownerContext.ownerName ?? ''} · Almashtirish',
                          style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionLabel extends StatelessWidget {
  const _VersionLabel();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '';
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          child: Center(
            child: Text('Versiya $version', style: TextStyle(color: context.colors.textTertiary, fontSize: 12)),
          ),
        );
      },
    );
  }
}
