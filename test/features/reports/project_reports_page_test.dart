import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/di/injector.dart';
import 'package:hisobchi_uz/core/network/api_client.dart';
import 'package:hisobchi_uz/core/theme/app_theme.dart';
import 'package:hisobchi_uz/features/projects/data/projects_repository.dart';
import 'package:hisobchi_uz/features/reports/data/reports_repository.dart';
import 'package:hisobchi_uz/features/reports/presentation/pages/project_reports_page.dart';

const report = {
  'income_uzs': '2000.75',
  'income_usd': 12.75,
  'balance_uzs': '1000.25',
  'balance_usd': 7.25,
  'costs': {
    'cost_uzs': '1000.50',
    'cost_usd': 5.5,
    'details': [
      {
        'cost_type_id': 7,
        'cost_type_name': 'Materiallar',
        'summa_uzs': '750.25',
        'summa_usd': 5.5,
      },
      {
        'cost_type_id': 8,
        'cost_type_name': 'Ish haqi',
        'summa_uzs': '250.25',
        'summa_usd': 0,
      },
    ],
  },
};
ApiClient fixture(List<RequestOptions> requests) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        requests.add(options);
        Object result;
        if (options.path.endsWith('/balance')) {
          result = report;
        } else if (options.path.endsWith('/projects')) {
          final first =
              options.queryParameters['page'] == 1 &&
              options.queryParameters['search'] == null;
          result = {
            'data': [
              {
                'id': first ? 1 : 37,
                'project_name': first ? 'Birinchi loyiha' : 'Sinov loyiha',
                'project_owner': 'Farrux',
                'phone': '901234567',
                'status': 'in_progress',
              },
            ],
            'links': {'next': first ? 'page2' : null},
          };
        } else {
          result = {
            'data': [],
            'links': {'next': null},
          };
        }
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
    'legacy project report fields preserve both currencies and category IDs',
    () async {
      final requests = <RequestOptions>[];
      final result = (await ReportsRepository(
        fixture(requests),
      ).getProjectBalance(37)).dataOrNull!;
      expect(requests.single.path, '/reports/projects/balance');
      expect(requests.single.queryParameters['project_id'], 37);
      expect(result.costsUzs.toString(), '1000.5');
      expect(result.costsUsd.toString(), '5.5');
      expect(result.balanceUsd.toString(), '7.25');
      expect(result.details.first.costTypeId, 7);
      expect(result.details.first.amount.toString(), '750.25');
      expect(result.details.first.summaUsd.toString(), '5.5');
    },
  );
  for (final dark in [false, true]) {
    testWidgets(
      'financial cards, paged selection and filtered category navigation (${dark ? 'dark' : 'light'})',
      (tester) async {
        tester.view.physicalSize = Size(dark ? 320 : 393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final requests = <RequestOptions>[];
        final client = fixture(requests);
        getIt.registerSingleton<ReportsRepository>(ReportsRepository(client));
        getIt.registerSingleton<ProjectsRepository>(ProjectsRepository(client));
        addTearDown(getIt.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.dark() : AppTheme.light(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(dark ? 1.3 : 1)),
              child: child!,
            ),
            home: const RepaintBoundary(
              key: ValueKey('project-preview'),
              child: ProjectReportsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Loyihani tanlang'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Yana yuklash'));
        await tester.pumpAndSettle();
        expect(requests.last.queryParameters['page'], 2);
        await tester.tap(find.text('Sinov loyiha'));
        await tester.pumpAndSettle();
        expect(find.text('Qoldiq'), findsOneWidget);
        expect(find.text('1 000,25 UZS'), findsOneWidget);
        expect(find.text('7,25 USD'), findsOneWidget);
        expect(find.text('1 000,5 UZS'), findsOneWidget);
        if (const bool.fromEnvironment('SAVE_UI_PREVIEWS')) {
          await expectLater(
            find.byKey(const ValueKey('project-preview')),
            matchesGoldenFile(
              '/tmp/hisobchi-project-report-${dark ? 'dark' : 'light'}.png',
            ),
          );
        }
        await tester.tap(find.text('Kirim'));
        await tester.pumpAndSettle();
        expect(requests.last.path, '/project/project-incomes');
        expect(requests.last.queryParameters['project_id'], 37);
        await tester.pageBack();
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Materiallar'),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Materiallar'));
        await tester.pumpAndSettle();
        expect(requests.last.path, '/project/project-costs');
        expect(requests.last.queryParameters['cost_type_id'], 7);
        expect(requests.last.queryParameters['project_id'], 37);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(requests.last.path, '/reports/projects/balance');
        await tester.tap(find.text('Sinov loyiha'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Sinov');
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pumpAndSettle();
        expect(requests.last.queryParameters['search'], 'Sinov');
        expect(tester.takeException(), isNull);
      },
    );
  }
}
