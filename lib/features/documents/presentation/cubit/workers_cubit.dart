import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../data/document_models.dart';
import '../../data/documents_repository.dart';

sealed class WorkersState extends Equatable {
  const WorkersState();
  @override
  List<Object?> get props => [];
}

class WorkersLoading extends WorkersState {
  const WorkersLoading();
}

class WorkersLoaded extends WorkersState {
  const WorkersLoaded(this.items, this.positions);
  final List<Worker> items;
  final List<SimpleDocument> positions;
  @override
  List<Object?> get props => [items, positions];
}

class WorkersError extends WorkersState {
  const WorkersError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

/// Ishchilar ro'yxati (MOBILE_APP_TZ.md 11-bo'lim).
class WorkersCubit extends Cubit<WorkersState> {
  WorkersCubit(this._repository) : super(const WorkersLoading());

  final DocumentsRepository _repository;

  Future<void> load() async {
    emit(const WorkersLoading());
    final workersResult = await _repository.getWorkers();
    final positionsResult = await _repository.getPositions();
    workersResult.when(
      success: (workers) => emit(WorkersLoaded(workers, positionsResult.dataOrNull ?? [])),
      failure: (f) => emit(WorkersError(f)),
    );
  }

  Future<Failure?> submitCreate({
    required String name,
    required String phone,
    String? additionalPhone,
    int? positionId,
    String? description,
  }) async {
    final result = await _repository.createWorker(
      name: name,
      phone: phone,
      additionalPhone: additionalPhone,
      positionId: positionId,
      description: description,
    );
    return result.when(success: (_) { load(); return null; }, failure: (f) => f);
  }

  Future<Failure?> submitUpdate(
    int id, {
    required String name,
    required String phone,
    String? additionalPhone,
    int? positionId,
    String? description,
  }) async {
    final result = await _repository.updateWorker(
      id,
      name: name,
      phone: phone,
      additionalPhone: additionalPhone,
      positionId: positionId,
      description: description,
    );
    return result.when(success: (_) { load(); return null; }, failure: (f) => f);
  }

  Future<Failure?> submitDelete(int id) async {
    final result = await _repository.deleteWorker(id);
    return result.when(success: (_) { load(); return null; }, failure: (f) => f);
  }

  Future<Failure?> submitRestore(int id) async {
    final result = await _repository.restoreWorker(id);
    return result.when(success: (_) { load(); return null; }, failure: (f) => f);
  }
}
