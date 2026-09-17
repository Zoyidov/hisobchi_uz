import 'package:dio/dio.dart';

import '../constants/app_durations.dart';

/// `--dart-define=BASE_URL=...` orqali kompilyatsiya vaqtida beriladi —
/// kodga hardcode qilinmaydi (MOBILE_APP_TZ.md 4.1).
const String _baseUrlFromEnv = String.fromEnvironment(
  'BASE_URL',
  // defaultValue: 'https://api.e-hisob.uz/api',
  defaultValue: 'https://api.pulza.uz/api',
);

class DioClient {
  static Dio create({String? baseUrl, List<Interceptor> interceptors = const []}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? _baseUrlFromEnv,
        connectTimeout: const Duration(seconds: ApiDurations.connectTimeoutSec),
        receiveTimeout: const Duration(seconds: ApiDurations.receiveTimeoutSec),
        sendTimeout: const Duration(seconds: ApiDurations.sendTimeoutSec),
        contentType: 'application/json',
        // Standart validateStatus (200-299) saqlanadi: 401/403/422/5xx kabi
        // statuslar Dio tomonidan xato deb hisoblanib, ErrorInterceptor.onError
        // orqali yagona Failure turiga aylantiriladi.
      ),
    );
    dio.interceptors.addAll(interceptors);
    return dio;
  }
}
