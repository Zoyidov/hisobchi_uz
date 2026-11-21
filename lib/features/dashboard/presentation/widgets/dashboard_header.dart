part of '../dashboard_page.dart';

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();
  static String _greeting(AppLocalizations l10n) =>
      switch (DateTime.now().hour) {
        >= 5 && < 11 => l10n.greetingMorning,
        >= 11 && < 17 => l10n.greetingDay,
        >= 17 && < 22 => l10n.greetingEvening,
        _ => l10n.greetingNight,
      };
  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserCubit>().currentUserOrNull;
    final owner = context.watch<OwnerContextCubit>().state;
    final colors = context.colors;
    return Row(
      children: [
        if (user != null) ...[
          Semantics(
            button: true,
            label: context.l10n.dashboardOpenProfile,
            child: Material(
              color: _DashboardStyle.surface(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                side: BorderSide(color: colors.borderSubtle),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => context.go(RoutePaths.profile),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: SvgPicture.asset(
                    _DashboardStyle.dark(context)
                        ? 'assets/icon/hisup_mark_dark.svg'
                        : 'assets/icon/hisup_mark.svg',
                    width: 38,
                    height: 38,
                    semanticsLabel: context.l10n.hisupLogoLabel,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(context.l10n),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user?.name ?? context.l10n.dashboardTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.8,
                  height: 1.15,
                ),
              ),
              if (owner.isStaffMode) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${owner.ownerName ?? 'Tashkilot'} hisobida',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: colors.primary),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        BlocBuilder<NotificationBadgeCubit, int>(
          builder: (context, count) => Semantics(
            label: context.l10n.notificationsUnreadCount(count),
            button: true,
            child: SizedBox(
              width: 46,
              height: 46,
              child: _DashboardSurface(
                radius: 15,
                padding: EdgeInsets.zero,
                onTap: () => context.push(RoutePaths.profileNotifications),
                child: Tooltip(
                  message: context.l10n.notificationsTitle,
                  child: Center(
                    child: Badge(
                      isLabelVisible: count > 0,
                      backgroundColor: colors.error,
                      smallSize: 8,
                      child: Icon(
                        AppIcons.notification,
                        size: 25,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
