import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/network/api_client.dart';
import 'package:hisobchi_uz/features/reports/data/reports_repository.dart';

void main() {
  test(
    'installment partners accepts empty and subsequent paginator pages',
    () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.queryParameters['currency_type_id'], 1);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'status': true,
                  'result': {
                    'current_page': options.queryParameters['page'],
                    'data': [],
                    'next_page_url': options.queryParameters['page'] == 1
                        ? '/partners?page=2'
                        : null,
                  },
                },
              ),
            );
          },
        ),
      );
      final repository = ReportsRepository(ApiClient(dio));
      final first = await repository.getInstallmentPartners(1);
      first.when(
        success: (page) {
          expect(page.items, isEmpty);
          expect(page.hasNext, isTrue);
        },
        failure: (error) => fail(error.message),
      );
      final last = await repository.getInstallmentPartners(1, page: 2);
      last.when(
        success: (page) {
          expect(page.items, isEmpty);
          expect(page.hasNext, isFalse);
        },
        failure: (error) => fail(error.message),
      );
    },
  );
  test(
    'workers API receives currency and optional reference date array',
    () async {
      final requests = <RequestOptions>[];
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests.add(options);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'status': true,
                  'result': [
                    {
                      'id': 7,
                      'name': 'Farrux',
                      'role': 'Admin',
                      'debt': '1500.50',
                      'credit': '200',
                      'operations_count': 3,
                    },
                  ],
                },
              ),
            );
          },
        ),
      );
      final repository = ReportsRepository(ApiClient(dio));
      final result = await repository.getWorkersReport(currencyTypeId: 2);
      result.when(
        success: (items) {
          expect(items.single.name, 'Farrux');
          expect(items.single.debt.toString(), '1500.5');
          expect(items.single.operationsCount, 3);
        },
        failure: (error) => fail(error.message),
      );
      expect(requests.single.path, '/reports/partners-v3/workers-lists');
      expect(requests.single.queryParameters, {'currency_type_id': 2});
      await repository.getWorkersReport(
        currencyTypeId: 1,
        from: DateTime(2026, 10, 1),
        to: DateTime(2026, 10, 17),
      );
      expect(requests.last.queryParameters, {
        'currency_type_id': 1,
        'date[]': ['01.10.2026', '17.10.2026'],
      });
    },
  );
}
