import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../data/activity_log_models.dart';
import '../../data/activity_log_repository.dart';

class ActivityLogState extends Equatable {
  const ActivityLogState({
    this.items = const [],
    this.currentPage = 0,
    this.lastPage = 1,
    this.isLoading = true,
    this.isLoadingMore = false,
    this.failure,
  });

  final List<ActivityLogEntry> items;
  final int currentPage;
  final int lastPage;
  final bool isLoading;
  final bool isLoadingMore;
  final Failure? failure;

  bool get hasNext => currentPage < lastPage;
  bool get isEmpty => items.isEmpty && !isLoading && failure == null;

  ActivityLogState copyWith({
    List<ActivityLogEntry>? items,
    int? currentPage,
    int? lastPage,
    bool? isLoading,
    bool? isLoadingMore,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return ActivityLogState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [items, currentPage, lastPage, isLoading, isLoadingMore, failure];
}

/// Faollik jurnali — maxsus `pagination` formati (MOBILE_APP_TZ.md 4.7-B, 16-bo'lim).
class ActivityLogCubit extends Cubit<ActivityLogState> {
  ActivityLogCubit(this._repository) : super(const ActivityLogState());

  final ActivityLogRepository _repository;

  ActivityAction? _action;
  String? _modelType;

  ActivityAction? get actionFilter => _action;
  String? get modelTypeFilter => _modelType;

  void updateFilters({ActivityAction? action, String? modelType}) {
    _action = action;
    _modelType = modelType;
    loadFirst();
  }

  Future<void> loadFirst() async {
    emit(state.copyWith(isLoading: true, clearFailure: true));
    final result = await _repository.getActivityLog(page: 1, action: _action, modelType: _modelType);
    result.when(
      success: (page) => emit(ActivityLogState(items: page.items, currentPage: 1, lastPage: page.lastPage, isLoading: false)),
      failure: (f) => emit(state.copyWith(isLoading: false, failure: f)),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasNext || state.isLoadingMore || state.isLoading) return;
    emit(state.copyWith(isLoadingMore: true));
    final nextPage = state.currentPage + 1;
    final result = await _repository.getActivityLog(page: nextPage, action: _action, modelType: _modelType);
    result.when(
      success: (page) => emit(state.copyWith(
        items: [...state.items, ...page.items],
        currentPage: nextPage,
        lastPage: page.lastPage,
        isLoadingMore: false,
      )),
      failure: (f) => emit(state.copyWith(isLoadingMore: false, failure: f)),
    );
  }

  Future<void> refresh() => loadFirst();
}
