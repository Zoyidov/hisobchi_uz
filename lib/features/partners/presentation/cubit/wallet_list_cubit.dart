import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/events/data_refresh_bus.dart';
import '../../data/partner_models.dart';
import '../../data/wallet_repository.dart';

sealed class WalletListState extends Equatable {
  const WalletListState();
  @override
  List<Object?> get props => [];
}

class WalletListLoading extends WalletListState {
  const WalletListLoading();
}

class WalletListLoaded extends WalletListState {
  const WalletListLoaded(this.wallets);
  final List<Wallet> wallets;
  @override
  List<Object?> get props => [wallets];
}

class WalletListError extends WalletListState {
  const WalletListError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

/// Tranzaksiyalar tabi — paginatsiyasiz, oxirgi 3 oy sukut bo'yicha
/// (MOBILE_APP_TZ.md 8.6).
class WalletListCubit extends Cubit<WalletListState> {
  WalletListCubit(this._repository, this.partnerId) : super(const WalletListLoading()) {
    _refreshSub = getIt<DataRefreshBus>().events.listen((event) {
      if (event is WalletsChangedEvent && (event.partnerId == null || event.partnerId == partnerId)) {
        load();
      }
    });
  }

  final WalletRepository _repository;
  final int partnerId;
  StreamSubscription<DataChangeEvent>? _refreshSub;

  WalletFilterStatus _filter = WalletFilterStatus.all;
  WalletFilterStatus get filter => _filter;

  DateTime? _dateFrom;
  DateTime? _dateTo;

  DateTime? get dateFrom => _dateFrom;
  DateTime? get dateTo => _dateTo;
  bool get hasDateFilter => _dateFrom != null || _dateTo != null;

  void updateFilter(WalletFilterStatus newFilter) {
    if (_filter == newFilter) return;
    _filter = newFilter;
    load();
  }

  void updateDateRange(DateTime? from, DateTime? to) {
    if (_dateFrom == from && _dateTo == to) return;
    _dateFrom = from;
    _dateTo = to;
    load();
  }

  void clearDateFilter() {
    if (_dateFrom == null && _dateTo == null) return;
    _dateFrom = null;
    _dateTo = null;
    load();
  }

  @override
  Future<void> close() {
    _refreshSub?.cancel();
    return super.close();
  }

  Future<void> load() async {
    if (isClosed) return;
    emit(const WalletListLoading());
    final int isCancelled = _filter == WalletFilterStatus.cancelled ? 1 : 0;
    final String? type = switch (_filter) {
      WalletFilterStatus.debt => 'debt',
      WalletFilterStatus.credit => 'credit',
      _ => null,
    };
    final result = await _repository.getWallets(
      partnerId: partnerId,
      isCancelled: isCancelled,
      type: type,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
    );
    if (isClosed) return;
    result.when(
      success: (wallets) => emit(WalletListLoaded(wallets)),
      failure: (f) => emit(WalletListError(f)),
    );
  }

  Future<void> refresh() => load();

  void prependOptimistic(Wallet wallet) {
    if (state is WalletListLoaded) {
      emit(WalletListLoaded([wallet, ...(state as WalletListLoaded).wallets]));
    }
  }
}
