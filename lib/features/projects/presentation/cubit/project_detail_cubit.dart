import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../data/project_models.dart';
import '../../data/projects_repository.dart';

sealed class ProjectDetailState extends Equatable {
  const ProjectDetailState();
  @override
  List<Object?> get props => [];
}

class ProjectDetailLoading extends ProjectDetailState {
  const ProjectDetailLoading();
}

class ProjectDetailLoaded extends ProjectDetailState {
  const ProjectDetailLoaded(this.project);
  final Project project;
  @override
  List<Object?> get props => [project];
}

class ProjectDetailError extends ProjectDetailState {
  const ProjectDetailError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

/// Loyiha kartochkasi (MOBILE_APP_TZ.md 10.4).
class ProjectDetailCubit extends Cubit<ProjectDetailState> {
  ProjectDetailCubit(this._repository, this.projectId) : super(const ProjectDetailLoading());

  final ProjectsRepository _repository;
  final int projectId;

  Future<void> load() async {
    emit(const ProjectDetailLoading());
    final result = await _repository.getProject(projectId);
    result.when(success: (p) => emit(ProjectDetailLoaded(p)), failure: (f) => emit(ProjectDetailError(f)));
  }

  Future<void> refresh() => load();

  Future<Failure?> updateStatus(ProjectStatus status) async {
    final result = await _repository.updateStatus(projectId, status);
    return result.when(success: (_) { load(); return null; }, failure: (f) => f);
  }
}
