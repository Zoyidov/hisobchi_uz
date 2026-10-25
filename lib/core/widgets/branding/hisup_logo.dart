import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Hisup mark and wordmark, kept together on entry screens.
class HisupLogo extends StatelessWidget {
  const HisupLogo({super.key, this.markSize = 104, this.fontSize = 40});

  final double markSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: 'Hisup',
      image: true,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icon/hisup_mark.svg',
              width: markSize,
              height: markSize,
            ),
            SizedBox(height: markSize * .02),
            Text(
              'Hisup',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFF1F5FF)
                    : const Color(0xFF061536),
                fontSize: fontSize,
                height: 1.1,
                fontWeight: FontWeight.w800,
                letterSpacing: -fontSize * .04,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
