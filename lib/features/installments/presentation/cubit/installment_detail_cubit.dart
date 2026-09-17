import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../data/installment_models.dart';
import '../../data/installments_repository.dart';

sealed class InstallmentDetailState extends Equatable {
  const InstallmentDetailState();
  @override
  List<Object?> get props => [];
}

class InstallmentDetailLoading extends InstallmentDetailState {
  const InstallmentDetailLoading();
}

class InstallmentDetailLoaded extends InstallmentDetailState {
  const InstallmentDetailLoaded(this.plan);
  final InstallmentPlan plan;
  @override
  List<Object?> get props => [plan];
}

class InstallmentDetailError extends InstallmentDetailState {
  const InstallmentDetailError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

/// Reja tafsilotlari (MOBILE_APP_TZ.md 9.5).
class InstallmentDetailCubit extends Cubit<InstallmentDetailState> {
  InstallmentDetailCubit(this._repository, this.planId) : super(const InstallmentDetailLoading());

  final InstallmentsRepository _repository;
  final int planId;

  Future<void> load() async {
    emit(const InstallmentDetailLoading());
    final result = await _repository.getInstallment(planId);
    result.when(
      success: (plan) => emit(InstallmentDetailLoaded(plan)),
      failure: (f) => emit(InstallmentDetailError(f)),
    );
  }

  Future<void> refresh() => load();

  Future<Failure?> cancelPlan() async {
    final result = await _repository.cancel(planId);
    return result.when(success: (_) { load(); return null; }, failure: (f) => f);
  }
}
