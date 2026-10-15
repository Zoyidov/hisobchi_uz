import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/network/api_client.dart';
import 'package:hisobchi_uz/features/projects/data/projects_repository.dart';
import 'package:hisobchi_uz/features/projects/presentation/cubit/project_subtabs_cubit.dart';

void main() {
  test('parses paginated cost response and requests subsequent pages', () async {
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
                      'currency_type_name': 'UZS',
                      'cost_type_id': page == 1 ? 1 : 2,
                      'cost_type_name': page == 1
                          ? 'Ish haqi / Avans'
                          : 'Oziq-ovqat',
                      'worker_id': page == 1 ? 5 : null,
                      'worker_name': page == 1 ? 'Umidjon 123' : null,
                      'summa': page == 1 ? 700000 : 1000000,
                      'description': null,
                      'files': [],
                      'project_id': 4,
                      'created_at': '04.03.2026 11:44:34',
                      'deleted_at': null,
                    },
                  ],
                  'links': {
                    'next': page == 1
                        ? 'https://api.pulza.uz/api/project/project-costs?page=2'
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
    final cubit = ProjectCostsCubit(ProjectsRepository(ApiClient(dio)), 4);
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.failure, isNull);
    expect(cubit.state.items.single.id, 9);
    expect(cubit.state.items.single.currencyTypeName, 'UZS');
    expect(cubit.state.items.single.summa.toString(), '700000');
    expect(cubit.state.items.single.workerName, 'Umidjon 123');
    expect(cubit.state.hasNext, isTrue);
    await cubit.loadMore();
    expect(cubit.state.items.last.workerId, isNull);
    expect(cubit.state.items.map((income) => income.id), [9, 8]);
    expect(cubit.state.hasNext, isFalse);
    expect(requests.map((request) => request.queryParameters['page']), [1, 2]);
    expect(
      requests.every(
        (request) =>
            request.path == '/project/project-costs' &&
            request.queryParameters['project_id'] == 4,
      ),
      isTrue,
    );
    await cubit.loadMore();
    expect(requests.length, 2);
  });
}
