part of '../dashboard_page.dart';

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();
  String get _greeting => switch (DateTime.now().hour) {
    >= 5 && < 11 => 'Xayrli tong,',
    >= 11 && < 17 => 'Xayrli kun,',
    >= 17 && < 22 => 'Xayrli kech,',
    _ => 'Xayrli tun,',
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
            label: 'Profilni ochish',
            child: Material(
              color: _DashboardStyle.surface(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
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
                    semanticsLabel: 'Hisup logosi',
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
                _greeting,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user?.name ?? 'Boshqaruv paneli',
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
                const SizedBox(height: 4),
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
        const SizedBox(width: 12),
        BlocBuilder<NotificationBadgeCubit, int>(
          builder: (context, count) => Semantics(
            label: '$count ta o‘qilmagan bildirishnoma',
            button: true,
            child: SizedBox(
              width: 46,
              height: 46,
              child: _DashboardSurface(
                radius: 15,
                padding: EdgeInsets.zero,
                onTap: () => context.push(RoutePaths.profileNotifications),
                child: Tooltip(
                  message: 'Bildirishnomalar',
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
