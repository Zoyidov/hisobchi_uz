import 'package:flutter/material.dart';
import '../../icons/app_icons.dart';

/// Shared edit icon, inheriting the surrounding button or list icon theme.
class AppEditIcon extends StatelessWidget {
  const AppEditIcon({super.key, this.size, this.color});

  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    return ExcludeSemantics(
      child: Icon(
        AppIcons.edit,
        size: size ?? theme.size ?? 24,
        color: color ?? theme.color ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
