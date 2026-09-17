import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../data/project_models.dart';
import '../../data/projects_repository.dart';

sealed class ProjectFormState extends Equatable {
  const ProjectFormState();
  @override
  List<Object?> get props => [];
}

class ProjectFormInitial extends ProjectFormState {
  const ProjectFormInitial();
}

class ProjectFormSubmitting extends ProjectFormState {
  const ProjectFormSubmitting();
}

class ProjectFormSuccess extends ProjectFormState {
  const ProjectFormSuccess(this.project);
  final Project project;
  @override
  List<Object?> get props => [project];
}

class ProjectFormValidationError extends ProjectFormState {
  const ProjectFormValidationError(this.fieldErrors);
  final Map<String, String> fieldErrors;
  @override
  List<Object?> get props => [fieldErrors];
}

class ProjectFormLimitReached extends ProjectFormState {
  const ProjectFormLimitReached(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class ProjectFormFailed extends ProjectFormState {
  const ProjectFormFailed(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

/// Loyiha yaratish/tahrirlash (MOBILE_APP_TZ.md 10.3).
class ProjectFormCubit extends Cubit<ProjectFormState> {
  ProjectFormCubit(this._repository) : super(const ProjectFormInitial());

  final ProjectsRepository _repository;

  Future<void> submit({
    int? id,
    required String projectName,
    required String projectOwner,
    required String phone,
    String? address,
    String? location,
    List<int>? fileIds,
  }) async {
    emit(const ProjectFormSubmitting());
    final result = id == null
        ? await _repository.createProject(
            projectName: projectName,
            projectOwner: projectOwner,
            phone: phone,
            address: address,
            location: location,
            fileIds: fileIds,
          )
        : await _repository.updateProject(
            id,
            projectName: projectName,
            projectOwner: projectOwner,
            phone: phone,
            address: address,
            location: location,
            fileIds: fileIds,
          );

    result.when(
      success: (project) => emit(ProjectFormSuccess(project)),
      failure: (f) {
        if (f is ValidationFailure) {
          emit(ProjectFormValidationError(f.fieldErrors));
        } else if (f is BusinessFailure && f.message.contains('limit')) {
          emit(ProjectFormLimitReached(f.message));
        } else {
          emit(ProjectFormFailed(f));
        }
      },
    );
  }
}
