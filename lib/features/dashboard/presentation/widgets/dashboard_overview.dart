part of '../dashboard_page.dart';

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.summary});
  final DashboardSummary summary;
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onHero = colors.onPrimary;
    final overdue = summary.qarzExpired + summary.installmentExpired;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        gradient: colors.heroGradient,
        border: Border.all(
          color: onHero.withValues(alpha: colors.isDark ? .16 : .1),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.dashboardHeroTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -.55,
                              color: onHero,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        overdue > 0
                            ? context.l10n.dashboardOverduePayments(overdue)
                            : context.l10n.dashboardHeroSubtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          height: 1.4,
                          color: onHero.withValues(alpha: .92),
                        ),
                      ),
                    ],
                  ),
                ),
                if (MediaQuery.sizeOf(context).width >= 360 &&
                    MediaQuery.textScalerOf(context).scale(14) <= 20) ...[
                  const SizedBox(width: 6),
                  ExcludeSemantics(
                    child: CustomPaint(
                      size: const Size(76, 72),
                      painter: _OverviewIllustration(colors),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            color: onHero.withValues(alpha: .09),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Row(
              children: [
                Expanded(
                  child: _OverviewTile(
                    value: summary.partnersCount,
                    label: context.l10n.navPartners,
                    onTap: () => context.go(RoutePaths.partners),
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: onHero.withValues(alpha: .18),
                ),
                Expanded(
                  child: _OverviewTile(
                    value: summary.projectsCount,
                    label: context.l10n.navProjects,
                    onTap: () => context.go(RoutePaths.projects),
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: onHero.withValues(alpha: .18),
                ),
                Expanded(
                  child: _OverviewTile(
                    value: summary.qarzToday,
                    label: context.l10n.dashboardTodayDebts,
                    onTap: () => _openDue(context, DueDateType.qarzToday),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewTile extends StatelessWidget {
  const _OverviewTile({
    required this.value,
    required this.label,
    required this.onTap,
  });
  final int value;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final onHero = context.colors.onPrimary;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.small),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
          child: Column(
            children: [
              Text(
                '$value',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 17,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: onHero,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: onHero.withValues(alpha: .85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Native canvas illustration; decorative only, never an image background.
class _OverviewIllustration extends CustomPainter {
  const _OverviewIllustration(this.colors);

  final AppColorsExtension colors;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width * .12, size.height * .08);
    canvas.rotate(.12);
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width * .75, size.height * .88),
      const Radius.circular(AppRadius.md),
    );
    canvas.drawRRect(
      rect.shift(const Offset(3, 4)),
      Paint()..color = colors.heroGradientEnd.withValues(alpha: .45),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Color.alphaBlend(
              colors.brandAccent.withValues(alpha: .05),
              Colors.white,
            ),
            Color.alphaBlend(
              colors.brandAccent.withValues(alpha: .30),
              Colors.white,
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect.outerRect),
    );
    final stroke = Paint()
      ..color = Color.alphaBlend(
        colors.brandAccent.withValues(alpha: .50),
        Colors.white,
      )
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(11, 15), const Offset(37, 15), stroke);
    canvas.drawLine(const Offset(11, 23), const Offset(28, 23), stroke);
    for (var i = 0; i < 4; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(11 + i * 9, 51 - i * 5, 6, 9 + i * 5),
          const Radius.circular(AppRadius.hairline),
        ),
        Paint()..color = Color.lerp(colors.brandAccent, colors.primary, i / 3)!,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OverviewIllustration oldDelegate) =>
      oldDelegate.colors != colors;
}
