import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/chips/app_status_chip.dart';
import '../../data/project_models.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/localization/app_localization_extension.dart';

/// `ProjectCard` — business component (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 27,
/// MOBILE_APP_TZ.md 10.2).
class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, required this.onTap});

  final Project project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final image = project.files
        .where(
          (file) => RegExp(
            r'\.(jpe?g|png|webp|gif)$',
            caseSensitive: false,
          ).hasMatch(Uri.tryParse(file.url)?.path ?? ''),
        )
        .firstOrNull;
    final tone = switch (project.status) {
      ProjectStatus.inProgress => AppStatusChipTone.info,
      ProjectStatus.frozen => AppStatusChipTone.warning,
      ProjectStatus.completed => AppStatusChipTone.success,
    };

    final statusColor = switch (project.status) {
      ProjectStatus.inProgress => colors.info,
      ProjectStatus.frozen => colors.warning,
      ProjectStatus.completed => colors.success,
    };

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: image == null
                ? Icon(AppIcons.project, color: statusColor, size: 22)
                : Image.network(
                    image.url,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Icon(AppIcons.project, color: statusColor, size: 22),
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        project.projectName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    AppStatusChip(
                      label: project.status.label(context.l10n),
                      tone: tone,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    Icon(AppIcons.user, size: 14, color: colors.textSecondary),
                    const SizedBox(width: AppSpacing.xxs),
                    Expanded(
                      child: Text(
                        project.projectOwner,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(AppIcons.call, size: 13, color: colors.textTertiary),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      project.phone,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (project.address != null && project.address!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Icon(
                        AppIcons.location,
                        size: 13,
                        color: colors.textTertiary,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Expanded(
                        child: Text(
                          project.address!,
                          style: TextStyle(
                            color: colors.textTertiary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Icon(AppIcons.chevronRight, color: colors.textTertiary, size: 20),
        ],
      ),
    );
  }
}
