import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 4, bottom: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  color: colors.textSecondary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Qarzlar ro\'yxati',
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
                  title: 'Muddati o\'tgan',
                  count: overdueCount,
                  icon: Icons.error_outline_rounded,
                  color: const Color(0xFFEF4444),
                  onTap: onOverdueTap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDeadlineCard(
                  context: context,
                  title: 'Bugun',
                  count: todayCount,
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFF59E0B),
                  onTap: onTodayTap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDeadlineCard(
                  context: context,
                  title: 'Yaqinlashmoqda',
                  subtitle: '(3 kun)',
                  count: upcomingCount,
                  icon: Icons.schedule_rounded,
                  color: const Color(0xFF3B82F6),
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
      color: isDark ? colors.surfaceSecondary : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.border.withValues(alpha: 0.6),
            ),
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
                const SizedBox(height: 12),
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
                  const SizedBox(width: 8),
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
