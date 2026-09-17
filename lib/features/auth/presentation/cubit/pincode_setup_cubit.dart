import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/storage/secure_storage_service.dart';

sealed class PincodeSetupState extends Equatable {
  const PincodeSetupState();
  @override
  List<Object?> get props => [];
}

class PincodeSetupInitial extends PincodeSetupState {
  const PincodeSetupInitial();
}

class PincodeSetupSaving extends PincodeSetupState {
  const PincodeSetupSaving();
}

class PincodeSetupSuccess extends PincodeSetupState {
  const PincodeSetupSuccess();
}

/// PIN yaratish — mahalliy saqlash asosiy, serverga sinxronlash ikkinchi
/// darajali (MOBILE_APP_TZ.md 5.8: backend pincode'ni faqat qulf sifatida
/// biladi, autentifikatsiya vositasi emas).
class PincodeSetupCubit extends Cubit<PincodeSetupState> {
  PincodeSetupCubit(this._authRepository, this._secureStorage) : super(const PincodeSetupInitial());

  final AuthRepository _authRepository;
  final SecureStorageService _secureStorage;

  Future<void> save({required int userId, required String pincode}) async {
    emit(const PincodeSetupSaving());
    await _secureStorage.savePincode(pincode);
    await _authRepository.updateAppSettings(userId: userId, pincode: pincode);
    emit(const PincodeSetupSuccess());
  }
}
