import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../data/notification_models.dart';
import '../../data/notifications_repository.dart';

class NotificationsState extends Equatable {
  const NotificationsState({
    this.items = const [],
    this.currentPage = 0,
    this.lastPage = 1,
    this.isLoading = true,
    this.isLoadingMore = false,
    this.failure,
  });

  final List<AppNotification> items;
  final int currentPage;
  final int lastPage;
  final bool isLoading;
  final bool isLoadingMore;
  final Failure? failure;

  bool get hasNext => currentPage < lastPage;
  bool get isEmpty => items.isEmpty && !isLoading && failure == null;

  NotificationsState copyWith({
    List<AppNotification>? items,
    int? currentPage,
    int? lastPage,
    bool? isLoading,
    bool? isLoadingMore,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return NotificationsState(
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

/// Bildirishnomalar ro'yxati (MOBILE_APP_TZ.md 14.2).
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository) : super(const NotificationsState());

  final NotificationsRepository _repository;

  Future<void> loadFirst() async {
    emit(state.copyWith(isLoading: true, clearFailure: true));
    final result = await _repository.getNotifications(page: 1);
    result.when(
      success: (page) => emit(NotificationsState(items: page.items, currentPage: page.currentPage, lastPage: page.lastPage, isLoading: false)),
      failure: (f) => emit(state.copyWith(isLoading: false, failure: f)),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasNext || state.isLoadingMore || state.isLoading) return;
    emit(state.copyWith(isLoadingMore: true));
    final nextPage = state.currentPage + 1;
    final result = await _repository.getNotifications(page: nextPage);
    result.when(
      success: (page) => emit(state.copyWith(
        items: [...state.items, ...page.items],
        currentPage: page.currentPage,
        lastPage: page.lastPage,
        isLoadingMore: false,
      )),
      failure: (f) => emit(state.copyWith(isLoadingMore: false, failure: f)),
    );
  }

  Future<void> refresh() => loadFirst();

  Future<void> markAsRead(AppNotification notification) async {
    if (notification.isRead) return;
    await _repository.markAsRead(notification.id);
    loadFirst();
  }
}
