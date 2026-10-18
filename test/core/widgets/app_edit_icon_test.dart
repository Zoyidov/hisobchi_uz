import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi_uz/core/widgets/icons/app_edit_icon.dart';

void main() {
  testWidgets('edit SVG loads and inherits icon size and color', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: IconTheme(
            data: IconThemeData(color: Colors.red, size: 20),
            child: AppEditIcon(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(svg.width, 20);
    expect(svg.height, 20);
    expect(
      svg.colorFilter,
      ColorFilter.mode(Colors.red.withValues(alpha: 1), BlendMode.srcIn),
    );
    expect(tester.takeException(), isNull);
  });
}
