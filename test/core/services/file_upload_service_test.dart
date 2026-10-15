import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/network/api_client.dart';
import 'package:hisobchi_uz/core/services/file_upload_service.dart';

void main() {
  test(
    'uploads multipart file with entity type, filename and progress callback',
    () async {
      final directory = await Directory.systemTemp.createTemp('upload-test-');
      addTearDown(() => directory.delete(recursive: true));
      final file = await File(
        '${directory.path}/photo.jpg',
      ).writeAsBytes([1, 2, 3]);
      final dio = Dio(BaseOptions(contentType: 'application/json'));
      var progress = 0;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/files/upload');
            expect(options.contentType, contains('multipart/form-data'));
            final form = options.data as FormData;
            expect(form.fields.single.key, 'type');
            expect(form.fields.single.value, 'client');
            expect(form.files.single.key, 'file');
            expect(form.files.single.value.filename, 'photo.jpg');
            options.onSendProgress?.call(3, 3);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'status': true,
                  'result': {'id': 42, 'url': 'https://example.com/photo.jpg'},
                },
              ),
            );
          },
        ),
      );
      final result = await FileUploadService(ApiClient(dio)).upload(
        file,
        type: 'client',
        onProgress: (sent, total) => progress = sent,
      );
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.id, 42);
      expect(progress, 3);
    },
  );
}
