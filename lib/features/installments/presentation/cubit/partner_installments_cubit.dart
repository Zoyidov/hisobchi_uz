import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/events/data_refresh_bus.dart';
import '../../data/installment_models.dart';
import '../../data/installments_repository.dart';

sealed class PartnerInstallmentsState extends Equatable {
  const PartnerInstallmentsState();
  @override
  List<Object?> get props => [];
}

class PartnerInstallmentsLoading extends PartnerInstallmentsState {
  const PartnerInstallmentsLoading();
}

class PartnerInstallmentsLoaded extends PartnerInstallmentsState {
  const PartnerInstallmentsLoaded(this.plans);
  final List<InstallmentPlan> plans;
  @override
  List<Object?> get props => [plans];
}

class PartnerInstallmentsError extends PartnerInstallmentsState {
  const PartnerInstallmentsError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

/// Hamkor kartochkasidagi "Bo'lib to'lash" tabi (MOBILE_APP_TZ.md 9.9).
class PartnerInstallmentsCubit extends Cubit<PartnerInstallmentsState> {
  PartnerInstallmentsCubit(this._repository, this.partnerId) : super(const PartnerInstallmentsLoading()) {
    _refreshSub = getIt<DataRefreshBus>().events.listen((event) {
      if (event is InstallmentsChangedEvent || event is WalletsChangedEvent) {
        refresh();
      }
    });
  }

  final InstallmentsRepository _repository;
  final int partnerId;
  StreamSubscription<DataChangeEvent>? _refreshSub;

  @override
  Future<void> close() {
    _refreshSub?.cancel();
    return super.close();
  }

  Future<void> load() async {
    if (isClosed) return;
    emit(const PartnerInstallmentsLoading());
    final result = await _repository.getPartnerInstallments(partnerId);
    if (isClosed) return;
    result.when(
      success: (plans) => emit(PartnerInstallmentsLoaded(plans)),
      failure: (f) => emit(PartnerInstallmentsError(f)),
    );
  }

  Future<void> refresh() => load();
}
