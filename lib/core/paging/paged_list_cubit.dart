import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../errors/failure.dart';
import '../network/api_result.dart';
import '../network/paged_result.dart';

class PagedListState<T> extends Equatable {
  const PagedListState({
    required this.items,
    required this.hasNext,
    required this.currentPage,
    required this.isLoading,
    required this.isLoadingMore,
    this.failure,
  });

  final List<T> items;
  final bool hasNext;
  final int currentPage;
  final bool isLoading;
  final bool isLoadingMore;
  final Failure? failure;

  bool get isEmpty => items.isEmpty && !isLoading && failure == null;

  factory PagedListState.initial() => const PagedListState(
        items: [],
        hasNext: false,
        currentPage: 0,
        isLoading: true,
        isLoadingMore: false,
      );

  PagedListState<T> copyWith({
    List<T>? items,
    bool? hasNext,
    int? currentPage,
    bool? isLoading,
    bool? isLoadingMore,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return PagedListState(
      items: items ?? this.items,
      hasNext: hasNext ?? this.hasNext,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [items, hasNext, currentPage, isLoading, isLoadingMore, failure];
}

/// `simplePaginate` ro'yxatlari uchun umumiy infinite-scroll kontroller —
/// Partners/Wallets/Installments/Due-dates barchasi shu bir xil naqshdan
/// foydalanadi (MOBILE_APP_TZ.md 4.7-A, E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 143).
abstract class PagedListCubit<T> extends Cubit<PagedListState<T>> {
  PagedListCubit() : super(PagedListState<T>.initial());

  Future<ApiResult<SimplePage<T>>> fetchPage(int page);

  Future<void> loadFirst() async {
    emit(state.copyWith(isLoading: true, clearFailure: true));
    final result = await fetchPage(1);
    result.when(
      success: (page) => emit(PagedListState(
        items: page.items,
        hasNext: page.hasNext,
        currentPage: 1,
        isLoading: false,
        isLoadingMore: false,
      )),
      failure: (f) => emit(state.copyWith(isLoading: false, failure: f)),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasNext || state.isLoadingMore || state.isLoading) return;
    emit(state.copyWith(isLoadingMore: true));
    final nextPage = state.currentPage + 1;
    final result = await fetchPage(nextPage);
    result.when(
      success: (page) => emit(state.copyWith(
        items: [...state.items, ...page.items],
        hasNext: page.hasNext,
        currentPage: nextPage,
        isLoadingMore: false,
      )),
      failure: (f) => emit(state.copyWith(isLoadingMore: false, failure: f)),
    );
  }

  Future<void> refresh() => loadFirst();
}
