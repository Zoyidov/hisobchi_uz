import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../data/document_models.dart';
import '../../data/documents_repository.dart';

sealed class CostTypeState extends Equatable {
  const CostTypeState();
  @override
  List<Object?> get props => [];
}

class CostTypeLoading extends CostTypeState {
  const CostTypeLoading();
}

class CostTypeLoaded extends CostTypeState {
  const CostTypeLoaded(this.items);
  final List<CostType> items;
  @override
  List<Object?> get props => [items];
}

class CostTypeError extends CostTypeState {
  const CostTypeError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

/// Xarajat turlari — `is_worker_join` bayrog'i bilan (MOBILE_APP_TZ.md 11-bo'lim).
class CostTypeCubit extends Cubit<CostTypeState> {
  CostTypeCubit(this._repository) : super(const CostTypeLoading());

  final DocumentsRepository _repository;

  Future<void> load() async {
    emit(const CostTypeLoading());
    final result = await _repository.getCostTypes();
    result.when(success: (items) => emit(CostTypeLoaded(items)), failure: (f) => emit(CostTypeError(f)));
  }

  Future<Failure?> submitCreate(String name, String? description, bool isWorkerJoin) async {
    final result = await _repository.createCostType(name: name, description: description, isWorkerJoin: isWorkerJoin);
    return result.when(success: (_) { load(); return null; }, failure: (f) => f);
  }

  Future<Failure?> submitUpdate(int id, String name, String? description, bool isWorkerJoin) async {
    final result = await _repository.updateCostType(id, name: name, description: description, isWorkerJoin: isWorkerJoin);
    return result.when(success: (_) { load(); return null; }, failure: (f) => f);
  }

  Future<Failure?> submitDelete(int id) async {
    final result = await _repository.deleteCostType(id);
    return result.when(success: (_) { load(); return null; }, failure: (f) => f);
  }

  Future<Failure?> submitRestore(int id) async {
    final result = await _repository.restoreCostType(id);
    return result.when(success: (_) { load(); return null; }, failure: (f) => f);
  }
}
