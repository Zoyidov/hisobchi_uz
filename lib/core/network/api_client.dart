import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../errors/failure.dart';
import 'api_result.dart';
import 'paged_result.dart';

typedef JsonMap = Map<String, dynamic>;

/// Barcha repositorylar shu orqali murojaat qiladi — feature qatlami hech
/// qachon `Dio`ni to'g'ridan-to'g'ri chaqirmaydi (E_HISOB_FLUTTER_UI_UX_TZ.md
/// 81-bo'lim: "UI to'g'ridan-to'g'ri Dio chaqirmaydi").
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Dio get raw => _dio;

  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(dynamic result) parse,
  }) => _guard(() async {
        final res = await _dio.get(path, queryParameters: _clean(query));
        return parse(_unwrap(res));
      });

  Future<ApiResult<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    required T Function(dynamic result) parse,
  }) => _guard(() async {
        final res = await _dio.post(path, data: data, queryParameters: _clean(query));
        return parse(_unwrap(res));
      });

  Future<ApiResult<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    required T Function(dynamic result) parse,
  }) => _guard(() async {
        final res = await _dio.put(path, data: data, queryParameters: _clean(query));
        return parse(_unwrap(res));
      });

  Future<ApiResult<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    required T Function(dynamic result) parse,
  }) => _guard(() async {
        final res = await _dio.delete(path, data: data, queryParameters: _clean(query));
        return parse(_unwrap(res));
      });

  /// `simplePaginate` javobi (MOBILE_APP_TZ.md 4.7-A).
  Future<ApiResult<SimplePage<T>>> getSimplePage<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(JsonMap json) fromJson,
  }) => get<SimplePage<T>>(
        path,
        query: query,
        parse: (result) => SimplePage.fromJson(result as JsonMap, fromJson),
      );

  /// Standart `paginate` javobi — Activity Log (MOBILE_APP_TZ.md 4.7-B).
  Future<ApiResult<StandardPage<T>>> getStandardPage<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(JsonMap json) fromJson,
  }) => get<StandardPage<T>>(
        path,
        query: query,
        parse: (result) => StandardPage.fromJson(result as JsonMap, fromJson),
      );

  /// Paginatsiyasiz massiv (MOBILE_APP_TZ.md 4.7-C).
  Future<ApiResult<List<T>>> getList<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(JsonMap json) fromJson,
  }) => get<List<T>>(
        path,
        query: query,
        parse: (result) => (result as List).cast<JsonMap>().map(fromJson).toList(),
      );

  /// Fayl yuklash — avval alohida yuklanadi (MOBILE_APP_TZ.md 4.9).
  Future<ApiResult<T>> uploadFile<T>(
    String path,
    File file, {
    required T Function(dynamic result) parse,
  }) => _guard(() async {
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(file.path),
        });
        final res = await _dio.post(path, data: formData);
        return parse(_unwrap(res));
      });

  /// Excel eksport — binar `.xlsx` javob (MOBILE_APP_TZ.md 4.10).
  Future<ApiResult<List<int>>> downloadBytes(
    String path, {
    Map<String, dynamic>? query,
  }) => _guard(() async {
        final res = await _dio.get<List<int>>(
          path,
          queryParameters: _clean(query),
          options: Options(
            responseType: ResponseType.bytes,
            receiveTimeout: const Duration(seconds: 120),
          ),
        );
        return res.data ?? const [];
      });

  Map<String, dynamic>? _clean(Map<String, dynamic>? query) {
    if (query == null) return null;
    final cleaned = <String, dynamic>{};
    query.forEach((key, value) {
      if (value != null) cleaned[key] = value;
    });
    return cleaned;
  }

  dynamic _unwrap(Response response) {
    final data = response.data;
    if (data is Map) {
      if (data.containsKey('result') && data['result'] != null) {
        return data['result'];
      }
      if (data.containsKey('data') && data['data'] != null && data['status'] == true) {
        return data['data'];
      }
    }
    return data;
  }

  Future<ApiResult<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return ApiResult.success(await action());
    } on DioException catch (e) {
      final failure = e.error is Failure ? e.error as Failure : const UnknownFailure();
      return ApiResult.failure(failure);
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('💥 ApiClient parse error: $e\n$stack');
      }
      return ApiResult.failure(UnknownFailure('Xatolik: $e'));
    }
  }
}
