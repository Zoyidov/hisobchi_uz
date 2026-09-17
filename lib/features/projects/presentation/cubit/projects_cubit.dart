import 'dart:async';

import '../../../../core/di/injector.dart';
import '../../../../core/events/data_refresh_bus.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/paged_result.dart';
import '../../../../core/paging/paged_list_cubit.dart';
import '../../data/project_models.dart';
import '../../data/projects_repository.dart';

/// Loyihalar ro'yxati (MOBILE_APP_TZ.md 10.2).
class ProjectsCubit extends PagedListCubit<Project> {
  ProjectsCubit(this._repository) {
    _refreshSub = getIt<DataRefreshBus>().events.listen((event) {
      if (event is ProjectsChangedEvent) {
        refresh();
      }
    });
  }

  final ProjectsRepository _repository;
  StreamSubscription<DataChangeEvent>? _refreshSub;

  @override
  Future<void> close() {
    _refreshSub?.cancel();
    return super.close();
  }

  String _search = '';
  ProjectStatus? _status;

  String get search => _search;
  ProjectStatus? get status => _status;

  void updateSearch(String value) {
    _search = value;
    loadFirst();
  }

  void updateStatus(ProjectStatus? value) {
    _status = value;
    loadFirst();
  }

  @override
  Future<ApiResult<SimplePage<Project>>> fetchPage(int page) {
    return _repository.getProjects(page: page, search: _search, status: _status);
  }
}
