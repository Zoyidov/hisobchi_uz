import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/errors/failure.dart';

sealed class ResetPasswordState extends Equatable {
  const ResetPasswordState();
  @override
  List<Object?> get props => [];
}

class ResetPasswordInitial extends ResetPasswordState {
  const ResetPasswordInitial();
}

class ResetPasswordSubmitting extends ResetPasswordState {
  const ResetPasswordSubmitting();
}

class ResetPasswordSuccess extends ResetPasswordState {
  const ResetPasswordSuccess(this.token);
  final String token;
  @override
  List<Object?> get props => [token];
}

class ResetPasswordFailed extends ResetPasswordState {
  const ResetPasswordFailed(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

/// Parolni tiklash — javobda token keladi, qayta login talab qilinmaydi
/// (MOBILE_APP_TZ.md 5.7).
class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit(this._authRepository) : super(const ResetPasswordInitial());

  final AuthRepository _authRepository;

  Future<void> submit({
    required String phone,
    required String otpCode,
    required String password,
  }) async {
    emit(const ResetPasswordSubmitting());
    final result = await _authRepository.resetPassword(
      phone: phone,
      otpCode: otpCode,
      password: password,
    );
    result.when(
      success: (data) => emit(ResetPasswordSuccess(data.token)),
      failure: (f) => emit(ResetPasswordFailed(f)),
    );
  }
}
