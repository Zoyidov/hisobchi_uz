import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/cubits/owner_context_cubit.dart';
import '../../../../core/cubits/user_cubit.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/media/app_avatar.dart';

/// Hisob tanlash — `role` da `user` va `staff` bo'lganda (MOBILE_APP_TZ.md 6.2).
class AccountSelectionPage extends StatelessWidget {
  const AccountSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserCubit>().currentUserOrNull;
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Text('Qaysi hisobda ishlaysiz?', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xl),
              if (user != null && user.isOwner)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AppCard(
                    onTap: () async {
                      await context.read<OwnerContextCubit>().switchTo(OwnerContext.own);
                      if (context.mounted) context.go(RoutePaths.dashboard);
                    },
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      children: [
                        AppAvatar(name: user.name, imageUrl: user.image, size: 50),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'O\'z hisobim (Egasi)',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.primary, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: colors.textTertiary, size: 22),
                      ],
                    ),
                  ),
                ),
              if (user != null)
                ...user.worksFor.map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: AppCard(
                      onTap: () async {
                        await context
                            .read<OwnerContextCubit>()
                            .switchTo(OwnerContext(ownerId: w.ownerId, ownerName: w.ownerName));
                        if (context.mounted) context.go(RoutePaths.dashboard);
                      },
                      padding: const EdgeInsets.all(AppSpacing.md),
                      borderRadius: BorderRadius.circular(20),
                      child: Row(
                        children: [
                          AppAvatar(name: w.ownerName, size: 50),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  w.ownerName,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Xodim sifatida',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.textSecondary, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: colors.textTertiary, size: 22),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
