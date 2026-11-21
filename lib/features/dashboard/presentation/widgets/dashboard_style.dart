part of '../dashboard_page.dart';

/// Dashboard-only presentation tokens inherit the app's Light/Dark/System theme.
abstract final class _DashboardStyle {
  static bool dark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
  static Color surface(BuildContext context) =>
      dark(context) ? context.colors.surfaceSecondary : context.colors.surface;
  static TextStyle section(BuildContext context) => Theme.of(context)
      .textTheme
      .titleMedium!
      .copyWith(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -.4);
  static TextStyle action(BuildContext context) => Theme.of(context)
      .textTheme
      .labelLarge!
      .copyWith(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: -.15);
  static Color tint(BuildContext context, Color color) => Color.alphaBlend(
    color.withValues(alpha: dark(context) ? .15 : .085),
    surface(context),
  );
  static Color ink(BuildContext context, Color color) => dark(context)
      ? Color.lerp(color, context.colors.textPrimary, .45)!
      : Color.lerp(color, context.colors.textPrimary, .28)!;
}

class _DashboardSurface extends StatelessWidget {
  const _DashboardSurface({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 20,
    this.onTap,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      boxShadow: _DashboardStyle.dark(context)
          ? const []
          : [
              BoxShadow(
                color: context.colors.primary.withValues(alpha: .035),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
    ),
    child: Material(
      color: _DashboardStyle.surface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(
          color: context.colors.border.withValues(
            alpha: _DashboardStyle.dark(context) ? .8 : .6,
          ),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    ),
  );
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.color, this.size = 34});
  final IconData icon;
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: _DashboardStyle.tint(context, color),
      borderRadius: BorderRadius.circular(AppRadius.small),
    ),
    child: Icon(icon, color: color, size: 23),
  );
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();
  @override
  Widget build(BuildContext context) => Column(
    children: [
      AppSkeletonBox(
        height: 140,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      const SizedBox(height: AppSpacing.sm),
      Row(
        children: [
          for (var i = 0; i < 4; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 3 ? 10 : 0),
                child: AppSkeletonBox(
                  height: 78,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: AppSpacing.sm),
      AppSkeletonBox(
        height: 218,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      const SizedBox(height: AppSpacing.sm),
      AppSkeletonBox(
        height: 108,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
    ],
  );
}
