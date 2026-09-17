import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

class AppSegment<T> {
  const AppSegment({required this.value, required this.label});
  final T value;
  final String label;
}

/// 2-4 variantli segmented control — dropdown o'rnini bosadi
/// (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 17, 169).
class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
  });

  final List<AppSegment<T>> segments;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: colors.surfaceSecondary, borderRadius: AppRadius.mediumRadius),
      child: Row(
        children: segments.map((segment) {
          final selected = segment.value == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(segment.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? colors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: selected
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)]
                      : null,
                ),
                child: Text(
                  segment.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: selected ? colors.textPrimary : colors.textSecondary,
                      ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
