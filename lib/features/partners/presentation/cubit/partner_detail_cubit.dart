import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../data/partner_models.dart';
import '../../data/partners_repository.dart';

sealed class PartnerDetailState extends Equatable {
  const PartnerDetailState();
  @override
  List<Object?> get props => [];
}

class PartnerDetailLoading extends PartnerDetailState {
  const PartnerDetailLoading();
}

class PartnerDetailLoaded extends PartnerDetailState {
  const PartnerDetailLoaded(this.partner, this.account);
  final Partner partner;
  final PartnerAccount account;
  @override
  List<Object?> get props => [partner, account];
}

class PartnerDetailError extends PartnerDetailState {
  const PartnerDetailError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

/// Hamkor kartochkasi — yuqori blok (MOBILE_APP_TZ.md 8.5).
class PartnerDetailCubit extends Cubit<PartnerDetailState> {
  PartnerDetailCubit(this._repository, this.partnerId) : super(const PartnerDetailLoading());

  final PartnersRepository _repository;
  final int partnerId;

  Future<void> load() async {
    emit(const PartnerDetailLoading());
    final partnerFuture = _repository.getPartner(partnerId);
    final accountFuture = _repository.getPartnerAccount(partnerId);
    final partnerResult = await partnerFuture;
    final accountResult = await accountFuture;

    partnerResult.when(
      success: (partner) {
        accountResult.when(
          success: (account) => emit(PartnerDetailLoaded(partner, account)),
          failure: (f) => emit(PartnerDetailError(f)),
        );
      },
      failure: (f) => emit(PartnerDetailError(f)),
    );
  }

  Future<void> refresh() => load();
}
