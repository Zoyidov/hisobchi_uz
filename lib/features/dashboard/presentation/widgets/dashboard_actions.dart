part of '../dashboard_page.dart';

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserCubit>().currentUserOrNull;
    final owner = context.watch<OwnerContextCubit>().state;
    final colors = context.colors;
    final actions =
        <
              ({
                String permission,
                String label,
                IconData icon,
                Color color,
                VoidCallback onTap,
              })
            >[
              (
                permission: AppPermission.walletsDebtCreate,
                label: 'Kirim',
                icon: AppIcons.income,
                color: colors.success,
                onTap: () => _wallet(context, 'debt'),
              ),
              (
                permission: AppPermission.walletsCreditCreate,
                label: 'Chiqim',
                icon: AppIcons.expense,
                color: colors.error,
                onTap: () => _wallet(context, 'credit'),
              ),
              (
                permission: AppPermission.partnersCreate,
                label: 'Hamkor',
                icon: AppIcons.partnerAdd,
                color: colors.primary,
                onTap: () async {
                  await context.push(RoutePaths.partnerCreate);
                  if (context.mounted) {
                    await context.read<DashboardCubit>().refresh();
                  }
                },
              ),
              (
                permission: AppPermission.projectsCreate,
                label: 'Loyiha',
                icon: AppIcons.projectAdd,
                color: colors.accentViolet,
                onTap: () => context.go(RoutePaths.projects),
              ),
            ]
            .where(
              (action) =>
                  user?.hasPermission(action.permission, owner) ?? false,
            )
            .toList();
    if (actions.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns =
                constraints.maxWidth < 280 ||
                    MediaQuery.textScalerOf(context).scale(14) > 20
                ? 2
                : actions.length;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final action in actions)
                  SizedBox(
                    width:
                        (constraints.maxWidth - (columns - 1) * 10) / columns,
                    child: _DashboardSurface(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        action.onTap();
                      },

                      padding: const EdgeInsets.symmetric(
                        vertical: 11,
                        horizontal: 6,
                      ),
                      radius: 18,
                      child: Column(
                        children: [
                          _IconTile(
                            icon: action.icon,
                            color: action.color,
                            size: 32,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            action.label,
                            style: _DashboardStyle.action(context),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _wallet(BuildContext context, String type) async {
    final result = await showWalletFormSheet(context, type: type);
    if (result != null && context.mounted) {
      await context.read<DashboardCubit>().refresh();
    }
  }
}

Future<void> _openDue(BuildContext context, DueDateType type) async {
  await context.push(
    type.isInstallment
        ? RoutePaths.dashboardInstallmentDueDates
        : RoutePaths.dashboardDueDates,
    extra: type,
  );
  if (context.mounted) await context.read<DashboardCubit>().refresh();
}
