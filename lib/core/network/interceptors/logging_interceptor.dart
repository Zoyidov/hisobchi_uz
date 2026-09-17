import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Faqat debug rejimida log yozadi; parol/token kabi maxfiy maydonlarni
/// yashiradi (MOBILE_APP_TZ.md 76, E_HISOB_FLUTTER_UI_UX_TZ.md 76-bo'lim).
class AppLoggingInterceptor extends Interceptor {
  static const _sensitiveKeys = {'password', 'authorization', 'token', 'pincode'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('➡️  ${options.method} ${options.uri}');
      final body = options.data;
      if (body is Map) debugPrint('   body: ${_sanitize(body)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('✅ ${response.statusCode} ${response.requestOptions.uri}');
      debugPrint('   response (${response.statusCode}): ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '❌ ${err.response?.statusCode ?? err.type} ${err.requestOptions.uri} — ${err.message}',
      );
      if (err.response?.data != null) {
        debugPrint('   error data: ${err.response?.data}');
      }
    }
    handler.next(err);
  }

  Map _sanitize(Map body) {
    return body.map((key, value) {
      final k = key.toString().toLowerCase();
      if (_sensitiveKeys.any(k.contains)) return MapEntry(key, '***');
      return MapEntry(key, value);
    });
  }
}
