part of '../dashboard_page.dart';

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.summary});
  final DashboardSummary summary;
  @override
  Widget build(BuildContext context) {
    final dark = _DashboardStyle.dark(context);
    final overdue = summary.qarzExpired + summary.installmentExpired;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF2459DE), Color(0xFF2532A7)]
              : const [Color(0xFF278FFF), Color(0xFF2563EB)],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: dark ? .16 : .1),
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
                        'Hisob-kitoblar nazoratda',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -.55,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        overdue > 0
                            ? '$overdue ta muddati o‘tgan to‘lov'
                            : 'Loyiha va to‘lovlarni bir joyda boshqaring',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          height: 1.4,
                          color: Colors.white.withValues(alpha: .92),
                        ),
                      ),
                    ],
                  ),
                ),
                if (MediaQuery.sizeOf(context).width >= 360 &&
                    MediaQuery.textScalerOf(context).scale(14) <= 20) ...[
                  const SizedBox(width: 6),
                  const ExcludeSemantics(
                    child: CustomPaint(
                      size: Size(76, 72),
                      painter: _OverviewIllustration(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            color: Colors.white.withValues(alpha: .09),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Row(
              children: [
                Expanded(
                  child: _OverviewTile(
                    value: summary.partnersCount,
                    label: 'Hamkorlar',
                    onTap: () => context.go(RoutePaths.partners),
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.white.withValues(alpha: .18),
                ),
                Expanded(
                  child: _OverviewTile(
                    value: summary.projectsCount,
                    label: 'Loyihalar',
                    onTap: () => context.go(RoutePaths.projects),
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.white.withValues(alpha: .18),
                ),
                Expanded(
                  child: _OverviewTile(
                    value: summary.qarzToday,
                    label: 'Bugungi qarzlar',
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
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(10),
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
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: Colors.white.withValues(alpha: .85),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Native canvas illustration; decorative only, never an image background.
class _OverviewIllustration extends CustomPainter {
  const _OverviewIllustration();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width * .12, size.height * .08);
    canvas.rotate(.12);
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width * .75, size.height * .88),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      rect.shift(const Offset(3, 4)),
      Paint()..color = const Color(0xFF132D97).withValues(alpha: .22),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFF4F7FF), Color(0xFFBFD7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect.outerRect),
    );
    final stroke = Paint()
      ..color = const Color(0xFF8DB9FF)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(11, 15), const Offset(37, 15), stroke);
    canvas.drawLine(const Offset(11, 23), const Offset(28, 23), stroke);
    for (var i = 0; i < 4; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(11 + i * 9, 51 - i * 5, 6, 9 + i * 5),
          const Radius.circular(2),
        ),
        Paint()
          ..color = Color.lerp(
            const Color(0xFF43AAFF),
            const Color(0xFF3965F5),
            i / 3,
          )!,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OverviewIllustration oldDelegate) => false;
}
