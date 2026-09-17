import 'package:flutter/material.dart';

import '../../../../core/constants/app_permission.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/navigation/permission_guard.dart';
import 'installment_reports_page.dart';
import 'partner_reports_page.dart';
import 'project_reports_page.dart';

/// Hisobotlar bosh sahifasi (MOBILE_APP_TZ.md 12-bo'lim).
class ReportsHomePage extends StatelessWidget {
  const ReportsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      appBar: AppBar(title: const Text('Hisobotlar')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 100),
        children: [
          PermissionGuard(
            permission: AppPermission.reportPartnersView,
            child: _ReportCard(
              icon: Icons.people_alt_rounded,
              color: colors.primary,
              title: 'Hamkorlar hisoboti',
              subtitle: 'Umumiy balans, davr bo\'yicha, qarz muddatlari, xodimlar',
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PartnerReportsPage())),
            ),
          ),
          PermissionGuard(
            permission: AppPermission.reportInstallmentsView,
            child: _ReportCard(
              icon: Icons.calendar_month_rounded,
              color: const Color(0xFF8B5CF6),
              title: 'Bo\'lib to\'lash hisoboti',
              subtitle: 'Umumiy tahlil, muammoli grafiklar, undirish dinamikasi',
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const InstallmentReportsPage())),
            ),
          ),
          PermissionGuard(
            permission: AppPermission.reportProjectView,
            child: _ReportCard(
              icon: Icons.account_tree_rounded,
              color: colors.warning,
              title: 'Loyihalar hisoboti',
              subtitle: 'Loyiha balansi, xarajatlar va daromadlar tahlili',
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ProjectReportsPage())),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: colors.textSecondary, fontSize: 12, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: colors.textTertiary, size: 22),
          ],
        ),
      ),
    );
  }
}
