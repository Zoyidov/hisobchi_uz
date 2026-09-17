import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injector.dart';
import '../../../core/errors/failure.dart';
import '../../../core/events/data_refresh_bus.dart';
import '../data/dashboard_models.dart';
import '../data/dashboard_repository.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  const DashboardLoaded(this.summary, this.tutorials);
  final DashboardSummary summary;
  final List<TutorialItem> tutorials;
  @override
  List<Object?> get props => [summary, tutorials];
}

class DashboardError extends DashboardState {
  const DashboardError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

/// Bosh sahifa — MOBILE_APP_TZ.md 7-bo'lim.
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository) : super(const DashboardLoading()) {
    _refreshSub = getIt<DataRefreshBus>().events.listen((event) {
      if (event is PartnersChangedEvent ||
          event is WalletsChangedEvent ||
          event is ProjectsChangedEvent ||
          event is InstallmentsChangedEvent) {
        refresh();
      }
    });
  }

  final DashboardRepository _repository;
  StreamSubscription<DataChangeEvent>? _refreshSub;

  @override
  Future<void> close() {
    _refreshSub?.cancel();
    return super.close();
  }

  Future<void> load() async {
    emit(const DashboardLoading());
    final summaryResult = await _repository.getSummary();
    await summaryResult.when(
      success: (summary) async {
        final tutorialsResult = await _repository.getTutorials();
        emit(DashboardLoaded(summary, tutorialsResult.dataOrNull ?? const []));
      },
      failure: (f) async => emit(DashboardError(f)),
    );
  }

  Future<void> refresh() => load();
}
