import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/services/device_info_service.dart';

sealed class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginSubmitting extends LoginState {
  const LoginSubmitting();
}

class LoginSuccess extends LoginState {
  const LoginSuccess(this.token);
  final String token;
  @override
  List<Object?> get props => [token];
}

class LoginFailed extends LoginState {
  const LoginFailed(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

/// Parol bilan kirish — bitta faol sessiya qoidasi bilan
/// (MOBILE_APP_TZ.md 5.6: eski tokenlar avtomatik o'chadi).
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authRepository, this._deviceInfo) : super(const LoginInitial());

  final AuthRepository _authRepository;
  final DeviceInfoService _deviceInfo;

  Future<void> submit({required String phone, required String password}) async {
    emit(const LoginSubmitting());
    final deviceToken = await _deviceInfo.deviceToken;
    final result = await _authRepository.login(
      phone: phone,
      password: password,
      deviceToken: deviceToken,
      deviceType: _deviceInfo.deviceType,
    );
    result.when(
      success: (data) => emit(LoginSuccess(data.token)),
      failure: (f) => emit(LoginFailed(f)),
    );
  }
}
