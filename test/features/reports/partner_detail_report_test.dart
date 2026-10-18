import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/di/injector.dart';
import 'package:hisobchi_uz/core/network/api_client.dart';
import 'package:hisobchi_uz/core/theme/app_theme.dart';
import 'package:hisobchi_uz/features/partners/data/partners_repository.dart';
import 'package:hisobchi_uz/features/reports/data/reports_repository.dart';
import 'package:hisobchi_uz/features/reports/presentation/pages/partner_detail_report_page.dart';
import 'package:hisobchi_uz/features/reports/presentation/pages/report_detail_list_page.dart';

Map<String, Object> currencyReport(String balance) => {
  'balance': balance,
  'income': '99940592.75',
  'expense': '88828492.25',
  'operations_count': '12',
  'qarz_expired': {'count': '2'},
  'qarz_today': {'count': 1},
  'qarz_3_days': {'count': 3},
  'monthly_statistics': [
    {'month': 'Okt', 'income': '99940592.75', 'expense': '88828492.25'},
  ],
  'balance_dynamics': [
    {'date': '19.10.2026', 'balance': balance},
  ],
};
ApiClient fixture(List<RequestOptions> requests) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        requests.add(options);
        final Object result = options.path.contains('partner-details/7')
            ? {
                'UZS': currencyReport('-11112100.50'),
                'USD': currencyReport('99.25'),
              }
            : options.path.contains('/installments/partner/7')
            ? {
                'partner_id': 7,
                'partner_name': 'Farrux',
                'partner_phone': '+998901234567',
                'stats': [],
                'plans': [],
                'payments': [],
                'items': [],
                'monthly_dynamics': [],
              }
            : {
                'data': [
                  {'id': 7, 'name': 'Farrux', 'balance': '-11112100.50'},
                ],
                'next_page_url': null,
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
  return ApiClient(dio);
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
    'legacy partner detail API preserves cents, counts and both currencies',
    () async {
      final requests = <RequestOptions>[];
      final repo = ReportsRepository(fixture(requests));
      final result = (await repo.getPartnerDetailReport(7)).dataOrNull!;
      expect(requests.single.path, '/reports/partners-v2/partner-details/7');
      expect(result.uzs.balance.toString(), '-11112100.5');
      expect(result.usd.balance.toString(), '99.25');
      expect(result.uzs.operationsCount, 12);
      expect(result.uzs.qarzExpired, 2);
      expect(
        result.uzs.monthlyStatistics.single.income.toString(),
        '99940592.75',
      );
      expect(
        result.uzs.balanceDynamics.single.balance.toString(),
        '-11112100.5',
      );
    },
  );

  for (final dark in [false, true]) {
    testWidgets(
      'inner report opens from partner list and supports currency, installment and debt views (${dark ? 'dark' : 'light'})',
      (tester) async {
        tester.view.physicalSize = const Size(320, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final requests = <RequestOptions>[];
        final client = fixture(requests);
        final repo = ReportsRepository(client);
        getIt.registerSingleton<ReportsRepository>(repo);
        getIt.registerSingleton<PartnersRepository>(PartnersRepository(client));
        addTearDown(getIt.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.dark() : AppTheme.light(),
            home: ReportDetailListPage(
              title: 'Hamkorlar',
              currencyTypeId: 1,
              fetcher: (page) => repo.getPartnersSummaryDetails(
                type: 'qarzdorlar',
                currencyTypeId: 1,
                page: page,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Farrux'));
        await tester.pumpAndSettle();
        expect(find.byType(PartnerDetailReportPage), findsOneWidget);
        if (const bool.fromEnvironment('SAVE_UI_PREVIEWS')) {
          final boundary = find
              .ancestor(
                of: find.byType(PartnerDetailReportPage),
                matching: find.byType(RepaintBoundary),
              )
              .first;
          await expectLater(
            boundary,
            matchesGoldenFile(
              '/tmp/hisobchi-partner-report-${dark ? 'dark' : 'light'}.png',
            ),
          );
        }
        expect(find.text('Hisob kitob'), findsOneWidget);
        expect(find.text('−11 112 100,5'), findsOneWidget);
        expect(find.text('99 940 592,75'), findsOneWidget);
        await tester.tap(find.text('USD Hisob'));
        await tester.pumpAndSettle();
        expect(find.text('99,25'), findsOneWidget);
        await tester.tap(find.text("Muddatli to'lov"));
        await tester.pumpAndSettle();
        expect(
          requests.any((r) => r.path == '/reports/installments/partner/7'),
          isTrue,
        );
        await tester.tap(find.text('Hisob kitob'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Bugun'));
        await tester.tap(find.text('Bugun'));
        await tester.pumpAndSettle();
        expect(requests.last.queryParameters['partner_id'], 7);
        expect(requests.last.queryParameters['type'], 'qarz_today');
        expect(requests.last.queryParameters['currency_type_id'], 2);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
