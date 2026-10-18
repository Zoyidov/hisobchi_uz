import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/cubits/user_cubit.dart';
import 'package:hisobchi_uz/core/cubits/owner_context_cubit.dart';
import 'package:hisobchi_uz/core/storage/secure_storage_service.dart';
import 'package:hisobchi_uz/core/domain/repositories/auth_repository.dart';
import 'package:hisobchi_uz/core/domain/entities/user_entity.dart';
import 'package:hisobchi_uz/core/di/injector.dart';
import 'package:hisobchi_uz/core/network/api_client.dart';
import 'package:hisobchi_uz/core/theme/app_theme.dart';
import 'package:hisobchi_uz/features/partners/data/partners_repository.dart';
import 'package:hisobchi_uz/features/reports/data/reports_repository.dart';
import 'package:hisobchi_uz/features/reports/presentation/pages/partner_reports_page.dart';

class _Auth implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _User extends UserCubit {
  _User() : super(_Auth()) {
    emit(
      UserLoaded(
        UserEntity.fromJson({
          'user_id': 1,
          'permissions': ['report_installments.view'],
        }),
      ),
    );
  }
}

ApiClient fixture(List<RequestOptions> requests, {bool paginate = true}) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        requests.add(options);
        if (options.path.endsWith('/export/excel')) {
          handler.resolve(
            Response(requestOptions: options, statusCode: 200, data: [1, 2, 3]),
          );
          return;
        }
        final Object result = switch (options.path.split('/').last) {
          'summary' => {
            for (final currency in ['UZS', 'USD'])
              currency: {
                'debt': '100030592.75',
                'credit': '88828492.25',
                'balance': currency == 'UZS' ? '11202100.50' : '-50.25',
                'partners_count': 3,
                'operations': {'count': 21},
                'qarzdorlar': {'count': 1},
                'xaqdorlar': {'count': 2},
              },
          },
          'summary-details-section-two' => {
            'data': [
              {'id': 7, 'name': 'Farrux', 'balance': '300.50'},
            ],
            'next_page_url': paginate && options.queryParameters['page'] == 1
                ? 'next'
                : null,
          },
          'warranty-periods' => {
            for (final currency in ['UZS', 'USD'])
              currency: {
                'qarz_expired': {'count': 2},
                'qarz_today': {'count': 1},
                'qarz_3_days': {'count': 3},
              },
          },
          'workers' || 'periods' => {
            for (final currency in ['UZS', 'USD'])
              currency: {'debt': '1000.50', 'credit': '500.25'},
          },
          'workers-lists' => [],
          'summary-details-section-one' ||
          'periods-operations' ||
          'warranty-periods-details' => {
            'data': [
              {
                'id': 9,
                'partner_id': 7,
                'partner_name': 'Farrux',
                'type': 'debt',
                'scheduled_amount': '1000.50',
                'paid_amount': '500.25',
                'remaining_amount': '500.25',
                'created_at': '19.10.2026',
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
    'uses legacy summary, operation, creditor, period and export contracts',
    () async {
      final requests = <RequestOptions>[];
      final client = fixture(requests);
      final repo = ReportsRepository(client);
      final summary = (await repo.getPartnersSummaryReports()).dataOrNull!;
      expect(summary['UZS']!.balance.toString(), '11202100.5');
      expect(summary['USD']!.balance.toString(), '-50.25');
      expect(requests.single.path, '/reports/partners-v3/summary');
      final operations = (await repo.getPartnersMainOperations(
        currencyTypeId: 2,
      )).dataOrNull!;
      expect(operations.items.single.partnerId, 7);
      expect(
        requests.last.path,
        '/reports/partners-v2/summary-details-section-one',
      );
      expect(requests.last.queryParameters['type'], 'oparation');
      final debtors = (await repo.getPartnersSummaryDetails(
        type: 'qarzdor',
        currencyTypeId: 1,
      )).dataOrNull!;
      expect(debtors.hasNext, isTrue);
      expect(
        requests.last.path,
        '/reports/partners-v2/summary-details-section-two',
      );
      expect(
        (await repo.getPartnersSummaryDetails(
          type: 'xaqdor',
          currencyTypeId: 2,
          page: 2,
        )).dataOrNull!.hasNext,
        isFalse,
      );
      await repo.getPartnersPeriods(
        from: DateTime(2026, 10, 1),
        to: DateTime(2026, 10, 19),
      );
      expect(requests.last.data, {
        'date': ['01.10.2026', '19.10.2026'],
      });
      await repo.getPartnersPeriodOperations(
        type: 'debt',
        currencyTypeId: 1,
        from: DateTime(2026, 10, 1),
        to: DateTime(2026, 10, 19),
      );
      expect(requests.last.queryParameters['date[]'], [
        '01.10.2026',
        '19.10.2026',
      ]);
      final bytes = await PartnersRepository(client).exportPartnersExcel();
      expect(bytes.dataOrNull, [1, 2, 3]);
      expect(requests.last.path, '/partners/partners/export/excel');
    },
  );
  for (final dark in [false, true]) {
    testWidgets(
      'legacy main layout, signs, currency and linked report pages (${dark ? 'dark' : 'light'})',
      (tester) async {
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final requests = <RequestOptions>[];
        final client = fixture(requests, paginate: false);
        getIt.registerSingleton<ReportsRepository>(ReportsRepository(client));
        getIt.registerSingleton<PartnersRepository>(PartnersRepository(client));
        addTearDown(getIt.reset);
        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<UserCubit>(create: (_) => _User()),
              BlocProvider(
                create: (_) => OwnerContextCubit(SecureStorageService()),
              ),
            ],
            child: MaterialApp(
              theme: dark ? AppTheme.dark() : AppTheme.light(),
              home: const RepaintBoundary(
                key: ValueKey('main-preview'),
                child: PartnerReportsPage(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(TabBar), findsNothing);
        expect(find.text('Qoldiq'), findsOneWidget);
        expect(find.text('−11 202 100,5 UZS'), findsOneWidget);
        if (const bool.fromEnvironment('SAVE_UI_PREVIEWS')) {
          await expectLater(
            find.byKey(const ValueKey('main-preview')),
            matchesGoldenFile(
              '/tmp/hisobchi-partner-main-${dark ? 'dark' : 'light'}.png',
            ),
          );
        }
        await tester.tap(find.text('USD Hisob'));
        await tester.pumpAndSettle();
        expect(find.text('50,25 USD'), findsOneWidget);
        expect(requests.where((r) => r.path.endsWith('/summary')).length, 1);
        Future<void> open(String label) async {
          await tester.scrollUntilVisible(
            find.text(label),
            250,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.tap(find.text(label));
          await tester.pumpAndSettle();
        }

        await open('Operatsiyalar');
        expect(requests.last.queryParameters['type'], 'oparation');
        expect(requests.last.queryParameters['currency_type_id'], 2);
        await tester.pageBack();
        await tester.pumpAndSettle();
        await open('Qarzdorlar');
        expect(requests.last.path, endsWith('/summary-details-section-two'));
        expect(requests.last.queryParameters['type'], 'qarzdor');
        await tester.pageBack();
        await tester.pumpAndSettle();
        await open('Qarz muddatlari hisoboti');
        await tester.tap(find.text('Bugun'));
        await tester.pumpAndSettle();
        expect(requests.last.path, endsWith('/warranty-periods-details'));
        expect(requests.last.queryParameters['type'], 'qarz_today');
        await tester.pageBack();
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();
        await open('Muddat hisoboti');
        await tester.tap(find.text('Kirim'));
        await tester.pumpAndSettle();
        expect(requests.last.path, endsWith('/periods-operations'));
        expect(requests.last.queryParameters['type'], 'debt');
        await tester.pageBack();
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();
        await open('Xodimlar hisoboti');
        expect(requests.any((r) => r.path.endsWith('/workers')), isTrue);
        expect(requests.any((r) => r.path.endsWith('/workers-lists')), isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
