import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// Loading uchun default holat — spinner emas, skeleton
/// (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 66, 133, 154).
class AppSkeletonBox extends StatelessWidget {
  const AppSkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Shimmer.fromColors(
      baseColor: colors.surfaceSecondary,
      highlightColor: colors.border,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: borderRadius ?? AppRadius.smallRadius,
        ),
      ),
    );
  }
}

/// Ro'yxatlar uchun 5-7 dona kartochka skeleton.
class AppSkeletonList extends StatelessWidget {
  const AppSkeletonList({super.key, this.itemCount = 6, this.itemHeight = 88});

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) => AppSkeletonBox(
        height: itemHeight,
        width: double.infinity,
        borderRadius: AppRadius.cardRadius,
      ),
    );
  }
}
