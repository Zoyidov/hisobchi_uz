import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/errors/failure.dart';
import 'package:hisobchi_uz/core/network/api_client.dart';
import 'package:hisobchi_uz/core/network/api_result.dart';
import 'package:hisobchi_uz/core/network/paged_result.dart';
import 'package:hisobchi_uz/features/partners/data/partner_models.dart';
import 'package:hisobchi_uz/features/partners/data/partners_repository.dart';
import 'package:hisobchi_uz/features/partners/presentation/cubit/partner_selection_cubit.dart';

class _Repository extends PartnersRepository {
  _Repository() : super(ApiClient(Dio()));
  final calls =
      <
        ({
          int page,
          String? search,
          Completer<ApiResult<SimplePage<Partner>>> response,
        })
      >[];

  @override
  Future<ApiResult<SimplePage<Partner>>> getPartners({
    required int page,
    String? search,
    PartnerStatusFilter status = PartnerStatusFilter.all,
    PartnerSort sort = PartnerSort.lastActivity,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    final response = Completer<ApiResult<SimplePage<Partner>>>();
    calls.add((page: page, search: search, response: response));
    return response.future;
  }

  void succeed(int index, List<int> ids, {bool hasNext = false}) =>
      calls[index].response.complete(
        ApiResult.success(
          SimplePage(
            items: ids
                .map((id) => Partner.placeholder(id: id, name: 'Partner $id'))
                .toList(),
            hasNext: hasNext,
          ),
        ),
      );
}

void main() {
  test(
    'appends pages, deduplicates, prevents parallel loads and stops at end',
    () async {
      final repository = _Repository();
      final cubit = PartnerSelectionCubit(repository);
      addTearDown(cubit.close);
      final first = cubit.loadFirst();
      repository.succeed(0, [1, 2], hasNext: true);
      await first;
      final more = cubit.loadMore();
      await cubit.loadMore();
      expect(repository.calls.length, 2);
      expect(repository.calls[1].page, 2);
      repository.succeed(1, [2, 3]);
      await more;
      expect(cubit.state.items.map((p) => p.id), [1, 2, 3]);
      await cubit.loadMore();
      expect(repository.calls.length, 2);
    },
  );

  test(
    'search invalidates old responses before debounce and resets page',
    () async {
      final repository = _Repository();
      final cubit = PartnerSelectionCubit(repository);
      addTearDown(cubit.close);
      final stale = cubit.loadFirst();
      cubit.search('  Ali  ');
      repository.succeed(0, [1]);
      await stale;
      expect(cubit.state.items, isEmpty);
      final latest = cubit.loadFirst();
      expect(repository.calls[1].page, 1);
      expect(repository.calls[1].search, 'Ali');
      repository.succeed(1, [4]);
      await latest;
      expect(cubit.state.items.single.id, 4);
    },
  );

  test('failed next page preserves items and retries the same page', () async {
    final repository = _Repository();
    final cubit = PartnerSelectionCubit(repository);
    addTearDown(cubit.close);
    final first = cubit.loadFirst();
    repository.succeed(0, [1], hasNext: true);
    await first;
    final more = cubit.loadMore();
    repository.calls[1].response.complete(
      const ApiResult.failure(BusinessFailure('Failed')),
    );
    await more;
    expect(cubit.state.items.single.id, 1);
    expect(cubit.state.failure, isNotNull);
    final retry = cubit.loadMore();
    expect(repository.calls[2].page, 2);
    repository.succeed(2, [2]);
    await retry;
    expect(cubit.state.failure, isNull);
    expect(cubit.state.items.length, 2);
  });
}
