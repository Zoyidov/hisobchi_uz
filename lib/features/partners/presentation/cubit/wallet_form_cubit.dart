import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/events/data_refresh_bus.dart';
import '../../data/partner_models.dart';
import '../../data/wallet_repository.dart';

sealed class WalletFormState extends Equatable {
  const WalletFormState();
  @override
  List<Object?> get props => [];
}

class WalletFormInitial extends WalletFormState {
  const WalletFormInitial();
}

class WalletFormSubmitting extends WalletFormState {
  const WalletFormSubmitting();
}

class WalletFormSuccess extends WalletFormState {
  const WalletFormSuccess(this.wallet);
  final Wallet wallet;
  @override
  List<Object?> get props => [wallet];
}

class WalletFormValidationError extends WalletFormState {
  const WalletFormValidationError(this.fieldErrors);
  final Map<String, String> fieldErrors;
  @override
  List<Object?> get props => [fieldErrors];
}

class WalletFormFailed extends WalletFormState {
  const WalletFormFailed(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

/// Kirim/Chiqim yaratish — ilovadagi eng muhim forma (MOBILE_APP_TZ.md 8.7).
class WalletFormCubit extends Cubit<WalletFormState> {
  WalletFormCubit(this._repository) : super(const WalletFormInitial());

  final WalletRepository _repository;

  Future<void> submit({
    int? editingWalletId,
    required int partnerId,
    required int currencyTypeId,
    required Decimal summa,
    required String type,
    String? description,
    DateTime? returnDate,
    List<int>? fileIds,
  }) async {
    emit(const WalletFormSubmitting());
    final result = editingWalletId == null
        ? await _repository.createWallet(
            partnerId: partnerId,
            currencyTypeId: currencyTypeId,
            summa: summa,
            type: type,
            description: description,
            returnDate: type == 'credit' ? returnDate : null,
            fileIds: fileIds,
          )
        : await _repository.updateWallet(
            id: editingWalletId,
            partnerId: partnerId,
            currencyTypeId: currencyTypeId,
            summa: summa,
            type: type,
            description: description,
            returnDate: type == 'credit' ? returnDate : null,
            fileIds: fileIds,
          );
    result.when(
      success: (wallet) {
        getIt<DataRefreshBus>().notifyWalletsChanged(partnerId: wallet.partnerId, walletId: wallet.id);
        emit(WalletFormSuccess(wallet));
      },
      failure: (f) => emit(
        f is ValidationFailure ? WalletFormValidationError(f.fieldErrors) : WalletFormFailed(f),
      ),
    );
  }
}
