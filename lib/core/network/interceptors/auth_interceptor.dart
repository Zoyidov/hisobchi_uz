import 'package:dio/dio.dart';

import '../../cubits/owner_context_cubit.dart';
import '../../localization/locale_cubit.dart';
import '../../storage/secure_storage_service.dart';

/// Standart headerlar: Accept, Content-Type, Authorization, Accept-Language,
/// X-As-Owner (MOBILE_APP_TZ.md 4.2, 6.3).
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SecureStorageService secureStorage,
    required OwnerContextCubit ownerContextCubit,
    required LocaleCubit localeCubit,
  })  : _secureStorage = secureStorage,
        _ownerContextCubit = ownerContextCubit,
        _localeCubit = localeCubit;

  final SecureStorageService _secureStorage;
  final OwnerContextCubit _ownerContextCubit;
  final LocaleCubit _localeCubit;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['Accept'] = 'application/json';
    options.headers['Accept-Language'] = _localeCubit.state.languageCode;

    final token = await _secureStorage.readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    final ownerContext = _ownerContextCubit.state;
    final isAuthGroup = options.path.startsWith('/auth');
    if (ownerContext.isStaffMode && !isAuthGroup) {
      options.headers['X-As-Owner'] = ownerContext.ownerId.toString();
    }

    handler.next(options);
  }
}
