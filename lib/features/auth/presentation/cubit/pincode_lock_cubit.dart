import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/storage/secure_storage_service.dart';

sealed class PincodeLockState extends Equatable {
  const PincodeLockState();
  @override
  List<Object?> get props => [];
}

class PincodeLockInitial extends PincodeLockState {
  const PincodeLockInitial();
}

class PincodeLockUnlocked extends PincodeLockState {
  const PincodeLockUnlocked();
}

class PincodeLockWrong extends PincodeLockState {
  const PincodeLockWrong(this.remainingAttempts);
  final int remainingAttempts;
  @override
  List<Object?> get props => [remainingAttempts];
}

class PincodeLockExhausted extends PincodeLockState {
  const PincodeLockExhausted();
}

/// Offline PIN tekshiruvi — 5 xato urinishdan keyin parol bilan kirishga
/// majburiy o'tkaziladi (MOBILE_APP_TZ.md 5.8).
class PincodeLockCubit extends Cubit<PincodeLockState> {
  PincodeLockCubit(this._secureStorage) : super(const PincodeLockInitial());

  final SecureStorageService _secureStorage;
  final LocalAuthentication _localAuth = LocalAuthentication();
  int _attempts = 0;

  Future<void> verify(String entered) async {
    final saved = await _secureStorage.readPincode();
    if (saved != null && saved == entered) {
      emit(const PincodeLockUnlocked());
      return;
    }
    _attempts++;
    final remaining = AppDurations.pincodeMaxAttempts - _attempts;
    if (remaining <= 0) {
      emit(const PincodeLockExhausted());
      return;
    }
    emit(PincodeLockWrong(remaining));
  }

  Future<bool> tryBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      if (!canCheck) return false;
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Ilovaga kirish uchun tasdiqlang',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
      if (authenticated) emit(const PincodeLockUnlocked());
      return authenticated;
    } catch (_) {
      return false;
    }
  }
}
