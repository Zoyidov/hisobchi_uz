import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/services/device_info_service.dart';

sealed class RegisterState extends Equatable {
  const RegisterState();
  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterSubmitting extends RegisterState {
  const RegisterSubmitting();
}

class RegisterSuccess extends RegisterState {
  const RegisterSuccess(this.token);
  final String token;
  @override
  List<Object?> get props => [token];
}

class RegisterValidationError extends RegisterState {
  const RegisterValidationError(this.fieldErrors);
  final Map<String, String> fieldErrors;
  @override
  List<Object?> get props => [fieldErrors];
}

class RegisterFailed extends RegisterState {
  const RegisterFailed(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

/// Ro'yxatdan o'tish — nom + parol + `verify_token` (MOBILE_APP_TZ.md 5.5).
class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._authRepository, this._deviceInfo) : super(const RegisterInitial());

  final AuthRepository _authRepository;
  final DeviceInfoService _deviceInfo;

  Future<void> submit({
    required String name,
    required String phone,
    required String password,
    required String verifyToken,
  }) async {
    emit(const RegisterSubmitting());
    final deviceToken = await _deviceInfo.deviceToken;
    final result = await _authRepository.register(
      name: name,
      phone: phone,
      password: password,
      verifyToken: verifyToken,
      deviceToken: deviceToken,
      deviceType: _deviceInfo.deviceType,
    );
    result.when(
      success: (data) => emit(RegisterSuccess(data.token)),
      failure: (f) => emit(
        f is ValidationFailure ? RegisterValidationError(f.fieldErrors) : RegisterFailed(f),
      ),
    );
  }
}
