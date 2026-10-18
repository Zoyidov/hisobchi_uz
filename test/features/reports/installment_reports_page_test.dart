import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/di/injector.dart';
import 'package:hisobchi_uz/core/network/api_client.dart';
import 'package:hisobchi_uz/core/theme/app_colors.dart';
import 'package:hisobchi_uz/features/reports/data/reports_repository.dart';
import 'package:hisobchi_uz/features/reports/presentation/pages/installment_reports_page.dart';

ReportsRepository repository({Object? result}) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'status': true,
              'result':
                  result ??
                  (options.queryParameters['currency_type_id'] == 1
                      ? []
                      : {
                          'active_count': 5,
                          'completed_count': 2,
                          'cancelled_count': 1,
                          'total_given': '99940592.00',
                          'total_paid': '88828492.00',
                          'total_remaining': '11112100.00',
                          'overdue_amount': '100000.00',
                        }),
            },
          ),
        );
      },
    ),
  );
  return ReportsRepository(ApiClient(dio));
}

void main() {
  test(
    'empty summary list is valid and normal maps preserve amounts',
    () async {
      final reports = repository();
      final empty = await reports.getInstallmentSummary(1);
      expect(empty.isSuccess, isTrue);
      expect(empty.dataOrNull!.isEmpty, isTrue);
      final filled = await reports.getInstallmentSummary(2);
      expect(filled.isSuccess, isTrue);
      expect(filled.dataOrNull!.totalRemaining.toString(), '11112100');
      expect(filled.dataOrNull!.activeCount, 5);
    },
  );
  test(
    'summary accepts the production list and selects the requested currency',
    () async {
      final reports = repository(
        result: [
          {
            'currency_type_id': 2,
            'active_plans': 9,
            'total_remaining': '999.00',
          },
          {
            'currency_type_id': 1,
            'currency_type_name': 'UZS',
            'active_plans': 1,
            'completed_plans': 0,
            'cancelled_plans': 0,
            'total_given': '80000.00',
            'total_paid': '8000.00',
            'total_remaining': '72000.00',
            'overdue_amount': '0.00',
          },
        ],
      );
      final result = await reports.getInstallmentSummary(1);
      expect(result.isSuccess, isTrue);
      final summary = result.dataOrNull!;
      expect(summary.activeCount, 1);
      expect(summary.completedCount, 0);
      expect(summary.cancelledCount, 0);
      expect(summary.totalGiven.toString(), '80000');
      expect(summary.totalPaid.toString(), '8000');
      expect(summary.totalRemaining.toString(), '72000');
      expect(summary.isEmpty, isFalse);
      final usd = await reports.getInstallmentSummary(2);
      expect(usd.dataOrNull!.activeCount, 9);
      final missing = await repository(
        result: [
          {'currency_type_id': 2, 'active_plans': 9},
        ],
      ).getInstallmentSummary(1);
      expect(missing.dataOrNull!.isEmpty, isTrue);
    },
  );

  testWidgets(
    'shows friendly empty state and compact summary on a small screen',
    (tester) async {
      tester.view.physicalSize = const Size(320, 760);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      getIt.registerSingleton<ReportsRepository>(repository());
      addTearDown(getIt.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: const InstallmentReportsPage(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bo‘lib to‘lash ma’lumoti yo‘q'), findsOneWidget);
      expect(find.textContaining('type'), findsNothing);
      await tester.tap(find.text('USD'));
      await tester.pumpAndSettle();
      expect(find.text('Qolgan'), findsOneWidget);
      expect(find.text('11 112 100 USD'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
