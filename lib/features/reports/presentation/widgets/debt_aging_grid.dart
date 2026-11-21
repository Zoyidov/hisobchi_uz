import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/localization/app_localization_extension.dart';

class DebtAgingGrid extends StatelessWidget {
  final int overdueCount;
  final int todayCount;
  final int upcomingCount;
  final VoidCallback? onOverdueTap;
  final VoidCallback? onTodayTap;
  final VoidCallback? onUpcomingTap;

  const DebtAgingGrid({
    super.key,
    required this.overdueCount,
    required this.todayCount,
    required this.upcomingCount,
    this.onOverdueTap,
    this.onTodayTap,
    this.onUpcomingTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: 4, bottom: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  AppIcons.clock,
                  color: colors.textSecondary,
                  size: 16,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                context.l10n.reportDebtsList,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildDeadlineCard(
                  context: context,
                  title: context.l10n.dashboardOverdueLabel,
                  count: overdueCount,
                  icon: AppIcons.error,
                  color: context.colors.error,
                  onTap: onOverdueTap,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _buildDeadlineCard(
                  context: context,
                  title: context.l10n.dateToday,
                  count: todayCount,
                  icon: AppIcons.warning,
                  color: context.colors.warning,
                  onTap: onTodayTap,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _buildDeadlineCard(
                  context: context,
                  title: context.l10n.reportUpcoming,
                  subtitle: context.l10n.reportIn3DaysParen,
                  count: upcomingCount,
                  icon: AppIcons.clock,
                  color: context.colors.primary,
                  onTap: onUpcomingTap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeadlineCard({
    required BuildContext context,
    required String title,
    String? subtitle,
    required int count,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? colors.surfaceSecondary : colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.border.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 9,
                    color: colors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                )
              else
                const SizedBox(height: AppSpacing.sm),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 14),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: count > 0 ? color : colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
