import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/cubits/auth_cubit.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/cubits/owner_context_cubit.dart';
import '../../../../core/cubits/user_cubit.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/media/app_avatar.dart';

/// Hisob tanlash — Senior Level FinTech Multi-Tenant Account Switcher ekrani.
class AccountSelectionPage extends StatefulWidget {
  const AccountSelectionPage({super.key});

  @override
  State<AccountSelectionPage> createState() => _AccountSelectionPageState();
}

class _AccountSelectionPageState extends State<AccountSelectionPage> {
  bool _activating = false;
  bool _ownerActivated = false;
  String? _activationError;

  Future<void> _activateOwner() async {
    if (_activating) return;
    setState(() {
      _activating = true;
      _activationError = null;
    });
    if (!_ownerActivated) {
      final result = await getIt<AuthRepository>().activateOwnAccount();
      if (!mounted) return;
      if (!result.isSuccess) {
        result.when(
          success: (_) {},
          failure: (f) {
            AppSnackbar.error(context, f.message);
            setState(() => _activationError = f.message);
          },
        );
        setState(() => _activating = false);
        return;
      }
      _ownerActivated = true;
    }
    await context.read<UserCubit>().loadMe();
    if (!mounted) return;
    final user = context.read<UserCubit>().currentUserOrNull;
    if (user == null || !user.isOwner) {
      setState(() {
        _activating = false;
        _activationError =
            "Hisob ma'lumotlarini yuklab bo'lmadi. Qayta urinib ko'ring.";
      });
      return;
    }
    await context.read<OwnerContextCubit>().switchTo(OwnerContext.own);
    if (mounted) context.go(RoutePaths.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserCubit>().state;
    final user = context.read<UserCubit>().currentUserOrNull;
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // 1. Ambient Background Glows
          Positioned(
            top: -100,
            right: -70,
            child: IgnorePointer(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.primary.withValues(alpha: isDark ? 0.22 : 0.12),
                      colors.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -90,
            left: -70,
            child: IgnorePointer(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.accentViolet.withValues(
                        alpha: isDark ? 0.15 : 0.08,
                      ),
                      colors.accentViolet.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.lg),

                  // Top Status Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer.withValues(
                            alpha: isDark ? 0.4 : 0.8,
                          ),
                          borderRadius: AppRadius.pillRadius,
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          'HISOBNI TANLASH 🏢',
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Chiqish',
                        icon: Icon(
                          Icons.logout_rounded,
                          color: colors.textTertiary,
                          size: 20,
                        ),
                        onPressed: () async {
                          HapticFeedback.mediumImpact();
                          await context.read<AuthCubit>().logout();
                          if (context.mounted) context.go(RoutePaths.phone);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Headings
                  Text(
                    'Qaysi hisobda ishlaysiz? 👋',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Xodim sifatida ish joyingizni tanlang yoki o‘zingizning biznes hisobingizga kiring.",
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14.5,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Accounts List
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        if (user == null && !_activating) ...[
                          Text(
                            userState is UserError
                                ? userState.failure.message
                                : "Hisob ma'lumotlari yuklanmoqda...",
                          ),
                          TextButton(
                            onPressed: userState is UserLoading
                                ? null
                                : () async {
                                    await context.read<UserCubit>().loadMe();
                                  },
                            child: const Text('Qayta yuklash'),
                          ),
                        ],
                        if ((user != null && !user.isOwner) ||
                            _activationError != null) ...[
                          if (_activationError != null)
                            Text(
                              _activationError!,
                              style: TextStyle(color: colors.error),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.lg,
                            ),
                            child: FilledButton.icon(
                              onPressed: _activating ? null : _activateOwner,
                              icon: const Icon(Icons.add_business_rounded),
                              label: Text(
                                _activating
                                    ? 'Hisob ochilmoqda...'
                                    : "O'z biznes hisobimni ochish",
                              ),
                            ),
                          ),
                        ],
                        // 1. Owner's Own Account Card
                        if (user != null && user.isOwner) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.lg,
                            ),
                            child: AppButtonPressable(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(22),
                                onTap: () async {
                                  HapticFeedback.mediumImpact();
                                  await context
                                      .read<OwnerContextCubit>()
                                      .switchTo(OwnerContext.own);
                                  if (context.mounted) {
                                    context.go(RoutePaths.dashboard);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? colors.surfaceSecondary
                                        : colors.surface,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: colors.primary.withValues(
                                        alpha: 0.5,
                                      ),
                                      width: 1.6,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors.primary.withValues(
                                          alpha: isDark ? 0.25 : 0.1,
                                        ),
                                        blurRadius: 18,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          AppAvatar(
                                            name: user.name,
                                            imageUrl: user.image,
                                            size: 54,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: colors.primary,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: colors.surface,
                                                width: 2,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.star_rounded,
                                              size: 11,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    user.name,
                                                    style: TextStyle(
                                                      fontSize: 16.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: colors.textPrimary,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 3,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        colors.primaryContainer,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'ASOSIY • EGASI',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: colors.primary,
                                                      letterSpacing: 0.4,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              'Shaxsiy biznesingiz va to\'liq hisobdorlik',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: colors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: colors.primary,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],

                        // 2. Staff Accounts
                        if (user != null && user.worksFor.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 12),
                            child: Text(
                              'XODIM SIFATIDA BIRIKTIRILGAN HISOBDORLIKLAR',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: colors.textTertiary,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          ...user.worksFor.map((w) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: AppButtonPressable(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () async {
                                    HapticFeedback.mediumImpact();
                                    await context
                                        .read<OwnerContextCubit>()
                                        .switchTo(
                                          OwnerContext(
                                            ownerId: w.ownerId,
                                            ownerName: w.ownerName,
                                          ),
                                        );
                                    if (context.mounted) {
                                      context.go(RoutePaths.dashboard);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? colors.surfaceSecondary
                                          : colors.surface,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: colors.border),
                                      boxShadow: colors.cardShadow,
                                    ),
                                    child: Row(
                                      children: [
                                        AppAvatar(name: w.ownerName, size: 50),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      w.ownerName,
                                                      style: TextStyle(
                                                        fontSize: 15.5,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            colors.textPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 3,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: colors
                                                          .surfaceSecondary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      'XODIM',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: colors
                                                            .textSecondary,
                                                        letterSpacing: 0.3,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Biriktirilgan korxona hisoboti',
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  color: colors.textTertiary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          color: colors.textTertiary,
                                          size: 22,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),

                  // Trust Footer
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceSecondary.withValues(alpha: 0.5),
                        borderRadius: AppRadius.pillRadius,
                        border: Border.all(color: colors.borderSubtle),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 15,
                            color: colors.textTertiary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Har bir hisob xavfsiz ajratilgan holda yuritiladi',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
