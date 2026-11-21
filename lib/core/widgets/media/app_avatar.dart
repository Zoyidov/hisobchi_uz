import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Rasm bo'lmasa initsiallar, xato bo'lsa ham initsiallarga qaytadi
/// (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 33). Kesh kaliti sifatida `cacheKey`
/// (odatda `file.id`) ishlatiladi, URL emas — MOBILE_APP_TZ.md 4.9.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.cacheKey,
    this.size = 48,
  });

  final String name;
  final String? imageUrl;
  final String? cacheKey;
  final double size;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  /// Ism bo'yicha barqaror kategoriya rangi — bir hamkor har doim bir xil
  /// rangda ko'rinadi (brend palitrasidan, light/dark'ga moslashadi).
  static List<Color> _gradientFor(String input, AppColorsExtension colors) {
    final hash = input.codeUnits.fold<int>(0, (prev, unit) => prev + unit);
    final base = colors.categoricalAt(hash);
    return [base, Color.lerp(base, Colors.black, 0.22)!];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final gradient = _gradientFor(name, colors);

    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.surface.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        _initials,
        style: TextStyle(
          color: colors.onPrimary,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.38,
          letterSpacing: 0.5,
        ),
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) return fallback;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.border.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          cacheKey: cacheKey,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => fallback,
          errorWidget: (context, url, error) => fallback,
        ),
      ),
    );
  }
}
