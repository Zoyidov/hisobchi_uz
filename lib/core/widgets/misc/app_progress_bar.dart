import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Chiziqli progress — 80%+ warning, 100% error (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 67).
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({super.key, required this.value, this.height = 8});

  /// 0.0 – 1.0
  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final clamped = value.clamp(0.0, 1.0);
    final color = clamped >= 1.0 ? colors.error : (clamped >= 0.8 ? colors.warning : colors.primary);

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: clamped,
        minHeight: height,
        backgroundColor: colors.surfaceSecondary,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}

class AppCircularProgress extends StatelessWidget {
  const AppCircularProgress({super.key, required this.value, this.size = 56, this.label});

  final double value;
  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value.clamp(0.0, 1.0),
            strokeWidth: 6,
            backgroundColor: colors.surfaceSecondary,
            valueColor: AlwaysStoppedAnimation(colors.primary),
          ),
          if (label != null)
            Text(label!, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
