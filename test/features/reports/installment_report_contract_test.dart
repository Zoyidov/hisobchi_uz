import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/di/injector.dart';
import 'package:hisobchi_uz/core/network/api_client.dart';
import 'package:hisobchi_uz/core/theme/app_theme.dart';
import 'package:hisobchi_uz/features/reports/data/reports_repository.dart';
import 'package:hisobchi_uz/features/reports/presentation/pages/installment_reports_page.dart';

const summary = {
  'currency_type_id': 1,
  'active_plans': 1,
  'completed_plans': 2,
  'cancelled_plans': 0,
  'total_given': '80000.00',
  'total_paid': '8000.00',
  'total_remaining': '72000.00',
  'overdue_amount': '1000.00',
};
const recovery = {
  'currency_type_id': 1,
  'recovery_rate': '10.00',
  'overdue_rate': '1.25',
  'rating_label': 'Past',
  'total_given': '80000.00',
  'total_collected': '8000.00',
  'total_remaining': '72000.00',
  'overdue_amount': '1000.00',
  'by_items': {'paid': 1, 'partial': 1, 'overdue': 1, 'pending': 2},
};

ReportsRepository fixture(List<RequestOptions> requests) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        requests.add(options);
        final Object result = switch (options.path.split('/').last) {
          'summary' => [summary],
          'recovery' => [
            recovery,
            {
              'currency_type_id': 2,
              'recovery_rate': '90.00',
              'total_collected': '99.50',
            },
          ],
          'forecast' => [
            {
              'currency_type_id': 1,
              'period_days': 30,
              'date_from': '2026-10-19',
              'date_to': '2026-11-18',
              'expected_amount': '30000.50',
              'items_count': 3,
              'partners_count': 2,
            },
          ],
          'monthly' => [
            {
              'currency_type_id': 1,
              'year': 2026,
              'months': [
                {
                  'month': 10,
                  'month_label': 'Okt',
                  'payments_count': 2,
                  'total_amount': '8000.50',
                },
              ],
            },
          ],
          'risky-partners' => [
            {
              'partner_id': 7,
              'partner_name': 'Farrux',
              'partner_phone': '+998901234567',
              'risk_score': 75,
              'risk_level': 'high',
              'overdue_items': 2,
              'overdue_amount': '1000.00',
              'avg_days_overdue': 5,
              'total_remaining': '72000.00',
            },
          ],
          'partners' => {
            'data': [
              {
                'partner_id': 7,
                'partner_name': 'Farrux',
                'partner_phone': '+998901234567',
                'active_plans': 1,
                'total_given': '80000',
                'total_paid': '8000',
                'total_remaining': '72000',
                'overdue_amount': '1000',
              },
            ],
            'links': {
              'next': options.queryParameters['page'] == 1 ? 'next-page' : null,
            },
            'meta': {'current_page': 1},
          },
          'items' => {
            'data': [
              {
                'plan_id': 10,
                'partner_name': 'Farrux',
                'item_number': 1,
                'amount': '20000',
                'paid_amount': '8000',
                'remaining': '12000',
                'due_date': '2026-11-19',
                'status_label': 'Qisman to‘langan',
              },
            ],
            'next_page_url': null,
          },
          _ => [],
        };
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {'status': true, 'result': result},
          ),
        );
      },
    ),
  );
  return ReportsRepository(ApiClient(dio));
}

void main() {
  setUpAll(() async {
    const path = String.fromEnvironment('UI_PREVIEW_FONT');
    if (path.isNotEmpty) {
      await (FontLoader('Roboto')..addFont(
            Future.value(ByteData.sublistView(File(path).readAsBytesSync())),
          ))
          .load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    }
  });
  test(
    'legacy recovery, monthly, forecast, partner and item response shapes preserve values',
    () async {
      final requests = <RequestOptions>[];
      final repo = fixture(requests);
      final report = (await repo.getRecoveryReport(1)).dataOrNull!;
      expect(report.recoveryRate, 10);
      expect(report.recoveredAmount.toString(), '8000');
      expect(report.byItems['partial'], 1);
      expect(
        (await repo.getRecoveryReport(
          2,
        )).dataOrNull!.recoveredAmount.toString(),
        '99.5',
      );
      final months = (await repo.getMonthlyInstallments(
        year: 2026,
        currencyTypeId: 1,
      )).dataOrNull!;
      expect(months.single.amount.toString(), '8000.5');
      expect(months.single.paymentsCount, 2);
      expect(
        (await repo.getMonthlyInstallments(
          year: 2026,
          currencyTypeId: 2,
        )).dataOrNull,
        isEmpty,
      );
      final forecast = (await repo.getInstallmentForecast(
        currencyTypeId: 1,
        dateFrom: DateTime(2026, 10, 19),
        dateTo: DateTime(2026, 11, 18),
      )).dataOrNull!;
      expect(forecast.expectedAmount.toString(), '30000.5');
      expect(forecast.itemsCount, 3);
      expect(requests.last.queryParameters, {
        'currency_type_id': 1,
        'date_from': '19.10.2026',
        'date_to': '18.11.2026',
      });
      final risky = (await repo.getRiskyPartners(1)).dataOrNull!.single;
      expect(risky.averageDelayDays, 5);
      expect(risky.overdueAmount.toString(), '1000');
      final partners = (await repo.getInstallmentPartners(1)).dataOrNull!;
      expect(partners.hasNext, isTrue);
      expect(partners.items.single.remaining.toString(), '72000');
      expect(requests.last.queryParameters['sort'], 'remaining');
      expect(
        (await repo.getInstallmentPartners(1, page: 2)).dataOrNull!.hasNext,
        isFalse,
      );
      final items = (await repo.getInstallmentReportItems(
        currencyTypeId: 1,
        status: 'partial',
      )).dataOrNull!;
      expect(items.items.single.planId, 10);
      expect(items.items.single.remaining.toString(), '12000');
      expect(requests.last.queryParameters['status'], 'partial');
    },
  );

  testWidgets(
    'overview opens legacy report pages and sends date and year filters',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final requests = <RequestOptions>[];
      getIt.registerSingleton<ReportsRepository>(fixture(requests));
      addTearDown(getIt.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const InstallmentReportsPage(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Faol rejalar'), findsOneWidget);
      expect(find.byType(TabBar), findsNothing);
      Future<void> open(String title) async {
        await tester.ensureVisible(find.text(title));
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
      }

      Future<void> back() async {
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      await open('Undirish samaradorligi');
      expect(find.text('10.0%'), findsOneWidget);
      await open('Qisman to‘langan');
      expect(requests.last.path, endsWith('/items'));
      expect(requests.last.queryParameters['status'], 'partial');
      await back();
      await back();
      await open('Kutilayotgan to‘lovlar');
      expect(find.text('30 000,5 UZS'), findsOneWidget);
      await tester.tap(find.text('60 kun'));
      await tester.pumpAndSettle();
      expect(requests.last.path, endsWith('/forecast'));
      await back();
      await open('Oylik dinamika');
      await tester.tap(find.byTooltip('Oldingi yil'));
      await tester.pumpAndSettle();
      expect(requests.last.queryParameters['year'], DateTime.now().year - 1);
      await back();
      await open('Muammoli mijozlar');
      expect(find.text('Yuqori xavf'), findsOneWidget);
      await back();
      await open('Mijozlar bo‘yicha');
      expect(find.text('72 000 UZS'), findsOneWidget);
      await tester.ensureVisible(find.text('Yana yuklash'));
      await tester.tap(find.text('Yana yuklash'));
      await tester.pumpAndSettle();
      expect(requests.last.queryParameters['page'], 2);
      expect(tester.takeException(), isNull);
    },
  );
  for (final dark in [false, true]) {
    testWidgets(
      'report overview adapts to 320px ${dark ? 'dark' : 'light'} layout',
      (tester) async {
        tester.view.physicalSize = const Size(320, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        getIt.registerSingleton<ReportsRepository>(fixture([]));
        addTearDown(getIt.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.dark() : AppTheme.light(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: const RepaintBoundary(
              key: ValueKey('report-preview'),
              child: InstallmentReportsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (const bool.fromEnvironment('SAVE_UI_PREVIEWS')) {
          await expectLater(
            find.byKey(const ValueKey('report-preview')),
            matchesGoldenFile(
              '/tmp/hisobchi-installment-report-${dark ? 'dark' : 'light'}.png',
            ),
          );
        }
        await tester.scrollUntilVisible(
          find.text('Mijozlar bo‘yicha'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Mijozlar bo‘yicha'));
        await tester.pumpAndSettle();
        expect(find.text('72 000 UZS'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
