import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_result.dart';
import '../../data/subscription_models.dart';

sealed class PaymentFlowState extends Equatable {
  const PaymentFlowState();
  @override
  List<Object?> get props => [];
}

class PaymentFlowIdle extends PaymentFlowState {
  const PaymentFlowIdle();
}

class PaymentFlowCreatingOrder extends PaymentFlowState {
  const PaymentFlowCreatingOrder();
}

class PaymentFlowPolling extends PaymentFlowState {
  const PaymentFlowPolling(this.orderNumber);
  final String orderNumber;
  @override
  List<Object?> get props => [orderNumber];
}

class PaymentFlowPending extends PaymentFlowState {
  const PaymentFlowPending(this.orderNumber);
  final String orderNumber;
  @override
  List<Object?> get props => [orderNumber];
}

class PaymentFlowSuccess extends PaymentFlowState {
  const PaymentFlowSuccess();
}

class PaymentFlowFailed extends PaymentFlowState {
  const PaymentFlowFailed(this.failure);
  final Failure? failure;
  @override
  List<Object?> get props => [failure];
}

/// To'lov oqimi — obuna va SMS paketi sotib olishda **bir xil**
/// (MOBILE_APP_TZ.md 13.4-13.5): buyurtma yaratish → tashqi brauzer →
/// 5s intervalda polling, maks. 2 daqiqa.
class PaymentFlowCubit extends Cubit<PaymentFlowState> {
  PaymentFlowCubit({
    required Future<ApiResult<PurchaseOrder>> Function() createOrder,
    required Future<ApiResult<OrderStatus>> Function(String orderNumber) checkStatus,
  })  : _createOrder = createOrder,
        _checkStatus = checkStatus,
        super(const PaymentFlowIdle());

  final Future<ApiResult<PurchaseOrder>> Function() _createOrder;
  final Future<ApiResult<OrderStatus>> Function(String orderNumber) _checkStatus;
  Timer? _timer;
  int _elapsedSeconds = 0;

  Future<void> start() async {
    emit(const PaymentFlowCreatingOrder());
    final result = await _createOrder();
    await result.when(
      success: (order) async {
        await launchUrl(Uri.parse(order.paymentUrl), mode: LaunchMode.externalApplication);
        emit(PaymentFlowPolling(order.orderNumber));
        _startPolling(order.orderNumber);
      },
      failure: (f) async => emit(PaymentFlowFailed(f)),
    );
  }

  void _startPolling(String orderNumber) {
    _elapsedSeconds = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) => _poll(orderNumber));
  }

  Future<void> _poll(String orderNumber) async {
    _elapsedSeconds += 5;
    final result = await _checkStatus(orderNumber);
    result.when(
      success: (status) {
        switch (status) {
          case OrderStatus.paid:
            _timer?.cancel();
            emit(const PaymentFlowSuccess());
          case OrderStatus.failed:
            _timer?.cancel();
            emit(const PaymentFlowFailed(null));
          case OrderStatus.pending:
            if (_elapsedSeconds >= 120) {
              _timer?.cancel();
              emit(PaymentFlowPending(orderNumber));
            }
        }
      },
      failure: (_) {},
    );
  }

  Future<void> checkNow(String orderNumber) async {
    emit(PaymentFlowPolling(orderNumber));
    _startPolling(orderNumber);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
