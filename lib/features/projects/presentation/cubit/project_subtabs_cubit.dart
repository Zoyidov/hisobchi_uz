import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/paging/paged_list_cubit.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/paged_result.dart';
import '../../data/project_models.dart';
import '../../data/projects_repository.dart';

sealed class ListState<T> extends Equatable {
  const ListState();
  @override
  List<Object?> get props => [];
}

class ListLoading<T> extends ListState<T> {
  const ListLoading();
}

class ListLoaded<T> extends ListState<T> {
  const ListLoaded(this.items);
  final List<T> items;
  @override
  List<Object?> get props => [items];
}

class ListError<T> extends ListState<T> {
  const ListError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

/// Shartnomalar tabi (MOBILE_APP_TZ.md 10.4-A).
class ProjectContractsCubit extends Cubit<ListState<ProjectContract>> {
  ProjectContractsCubit(this._repository, this.projectId)
    : super(const ListLoading());
  final ProjectsRepository _repository;
  final int projectId;

  Future<void> load() async {
    emit(const ListLoading());
    final result = await _repository.getContracts(projectId);
    if (isClosed) return;
    result.when(
      success: (items) => emit(ListLoaded(items)),
      failure: (f) => emit(ListError(f)),
    );
  }
}

/// Daromadlar tabi (MOBILE_APP_TZ.md 10.4-B).
class ProjectIncomesCubit extends PagedListCubit<ProjectIncome> {
  ProjectIncomesCubit(this._repository, this.projectId);
  final ProjectsRepository _repository;
  final int projectId;

  Future<void> load() => loadFirst();

  @override
  Future<ApiResult<SimplePage<ProjectIncome>>> fetchPage(int page) =>
      _repository.getIncomes(projectId, page: page);
}

/// Xarajatlar tabi (MOBILE_APP_TZ.md 10.4-C).
class ProjectCostsCubit extends PagedListCubit<ProjectCost> {
  ProjectCostsCubit(this._repository, this.projectId);
  final ProjectsRepository _repository;
  final int projectId;

  Future<void> load() => loadFirst();

  @override
  Future<ApiResult<SimplePage<ProjectCost>>> fetchPage(int page) =>
      _repository.getCosts(projectId, page: page);
}

/// Ishchilar tabi (MOBILE_APP_TZ.md 10.4-D).
class ProjectWorkersCubit extends Cubit<ListState<ProjectWorker>> {
  ProjectWorkersCubit(this._repository, this.projectId)
    : super(const ListLoading());
  final ProjectsRepository _repository;
  final int projectId;

  Future<void> load() async {
    emit(const ListLoading());
    final result = await _repository.getProjectWorkers(projectId);
    if (isClosed) return;
    result.when(
      success: (items) => emit(ListLoaded(items)),
      failure: (f) => emit(ListError(f)),
    );
  }

  Future<Failure?> addWorkers(List<int> workerIds) async {
    final result = await _repository.addWorkersToProject(projectId, workerIds);
    if (isClosed) return null;
    return result.when(
      success: (_) {
        load();
        return null;
      },
      failure: (f) => f,
    );
  }

  Future<Failure?> removeWorker(int workerId) async {
    final result = await _repository.removeWorkerFromProject(
      projectId,
      workerId,
    );
    if (isClosed) return null;
    return result.when(
      success: (_) {
        load();
        return null;
      },
      failure: (f) => f,
    );
  }
}
