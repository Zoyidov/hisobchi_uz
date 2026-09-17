import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/errors/failure.dart';

enum OtpMode { register, resetPassword }

sealed class OtpState extends Equatable {
  const OtpState(this.secondsRemaining);
  final int secondsRemaining;
  @override
  List<Object?> get props => [secondsRemaining];
}

class OtpCountingDown extends OtpState {
  const OtpCountingDown(super.secondsRemaining);
}

class OtpVerifying extends OtpState {
  const OtpVerifying(super.secondsRemaining);
}

/// `payload` — register rejimida `verify_token`, resetPassword rejimida
/// foydalanuvchi kiritgan xom OTP kodi (MOBILE_APP_TZ.md 5.4, 5.7).
class OtpVerified extends OtpState {
  const OtpVerified(this.payload, super.secondsRemaining);
  final String payload;
  @override
  List<Object?> get props => [payload, secondsRemaining];
}

class OtpInvalid extends OtpState {
  const OtpInvalid(this.failure, super.secondsRemaining);
  final Failure failure;
  @override
  List<Object?> get props => [failure, secondsRemaining];
}

/// OTP ekrani — 60 soniyalik countdown, 4 raqam kiritilishi bilan avtomatik
/// tekshirish (MOBILE_APP_TZ.md 5.4).
class OtpCubit extends Cubit<OtpState> {
  OtpCubit(this._authRepository, {required this.phone, required this.mode})
      : super(const OtpCountingDown(AppDurations.otpCountdownSec)) {
    _startTimer();
  }

  final AuthRepository _authRepository;
  final String phone;
  final OtpMode mode;
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();
    var seconds = AppDurations.otpCountdownSec;
    emit(OtpCountingDown(seconds));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds--;
      if (seconds <= 0) {
        timer.cancel();
        emit(const OtpCountingDown(0));
      } else {
        emit(OtpCountingDown(seconds));
      }
    });
  }

  Future<void> resend() async {
    final result = await _authRepository.sendOtp(phone);
    result.when(
      success: (_) => _startTimer(),
      failure: (f) => emit(OtpInvalid(f, state.secondsRemaining)),
    );
  }

  Future<void> submit(String code) async {
    if (mode == OtpMode.resetPassword) {
      emit(OtpVerified(code, state.secondsRemaining));
      return;
    }
    emit(OtpVerifying(state.secondsRemaining));
    final result = await _authRepository.verifyOtp(phone: phone, otpCode: code);
    result.when(
      success: (data) => emit(OtpVerified(data.verifyToken, state.secondsRemaining)),
      failure: (f) => emit(OtpInvalid(f, state.secondsRemaining)),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
