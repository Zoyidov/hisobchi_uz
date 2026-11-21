import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Testlar ilovani `uz` locale bilan ishga tushiradi, shuning uchun Flutter'ning
/// o'z (Material) matnlari ham o'zbekcha bo'ladi ("Back" emas, "Orqaga").
/// Bu yordamchilar Material matnlarini qattiq yozmasdan, joriy locale'dan oladi.

MaterialLocalizations _material(WidgetTester tester) =>
    MaterialLocalizations.of(tester.element(find.byType(Scaffold).last));

/// `tester.pageBack()` o'rnini bosadi — u faqat inglizcha "Back" tooltipini
/// qidiradi.
Future<void> tapBack(WidgetTester tester) async {
  final tooltip = _material(tester).backButtonTooltip;
  await tester.tap(find.byTooltip(tooltip).last);
}

/// Joriy locale'dagi Material "Delete" tooltipi bo'yicha qidiradi.
Finder findDeleteTooltip(WidgetTester tester) =>
    find.byTooltip(_material(tester).deleteButtonTooltip);
