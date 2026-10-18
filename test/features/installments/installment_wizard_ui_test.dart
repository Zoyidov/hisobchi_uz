import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/di/injector.dart';
import 'package:hisobchi_uz/core/network/api_client.dart';
import 'package:hisobchi_uz/core/theme/app_theme.dart';
import 'package:hisobchi_uz/features/installments/data/installments_repository.dart';
import 'package:hisobchi_uz/features/installments/presentation/pages/installment_wizard_page.dart';
import 'package:hisobchi_uz/features/partners/data/partner_models.dart';

final partner = Partner(
  id: 7,
  name: 'Farrux 3322',
  phone: '+998901234567',
  mainCurrencyTypeId: 1,
  mainCurrencyTypeName: 'UZS',
  balanceUzs: Decimal.zero,
  balanceUsd: Decimal.zero,
  installmentRemainingUzs: Decimal.zero,
  installmentRemainingUsd: Decimal.zero,
  sendOnKirim: false,
  sendOnChiqim: false,
);

Future<void> mount(
  WidgetTester tester, {
  double width = 393,
  bool dark = false,
  double scale = 1,
}) async {
  tester.view.physicalSize = Size(width, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  getIt.registerSingleton<InstallmentsRepository>(
    InstallmentsRepository(ApiClient(Dio())),
  );
  addTearDown(getIt.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark() : AppTheme.light(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: RepaintBoundary(
        key: const ValueKey('preview'),
        child: InstallmentWizardPage(partner: partner),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text(text).first);
  await tester.tap(find.text(text).first);
  await tester.pumpAndSettle();
}

Future<void> preview(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  if (const bool.fromEnvironment('SAVE_UI_PREVIEWS')) {
    await expectLater(
      find.byKey(const ValueKey('preview')),
      matchesGoldenFile('/tmp/hisobchi-installment-$name.png'),
    );
  }
}

void main() {
  setUpAll(() async {
    const fontPath = String.fromEnvironment('UI_PREVIEW_FONT');
    if (fontPath.isNotEmpty) {
      final loader = FontLoader('Roboto')
        ..addFont(
          Future.value(ByteData.sublistView(File(fontPath).readAsBytesSync())),
        );
      await loader.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
    }
  });
  testWidgets(
    'legacy cards, currency and draft survive navigation through equal schedule',
    (tester) async {
      await mount(tester);
      expect(find.text('1-bosqich • Asosiy ma’lumotlar'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, '1200000.50');
      await tester.enterText(
        find.widgetWithText(TextField, 'Tafsilotlarni yozishingiz mumkin...'),
        'Telefon uchun',
      );
      await preview(tester, 'basic');
      await tapText(tester, 'Davom etish');
      expect(find.text('2-bosqich • Grafik turi'), findsOneWidget);
      await preview(tester, 'types');
      await tapText(tester, 'Davom etish');
      expect(find.text('3-bosqich • Teng bo‘lib to‘lash'), findsOneWidget);
      expect(find.text('Taqsimot hisob-kitobi'), findsOneWidget);
      await preview(tester, 'equal');
      await tester.ensureVisible(find.byType(Switch));
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.text('AVANS').first, findsOneWidget);
      await tapText(tester, 'Orqaga');
      await tapText(tester, 'Orqaga');
      expect(find.text('1 200 000.50'), findsOneWidget);
      expect(find.text('Telefon uchun'), findsOneWidget);
      await tapText(tester, 'USD');
      expect(find.text('AQSH dollari'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('custom parts edit inline and reflect distribution immediately', (
    tester,
  ) async {
    await mount(tester);
    await tester.enterText(find.byType(TextField).first, '100');
    await tapText(tester, 'Davom etish');
    await tapText(tester, 'Erkin grafik');
    await tapText(tester, 'Davom etish');
    await tester.enterText(find.byType(TextField).first, '40');
    await tester.pumpAndSettle();
    final amountFields = find
        .byType(TextField)
        .evaluate()
        .where(
          (e) =>
              (e.widget as TextField).keyboardType ==
              const TextInputType.numberWithOptions(decimal: true),
        )
        .toList();
    final secondAmount = find.byWidget(amountFields.last.widget);
    await tester.ensureVisible(secondAmount);
    await tester.enterText(secondAmount, '60');
    await tester.pumpAndSettle();
    expect(find.text('To‘liq taqsimlandi'), findsOneWidget);
    await tester.ensureVisible(find.text('3-bosqich • Erkin grafik'));
    await preview(tester, 'custom');
    await tester.ensureVisible(find.byTooltip('Qismni olib tashlash').first);
    await tester.tap(find.byTooltip('Qismni olib tashlash').first);
    await tester.pumpAndSettle();
    expect(find.text('To‘liq taqsimlandi'), findsNothing);
    expect(find.text('60'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    testWidgets(
      '320px ${dark ? 'dark' : 'light'} layout supports large text without overflow',
      (tester) async {
        await mount(tester, width: 320, dark: dark, scale: 1.4);
        await tester.enterText(find.byType(TextField).first, '1000');
        await preview(tester, dark ? 'dark-small' : 'light-small');
        await tapText(tester, 'Davom etish');
        await tapText(tester, 'Davom etish');
        await tester.ensureVisible(find.byType(Switch));
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('To‘lov jadvali'));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
