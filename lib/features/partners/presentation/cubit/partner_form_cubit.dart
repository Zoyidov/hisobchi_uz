import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../data/partner_models.dart';
import '../../data/partners_repository.dart';

sealed class PartnerFormState extends Equatable {
  const PartnerFormState();
  @override
  List<Object?> get props => [];
}

class PartnerFormInitial extends PartnerFormState {
  const PartnerFormInitial();
}

class PartnerFormSubmitting extends PartnerFormState {
  const PartnerFormSubmitting();
}

class PartnerFormSuccess extends PartnerFormState {
  const PartnerFormSuccess(this.partner);
  final Partner partner;
  @override
  List<Object?> get props => [partner];
}

class PartnerFormValidationError extends PartnerFormState {
  const PartnerFormValidationError(this.fieldErrors);
  final Map<String, String> fieldErrors;
  @override
  List<Object?> get props => [fieldErrors];
}

class PartnerFormLimitReached extends PartnerFormState {
  const PartnerFormLimitReached(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class PartnerFormFailed extends PartnerFormState {
  const PartnerFormFailed(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

/// Hamkor yaratish/tahrirlash (MOBILE_APP_TZ.md 8.3).
class PartnerFormCubit extends Cubit<PartnerFormState> {
  PartnerFormCubit(this._repository) : super(const PartnerFormInitial());

  final PartnersRepository _repository;

  Future<void> submit({
    int? id,
    required String name,
    required String phone,
    String? additionalPhone,
    required int currencyTypeId,
    List<int>? fileIds,
  }) async {
    emit(const PartnerFormSubmitting());
    final result = id == null
        ? await _repository.createPartner(
            name: name,
            phone: phone,
            additionalPhone: additionalPhone,
            currencyTypeId: currencyTypeId,
            fileIds: fileIds,
          )
        : await _repository.updatePartner(
            id: id,
            name: name,
            phone: phone,
            additionalPhone: additionalPhone,
            currencyTypeId: currencyTypeId,
            fileIds: fileIds,
          );

    result.when(
      success: (partner) => emit(PartnerFormSuccess(partner)),
      failure: (f) {
        if (f is ValidationFailure) {
          emit(PartnerFormValidationError(f.fieldErrors));
        } else if (f is BusinessFailure && f.message.contains('limit')) {
          emit(PartnerFormLimitReached(f.message));
        } else {
          emit(PartnerFormFailed(f));
        }
      },
    );
  }
}
