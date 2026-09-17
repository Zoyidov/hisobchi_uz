import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../data/staff_models.dart';

/// Ruxsatlar — kategoriyalar bo'yicha guruhlangan checkbox ro'yxati, har bir
/// kategoriyada "Barchasini tanlash" (MOBILE_APP_TZ.md 15.1).
class PermissionGroupList extends StatelessWidget {
  const PermissionGroupList({
    super.key,
    required this.groups,
    required this.selected,
    required this.onToggle,
    required this.onToggleCategory,
  });

  final List<PermissionGroup> groups;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final void Function(PermissionGroup group, bool selectAll) onToggleCategory;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in groups) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(group.category, style: Theme.of(context).textTheme.titleSmall),
              AppButton.text(
                label: 'Barchasini tanlash',
                onPressed: () => onToggleCategory(group, !group.items.every((i) => selected.contains(i.key))),
              ),
            ],
          ),
          for (final item in group.items)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: selected.contains(item.key),
              title: Text(item.label),
              onChanged: (_) => onToggle(item.key),
            ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Text('Ruxsatlar ro\'yxati yuklanmoqda...', style: TextStyle(color: colors.textSecondary)),
          ),
      ],
    );
  }
}
