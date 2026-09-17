import 'dart:io';

import '../constants/app_endpoints.dart';
import '../domain/entities/app_file.dart';
import '../network/api_client.dart';
import '../network/api_result.dart';

/// Fayl avval alohida yuklanadi, keyin `id` forma bilan yuboriladi
/// (MOBILE_APP_TZ.md 4.9).
class FileUploadService {
  FileUploadService(this._client);

  final ApiClient _client;

  Future<ApiResult<AppFile>> upload(File file) {
    return _client.uploadFile(
      ApiEndpoints.filesUpload,
      file,
      parse: (r) => AppFile.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<void>> delete(int id) => _client.delete(ApiEndpoints.fileDelete(id), parse: (_) {});
}
