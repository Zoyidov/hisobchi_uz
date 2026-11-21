part of '../dashboard_page.dart';

class _PaymentOverview extends StatelessWidget {
  const _PaymentOverview({required this.summary});
  final DashboardSummary summary;
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final groups = [
      (
        label: context.l10n.dashboardPartnersDebt,
        icon: AppIcons.partners,
        values: [summary.qarzExpired, summary.qarzToday, summary.qarz3Days],
        types: [
          DueDateType.qarzExpired,
          DueDateType.qarzToday,
          DueDateType.qarz3Days,
        ],
      ),
      (
        label: context.l10n.commonInstallment,
        icon: AppIcons.payments,
        values: [
          summary.installmentExpired,
          summary.installmentToday,
          summary.installment3Days,
        ],
        types: [
          DueDateType.installmentExpired,
          DueDateType.installmentToday,
          DueDateType.installment3Days,
        ],
      ),
    ];
    final accents = [colors.error, colors.warning, colors.primary];
    final labels = [
      context.l10n.dashboardOverdueLabel,
      context.l10n.dueToday,
      context.l10n.dueIn3Days,
    ];
    return _DashboardSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.dashboardPaymentsControl,
            style: _DashboardStyle.section(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var group = 0; group < groups.length; group++) ...[
            if (group > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Divider(height: 1, color: colors.divider),
              ),
            Row(
              children: [
                Icon(groups[group].icon, size: 18, color: colors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    groups[group].label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked =
                    constraints.maxWidth < 235 ||
                    MediaQuery.textScalerOf(context).scale(12) > 20;
                return Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (var i = 0; i < 3; i++)
                      SizedBox(
                        width: stacked
                            ? constraints.maxWidth
                            : (constraints.maxWidth - 14) / 3,
                        child: Semantics(
                          label:
                              '${groups[group].label}, ${labels[i]}: ${groups[group].values[i]}',
                          button: groups[group].values[i] > 0,
                          child: Material(
                            color: _DashboardStyle.tint(context, accents[i]),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              side: BorderSide(
                                color: accents[i].withValues(
                                  alpha: _DashboardStyle.dark(context)
                                      ? .12
                                      : .025,
                                ),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: groups[group].values[i] == 0
                                  ? null
                                  : () => _openDue(
                                      context,
                                      groups[group].types[i],
                                    ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 7,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${groups[group].values[i]}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontSize: 21,
                                            height: 1.05,
                                            fontWeight: FontWeight.w600,
                                            color: _DashboardStyle.ink(
                                              context,
                                              accents[i],
                                            ),
                                          ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      labels[i],
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w400,
                                            color: colors.textPrimary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
