import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/localization/app_localization_extension.dart';

class DateRangeResult {
  const DateRangeResult({this.start, this.end, this.isCleared = false});
  final DateTime? start;
  final DateTime? end;
  final bool isCleared;
}

Future<DateRangeResult?> showTransactionDateFilterSheet(
  BuildContext context, {
  DateTime? currentFrom,
  DateTime? currentTo,
}) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final thisMonthStart = DateTime(now.year, now.month, 1);
  final lastMonthStart = DateTime(now.year, now.month - 1, 1);
  final lastMonthEnd = DateTime(now.year, now.month, 0);
  final last7DaysStart = today.subtract(const Duration(days: 6));
  final last30DaysStart = today.subtract(const Duration(days: 29));

  return showAppBottomSheet<DateRangeResult>(
    context,
    title: context.l10n.dateFilterTitle,
    subtitle: context.l10n.dateFilterSubtitle,
    child: ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      children: [
        if (currentFrom != null || currentTo != null) ...[
          _PresetTile(
            title: context.l10n.dateFilterAll,
            subtitle: context.l10n.dateFilterAllSubtitle,
            icon: AppIcons.sort,
            isSelected: false,
            onTap: () => Navigator.of(
              context,
            ).pop(const DateRangeResult(isCleared: true)),
          ),
          const Divider(height: 1),
        ],
        _PresetTile(
          title: context.l10n.dateFilterThisMonth,
          subtitle:
              '${AppDateFormatter.display(thisMonthStart)} — ${AppDateFormatter.display(today)}',
          icon: AppIcons.calendar,
          isSelected: currentFrom == thisMonthStart && currentTo == today,
          onTap: () => Navigator.of(
            context,
          ).pop(DateRangeResult(start: thisMonthStart, end: today)),
        ),
        _PresetTile(
          title: context.l10n.dateToday,
          subtitle: AppDateFormatter.display(today),
          icon: AppIcons.clock,
          isSelected: currentFrom == today && currentTo == today,
          onTap: () => Navigator.of(
            context,
          ).pop(DateRangeResult(start: today, end: today)),
        ),
        _PresetTile(
          title: context.l10n.dateFilterLast7,
          subtitle:
              '${AppDateFormatter.display(last7DaysStart)} — ${AppDateFormatter.display(today)}',
          icon: AppIcons.calendar,
          isSelected: currentFrom == last7DaysStart && currentTo == today,
          onTap: () => Navigator.of(
            context,
          ).pop(DateRangeResult(start: last7DaysStart, end: today)),
        ),
        _PresetTile(
          title: context.l10n.dateFilterLastMonth,
          subtitle:
              '${AppDateFormatter.display(lastMonthStart)} — ${AppDateFormatter.display(lastMonthEnd)}',
          icon: AppIcons.calendarRemove,
          isSelected:
              currentFrom == lastMonthStart && currentTo == lastMonthEnd,
          onTap: () => Navigator.of(
            context,
          ).pop(DateRangeResult(start: lastMonthStart, end: lastMonthEnd)),
        ),
        _PresetTile(
          title: context.l10n.dateFilterLast30,
          subtitle:
              '${AppDateFormatter.display(last30DaysStart)} — ${AppDateFormatter.display(today)}',
          icon: AppIcons.calendar,
          isSelected: currentFrom == last30DaysStart && currentTo == today,
          onTap: () => Navigator.of(
            context,
          ).pop(DateRangeResult(start: last30DaysStart, end: today)),
        ),
        const Divider(height: 1),
        _PresetTile(
          title: context.l10n.dateFilterCustom,
          subtitle: context.l10n.dateFilterCustomSubtitle,
          icon: AppIcons.calendarAdd,
          isSelected: false,
          onTap: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime(now.year + 2),
              initialDateRange: currentFrom != null && currentTo != null
                  ? DateTimeRange(start: currentFrom, end: currentTo)
                  : DateTimeRange(start: thisMonthStart, end: today),
              builder: (context, child) {
                final colors = context.colors;
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: colors.primary,
                      onPrimary: context.colors.onPrimary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null && context.mounted) {
              Navigator.of(
                context,
              ).pop(DateRangeResult(start: picked.start, end: picked.end));
            }
          },
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    ),
  );
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.15)
              : colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? colors.primary : colors.textSecondary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          color: isSelected ? colors.primary : colors.textPrimary,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isSelected
              ? colors.primary.withValues(alpha: 0.8)
              : colors.textTertiary,
        ),
      ),
      trailing: isSelected
          ? Icon(AppIcons.check, color: colors.primary, size: 20)
          : null,
      onTap: onTap,
    );
  }
}
