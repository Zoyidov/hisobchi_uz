import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/icons/app_icons.dart';
import 'package:hisobchi_uz/core/widgets/icons/app_edit_icon.dart';

void main() {
  testWidgets('Solar edit icon inherits icon size and color', (tester) async {
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
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, AppIcons.edit);
    expect(icon.size, 20);
    expect(icon.color, Colors.red);
    expect(tester.takeException(), isNull);
  });
}
