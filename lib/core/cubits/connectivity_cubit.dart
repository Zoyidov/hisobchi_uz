import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Offline banner va yozish amallarini bloklash uchun (MOBILE_APP_TZ.md 4.11, 71-bo'lim).
class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(this._connectivity) : super(true) {
    _init();
  }

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> _init() async {
    final result = await _connectivity.checkConnectivity();
    emit(!result.contains(ConnectivityResult.none));
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      emit(!result.contains(ConnectivityResult.none));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
