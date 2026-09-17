import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/errors/failure.dart';

sealed class PhoneState extends Equatable {
  const PhoneState();
  @override
  List<Object?> get props => [];
}

class PhoneInitial extends PhoneState {
  const PhoneInitial();
}

class PhoneLoading extends PhoneState {
  const PhoneLoading();
}

class PhoneNeedsOtp extends PhoneState {
  const PhoneNeedsOtp(this.phone);
  final String phone;
  @override
  List<Object?> get props => [phone];
}

class PhoneNeedsLogin extends PhoneState {
  const PhoneNeedsLogin(this.phone);
  final String phone;
  @override
  List<Object?> get props => [phone];
}

class PhoneError extends PhoneState {
  const PhoneError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

/// Telefon kiritish ekrani oqimi — `verify-number` → register(OTP) | login
/// (MOBILE_APP_TZ.md 5.3).
class PhoneCubit extends Cubit<PhoneState> {
  PhoneCubit(this._authRepository) : super(const PhoneInitial());

  final AuthRepository _authRepository;

  Future<void> submit(String phone) async {
    emit(const PhoneLoading());
    final result = await _authRepository.verifyNumber(phone);
    await result.when(
      success: (data) async {
        if (data.page == 'register') {
          final otpResult = await _authRepository.sendOtp(phone);
          otpResult.when(
            success: (_) => emit(PhoneNeedsOtp(phone)),
            failure: (f) => emit(PhoneError(f)),
          );
        } else {
          emit(PhoneNeedsLogin(phone));
        }
      },
      failure: (f) async => emit(PhoneError(f)),
    );
  }

  void reset() => emit(const PhoneInitial());
}
