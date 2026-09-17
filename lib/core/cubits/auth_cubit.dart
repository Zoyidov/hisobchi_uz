import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/secure_storage_service.dart';

enum AuthStatus { splash, authenticated, unauthenticated }

/// Token mavjudligiga asoslangan global "darvoza" — router shu holatga qarab
/// auth yoki asosiy stack'ni ko'rsatadi (MOBILE_APP_TZ.md 5.1).
class AuthCubit extends Cubit<AuthStatus> {
  AuthCubit(this._secureStorage) : super(AuthStatus.splash);

  final SecureStorageService _secureStorage;

  Future<void> bootstrap() async {
    final token = await _secureStorage.readToken();
    emit(token != null && token.isNotEmpty ? AuthStatus.authenticated : AuthStatus.unauthenticated);
  }

  Future<void> onLoginSuccess(String token) async {
    await _secureStorage.saveToken(token);
    emit(AuthStatus.authenticated);
  }

  Future<void> logout() async {
    await _secureStorage.clearAll();
    emit(AuthStatus.unauthenticated);
  }
}
