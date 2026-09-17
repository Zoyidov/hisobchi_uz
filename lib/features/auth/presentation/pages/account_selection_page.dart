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
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppCard(
                    onTap: () async {
                      await context.read<OwnerContextCubit>().switchTo(OwnerContext.own);
                      if (context.mounted) context.go(RoutePaths.dashboard);
                    },
                    child: Row(
                      children: [
                        AppAvatar(name: user.name, imageUrl: user.image),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name, style: Theme.of(context).textTheme.titleMedium),
                              Text('O\'z hisobim',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: colors.textSecondary)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: colors.textTertiary),
                      ],
                    ),
                  ),
                ),
              if (user != null)
                ...user.worksFor.map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      onTap: () async {
                        await context
                            .read<OwnerContextCubit>()
                            .switchTo(OwnerContext(ownerId: w.ownerId, ownerName: w.ownerName));
                        if (context.mounted) context.go(RoutePaths.dashboard);
                      },
                      child: Row(
                        children: [
                          AppAvatar(name: w.ownerName),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(w.ownerName, style: Theme.of(context).textTheme.titleMedium),
                                Text('Xodim sifatida',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: colors.textSecondary)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: colors.textTertiary),
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
