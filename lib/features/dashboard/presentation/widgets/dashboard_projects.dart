part of '../dashboard_page.dart';

class _ProjectsSection extends StatelessWidget {
  const _ProjectsSection({required this.summary});
  final DashboardSummary summary;
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statuses = [
      (
        label: 'Jarayonda',
        count: summary.projectsInProgress,
        color: colors.primary,
      ),
      (
        label: 'Muzlatilgan',
        count: summary.projectsFrozen,
        color: colors.warning,
      ),
      (
        label: 'Yakunlangan',
        count: summary.projectsCompleted,
        color: colors.success,
      ),
    ];
    final classified = statuses.fold<int>(0, (sum, item) => sum + item.count);
    final unclassified = (summary.projectsCount - classified).clamp(
      0,
      summary.projectsCount,
    );
    return _DashboardSurface(
      onTap: () => context.go(RoutePaths.projects),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _IconTile(
                icon: AppIcons.project,
                color: colors.primary,
                size: 32,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${summary.projectsCount} ta loyiha',
                  style: _DashboardStyle.section(context),
                ),
              ),
              Icon(
                AppIcons.chevronRight,
                size: 21,
                color: colors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (summary.projectsCount == 0)
            Text(
              'Birinchi loyihangizni qo‘shib, ishlarni shu yerda kuzating.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
            )
          else
            Semantics(
              label: statuses.map((s) => '${s.label}: ${s.count}').join(', '),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  key: const ValueKey('dashboard-project-progress'),
                  height: 8,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final status in statuses)
                        if (status.count > 0)
                          Expanded(
                            flex: status.count,
                            child: ColoredBox(color: status.color),
                          ),
                      if (unclassified > 0)
                        Expanded(
                          flex: unclassified,
                          child: ColoredBox(color: colors.surfaceTertiary),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 11),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 10,
            runSpacing: 7,
            children: [
              for (final status in statuses)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: status.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${status.label}  ${status.count}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
