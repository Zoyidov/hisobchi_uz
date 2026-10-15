import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/network/api_client.dart';
import 'package:hisobchi_uz/features/projects/data/projects_repository.dart';
import 'package:hisobchi_uz/features/projects/presentation/cubit/project_subtabs_cubit.dart';

void main() {
  test('parses paginated income response and requests subsequent pages', () async {
    final requests = <RequestOptions>[];
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          final page = options.queryParameters['page'] as int;
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'status': true,
                'result': {
                  'data': [
                    {
                      'id': page == 1 ? 9 : 8,
                      'currency_type_id': 1,
                      'currency_type': 'UZS',
                      'summa': page == 1 ? 700000 : 1000000,
                      'description': null,
                      'files': [
                        {
                          'id': 732,
                          'url':
                              'https://example.com/photo.webp?X-Amz-Signature=test',
                        },
                      ],
                      'project_id': 4,
                      'created_at': '04.03.2026 11:44:34',
                      'deleted_at': null,
                    },
                  ],
                  'links': {
                    'next': page == 1
                        ? 'https://api.pulza.uz/api/project/project-incomes?page=2'
                        : null,
                  },
                  'meta': {'current_page': page, 'per_page': 15},
                },
              },
            ),
          );
        },
      ),
    );
    final cubit = ProjectIncomesCubit(ProjectsRepository(ApiClient(dio)), 4);
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.failure, isNull);
    expect(cubit.state.items.single.id, 9);
    expect(cubit.state.items.single.currencyTypeName, 'UZS');
    expect(cubit.state.items.single.summa.toString(), '700000');
    expect(cubit.state.items.single.files.single.id, 732);
    expect(
      cubit.state.items.single.files.single.url,
      'https://example.com/photo.webp?X-Amz-Signature=test',
    );
    expect(cubit.state.hasNext, isTrue);
    await cubit.loadMore();
    expect(cubit.state.items.map((income) => income.id), [9, 8]);
    expect(cubit.state.hasNext, isFalse);
    expect(requests.map((request) => request.queryParameters['page']), [1, 2]);
    expect(
      requests.every(
        (request) =>
            request.path == '/project/project-incomes' &&
            request.queryParameters['project_id'] == 4,
      ),
      isTrue,
    );
    await cubit.loadMore();
    expect(requests.length, 2);
  });
}
