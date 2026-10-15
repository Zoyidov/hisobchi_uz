import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/paging/paged_list_cubit.dart';
import '../../data/partner_models.dart';
import '../../data/partners_repository.dart';

/// Independent selector pagination; a search invalidates all older requests.
class PartnerSelectionCubit extends Cubit<PagedListState<Partner>> {
  PartnerSelectionCubit(this._repository) : super(PagedListState.initial());
  final PartnersRepository _repository;
  Timer? _debounce;
  String _query = '';
  int _generation = 0;

  void search(String value) {
    _debounce?.cancel();
    _query = value.trim();
    _generation++;
    emit(PagedListState.initial());
    _debounce = Timer(
      const Duration(milliseconds: AppDurations.searchDebounceMs),
      loadFirst,
    );
  }

  Future<void> loadFirst() async {
    if (isClosed) return;
    _debounce?.cancel();
    final generation = ++_generation;
    emit(PagedListState.initial());
    await _fetch(1, generation);
  }

  Future<void> loadMore() async {
    if (isClosed || state.isLoading || state.isLoadingMore || !state.hasNext) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true, clearFailure: true));
    await _fetch(state.currentPage + 1, _generation);
  }

  Future<void> _fetch(int page, int generation) async {
    final result = await _repository.getPartners(page: page, search: _query);
    if (isClosed || generation != _generation) return;
    result.when(
      success: (data) {
        final byId = <int, Partner>{
          if (page > 1)
            for (final item in state.items) item.id: item,
          for (final item in data.items) item.id: item,
        };
        emit(
          PagedListState(
            items: byId.values.toList(),
            hasNext: data.hasNext,
            currentPage: page,
            isLoading: false,
            isLoadingMore: false,
          ),
        );
      },
      failure: (failure) => emit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          failure: failure,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    _generation++;
    return super.close();
  }
}
