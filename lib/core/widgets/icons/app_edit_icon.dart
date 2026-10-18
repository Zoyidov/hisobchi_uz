import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Shared edit asset, inheriting the surrounding button or list icon theme.
class AppEditIcon extends StatelessWidget {
  const AppEditIcon({super.key, this.size, this.color});

  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final iconColor =
        color ?? theme.color ?? Theme.of(context).colorScheme.onSurface;
    final opacity = theme.opacity ?? 1;
    return SvgPicture.asset(
      'assets/icon/edit.svg',
      width: size ?? theme.size ?? 24,
      height: size ?? theme.size ?? 24,
      colorFilter: ColorFilter.mode(
        iconColor.withValues(alpha: iconColor.a * opacity),
        BlendMode.srcIn,
      ),
      excludeFromSemantics: true,
    );
  }
}
