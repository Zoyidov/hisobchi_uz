import 'dart:convert';

import '../../../core/constants/app_endpoints.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/storage/local_cache_service.dart';
import 'currency.dart';
import 'document_models.dart';

/// Ma'lumotnomalar — ilova ochilganda 1 marta yangilanadi va lokal saqlanadi
/// (MOBILE_APP_TZ.md 4.11, 11-bo'lim).
class DocumentsRepository {
  DocumentsRepository(this._client, this._cache);

  final ApiClient _client;
  final LocalCacheService _cache;

  // ---------------- Currencies (cached) ----------------

  List<Currency> get cachedCurrencies {
    final raw = _cache.getJsonList(StorageKeys.cachedCurrencies);
    if (raw == null || raw.isEmpty) return Currency.defaults;
    return raw.cast<Map<String, dynamic>>().map(Currency.fromJson).toList();
  }

  Future<List<Currency>> refreshCurrencies() async {
    final result = await _client.getList(ApiEndpoints.currencies, fromJson: Currency.fromJson);
    return result.when(
      success: (list) {
        _cache.setString(
          StorageKeys.cachedCurrencies,
          jsonEncode(list.map((c) => {'id': c.id, 'name': c.name}).toList()),
        );
        return list;
      },
      failure: (_) => cachedCurrencies,
    );
  }

  // ---------------- Work types ----------------

  Future<ApiResult<List<SimpleDocument>>> getWorkTypes() =>
      _client.getList(ApiEndpoints.workTypes, fromJson: SimpleDocument.fromJson);

  Future<ApiResult<SimpleDocument>> createWorkType({required String name, String? description}) =>
      _client.post(ApiEndpoints.workType, data: {'name': name, 'description': description}, parse: (r) => SimpleDocument.fromJson(r as Map<String, dynamic>));

  Future<ApiResult<SimpleDocument>> updateWorkType(int id, {required String name, String? description}) =>
      _client.put(ApiEndpoints.workTypeById(id), data: {'name': name, 'description': description}, parse: (r) => SimpleDocument.fromJson(r as Map<String, dynamic>));

  Future<ApiResult<void>> deleteWorkType(int id) => _client.delete(ApiEndpoints.workTypeById(id), parse: (_) {});
  Future<ApiResult<void>> restoreWorkType(int id) => _client.post(ApiEndpoints.workTypeRestore(id), parse: (_) {});
  Future<ApiResult<void>> forceDeleteWorkType(int id) => _client.delete(ApiEndpoints.workTypeForceDelete(id), parse: (_) {});

  // ---------------- Cost types ----------------

  Future<ApiResult<List<CostType>>> getCostTypes() =>
      _client.getList(ApiEndpoints.costTypes, fromJson: CostType.fromJson);

  Future<ApiResult<CostType>> createCostType({
    required String name,
    String? description,
    required bool isWorkerJoin,
  }) =>
      _client.post(
        ApiEndpoints.costType,
        data: {'name': name, 'description': description, 'is_worker_join': isWorkerJoin},
        parse: (r) => CostType.fromJson(r as Map<String, dynamic>),
      );

  Future<ApiResult<CostType>> updateCostType(
    int id, {
    required String name,
    String? description,
    required bool isWorkerJoin,
  }) =>
      _client.put(
        ApiEndpoints.costTypeById(id),
        data: {'name': name, 'description': description, 'is_worker_join': isWorkerJoin},
        parse: (r) => CostType.fromJson(r as Map<String, dynamic>),
      );

  Future<ApiResult<void>> deleteCostType(int id) => _client.delete(ApiEndpoints.costTypeById(id), parse: (_) {});
  Future<ApiResult<void>> restoreCostType(int id) => _client.post(ApiEndpoints.costTypeRestore(id), parse: (_) {});
  Future<ApiResult<void>> forceDeleteCostType(int id) => _client.delete(ApiEndpoints.costTypeForceDelete(id), parse: (_) {});

  // ---------------- Positions (lavozimlar) ----------------

  Future<ApiResult<List<SimpleDocument>>> getPositions() =>
      _client.getList(ApiEndpoints.positions, fromJson: SimpleDocument.fromJson);

  Future<ApiResult<SimpleDocument>> createPosition({required String name, String? description}) =>
      _client.post(ApiEndpoints.position, data: {'name': name, 'description': description}, parse: (r) => SimpleDocument.fromJson(r as Map<String, dynamic>));

  Future<ApiResult<SimpleDocument>> updatePosition(int id, {required String name, String? description}) =>
      _client.put(ApiEndpoints.positionById(id), data: {'name': name, 'description': description}, parse: (r) => SimpleDocument.fromJson(r as Map<String, dynamic>));

  Future<ApiResult<void>> deletePosition(int id) => _client.delete(ApiEndpoints.positionById(id), parse: (_) {});
  Future<ApiResult<void>> restorePosition(int id) => _client.post(ApiEndpoints.positionRestore(id), parse: (_) {});
  Future<ApiResult<void>> forceDeletePosition(int id) => _client.delete(ApiEndpoints.positionForceDelete(id), parse: (_) {});

  // ---------------- Workers (ishchilar) ----------------

  Future<ApiResult<List<Worker>>> getWorkers({int? notInProjectId}) => _client.getList(
        ApiEndpoints.workers,
        query: notInProjectId != null ? {'worker_not_in_project_id': notInProjectId} : null,
        fromJson: Worker.fromJson,
      );

  Future<ApiResult<Worker>> createWorker({
    required String name,
    required String phone,
    String? additionalPhone,
    int? positionId,
    String? description,
    List<int>? fileIds,
  }) =>
      _client.post(
        ApiEndpoints.worker,
        data: {
          'name': name,
          'phone': phone,
          if (additionalPhone != null && additionalPhone.isNotEmpty) 'additional_phone': additionalPhone,
          if (positionId != null) 'worker_position_id': positionId,
          if (description != null) 'description': description,
          if (fileIds != null) 'file_id': fileIds,
        },
        parse: (r) => Worker.fromJson(r as Map<String, dynamic>),
      );

  Future<ApiResult<Worker>> updateWorker(
    int id, {
    required String name,
    required String phone,
    String? additionalPhone,
    int? positionId,
    String? description,
    List<int>? fileIds,
  }) =>
      _client.put(
        ApiEndpoints.workerById(id),
        data: {
          'name': name,
          'phone': phone,
          if (additionalPhone != null && additionalPhone.isNotEmpty) 'additional_phone': additionalPhone,
          if (positionId != null) 'worker_position_id': positionId,
          if (description != null) 'description': description,
          if (fileIds != null) 'file_id': fileIds,
        },
        parse: (r) => Worker.fromJson(r as Map<String, dynamic>),
      );

  Future<ApiResult<void>> deleteWorker(int id) => _client.delete(ApiEndpoints.workerById(id), parse: (_) {});
  Future<ApiResult<void>> restoreWorker(int id) => _client.post(ApiEndpoints.workerRestore(id), parse: (_) {});
  Future<ApiResult<void>> forceDeleteWorker(int id) => _client.delete(ApiEndpoints.workerForceDelete(id), parse: (_) {});

  // ---------------- Currency exchange rates ----------------

  Future<ApiResult<List<CurrencyExchangeRate>>> getCurrencyExchangeRates() =>
      _client.getList(ApiEndpoints.currencyExchangeRates, fromJson: CurrencyExchangeRate.fromJson);
}
