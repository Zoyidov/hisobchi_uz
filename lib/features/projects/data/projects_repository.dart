import 'package:decimal/decimal.dart';

import '../../../core/constants/app_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/paged_result.dart';
import '../../../core/utils/money.dart';
import 'project_models.dart';

class ProjectsRepository {
  ProjectsRepository(this._client);

  final ApiClient _client;

  Future<ApiResult<SimplePage<Project>>> getProjects({
    required int page,
    String? search,
    ProjectStatus? status,
  }) {
    return _client.getSimplePage(
      ApiEndpoints.projects,
      query: {
        'page': page,
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null) 'status': status.apiValue,
      },
      fromJson: Project.fromJson,
    );
  }

  Future<ApiResult<Project>> getProject(int id) =>
      _client.get(ApiEndpoints.projectById(id), parse: (r) => Project.fromJson(r as Map<String, dynamic>));

  Future<ApiResult<Project>> createProject({
    required String projectName,
    required String projectOwner,
    required String phone,
    String? address,
    String? location,
    List<int>? fileIds,
  }) {
    return _client.post(
      ApiEndpoints.project,
      data: {
        'project_name': projectName,
        'project_owner': projectOwner,
        'phone': phone,
        if (address != null) 'address': address,
        if (location != null) 'location': location,
        if (fileIds != null) 'file_id': fileIds,
      },
      parse: (r) => Project.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<Project>> updateProject(
    int id, {
    required String projectName,
    required String projectOwner,
    required String phone,
    String? address,
    String? location,
    List<int>? fileIds,
  }) {
    return _client.put(
      ApiEndpoints.projectById(id),
      data: {
        'project_name': projectName,
        'project_owner': projectOwner,
        'phone': phone,
        if (address != null) 'address': address,
        if (location != null) 'location': location,
        if (fileIds != null) 'file_id': fileIds,
      },
      parse: (r) => Project.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<void>> deleteProject(int id) => _client.delete(ApiEndpoints.projectById(id), parse: (_) {});
  Future<ApiResult<void>> restoreProject(int id) => _client.post(ApiEndpoints.projectRestore(id), parse: (_) {});
  Future<ApiResult<void>> forceDeleteProject(int id) =>
      _client.delete(ApiEndpoints.projectForceDelete(id), parse: (_) {});

  Future<ApiResult<void>> updateStatus(int id, ProjectStatus status) {
    return _client.put(ApiEndpoints.projectUpdateStatus(id), data: {'status': status.apiValue}, parse: (_) {});
  }

  // ---------------- Contracts ----------------

  Future<ApiResult<List<ProjectContract>>> getContracts(int projectId, {String? search}) {
    return _client.getList(
      ApiEndpoints.projectContracts,
      query: {'project_id': projectId, if (search != null && search.isNotEmpty) 'search': search},
      fromJson: ProjectContract.fromJson,
    );
  }

  Future<ApiResult<ProjectContract>> createContract({
    required int projectId,
    required int workTypeId,
    required String description,
    required Decimal summa,
    List<int>? fileIds,
  }) {
    return _client.post(
      ApiEndpoints.projectContract,
      data: {
        'project_id': projectId,
        'work_type_id': workTypeId,
        'description': description,
        'summa': moneyToApi(summa),
        if (fileIds != null) 'file_id': fileIds,
      },
      parse: (r) => ProjectContract.fromJson(r as Map<String, dynamic>),
    );
  }

  // ---------------- Incomes ----------------

  Future<ApiResult<List<ProjectIncome>>> getIncomes(int projectId, {String? search}) {
    return _client.getList(
      ApiEndpoints.projectIncomes,
      query: {'project_id': projectId, if (search != null && search.isNotEmpty) 'search': search},
      fromJson: ProjectIncome.fromJson,
    );
  }

  Future<ApiResult<ProjectIncome>> createIncome({
    required int projectId,
    required int currencyTypeId,
    required Decimal summa,
    String? description,
    List<int>? fileIds,
  }) {
    return _client.post(
      ApiEndpoints.projectIncome,
      data: {
        'project_id': projectId,
        'currency_type_id': currencyTypeId,
        'summa': moneyToApi(summa),
        if (description != null && description.isNotEmpty) 'description': description,
        if (fileIds != null) 'file_id': fileIds,
      },
      parse: (r) => ProjectIncome.fromJson(r as Map<String, dynamic>),
    );
  }

  // ---------------- Costs ----------------

  Future<ApiResult<List<ProjectCost>>> getCosts(int projectId, {String? search, int? costTypeId}) {
    return _client.getList(
      ApiEndpoints.projectCosts,
      query: {
        'project_id': projectId,
        if (search != null && search.isNotEmpty) 'search': search,
        if (costTypeId != null) 'cost_type_id': costTypeId,
      },
      fromJson: ProjectCost.fromJson,
    );
  }

  Future<ApiResult<ProjectCost>> createCost({
    required int projectId,
    required int costTypeId,
    required int currencyTypeId,
    required Decimal summa,
    String? description,
    int? workerId,
    List<int>? fileIds,
  }) {
    return _client.post(
      ApiEndpoints.projectCost,
      data: {
        'project_id': projectId,
        'cost_type_id': costTypeId,
        'currency_type_id': currencyTypeId,
        'summa': moneyToApi(summa),
        if (description != null && description.isNotEmpty) 'description': description,
        if (workerId != null) 'worker_id': workerId,
        if (fileIds != null) 'file_id': fileIds,
      },
      parse: (r) => ProjectCost.fromJson(r as Map<String, dynamic>),
    );
  }

  // ---------------- Workers ----------------

  Future<ApiResult<List<ProjectWorker>>> getProjectWorkers(int projectId) {
    return _client.getList(ApiEndpoints.projectWorkers(projectId), fromJson: ProjectWorker.fromJson);
  }

  Future<ApiResult<void>> addWorkersToProject(int projectId, List<int> workerIds) {
    return _client.post(
      ApiEndpoints.workerAddToProject,
      data: {'worker_ids': workerIds, 'project_id': projectId},
      parse: (_) {},
    );
  }

  Future<ApiResult<void>> removeWorkerFromProject(int projectId, int workerId) {
    return _client.post(
      ApiEndpoints.workerRemoveFromProject,
      data: {
        'worker_ids': [workerId],
        'project_id': projectId,
      },
      parse: (_) {},
    );
  }
}
