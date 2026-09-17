import 'package:dio/dio.dart';

import '../../cubits/owner_context_cubit.dart';
import '../../cubits/subscription_cubit.dart';
import '../../errors/failure.dart';
import '../auth_session_controller.dart';

/// Markazlashgan Error-Interceptor algoritmi (MOBILE_APP_TZ.md 4.3–4.6):
/// backendning 5 xil javob formatini yagona [Failure] turiga aylantiradi va
/// `X-Subscription-Status` headerini kuzatadi.
class ErrorInterceptor extends Interceptor {
  ErrorInterceptor({
    required AuthSessionController authSession,
    required SubscriptionCubit subscriptionCubit,
    required OwnerContextCubit ownerContextCubit,
  })  : _authSession = authSession,
        _subscriptionCubit = subscriptionCubit,
        _ownerContextCubit = ownerContextCubit;

  final AuthSessionController _authSession;
  final SubscriptionCubit _subscriptionCubit;
  final OwnerContextCubit _ownerContextCubit;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _subscriptionCubit.updateFromHeader(
      response.headers.value('X-Subscription-Status'),
    );

    final data = response.data;
    // B) HTTP 200 + status:false — biznes-xatolik / rate-limit.
    if (data is Map && data['status'] == false) {
      final message = _extractBusinessMessage(data);
      final failure = message.contains('Juda ko\'p urinish')
          ? ThrottleFailure(message)
          : BusinessFailure(message);
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: failure,
          type: DioExceptionType.badResponse,
        ),
      );
      return;
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.error is Failure) {
      handler.next(err);
      return;
    }

    _subscriptionCubit.updateFromHeader(
      err.response?.headers.value('X-Subscription-Status'),
    );

    final failure = _mapToFailure(err);
    handler.next(err.copyWith(error: failure));
  }

  Failure _mapToFailure(DioException err) {
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;

    switch (statusCode) {
      case 401:
        _authSession.notifyUnauthenticated();
        return const AuthFailure();

      case 403:
        final message = _extractPlainMessage(data) ?? const PermissionFailure().message;
        if (message.contains('akkaunt')) {
          _ownerContextCubit.reset();
          _authSession.notifyOwnerContextInvalid();
        }
        return PermissionFailure(message);

      case 422:
        return ValidationFailure(_extractValidationErrors(data));

      case null:
        switch (err.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.connectionError:
            return const NetworkFailure();
          case DioExceptionType.cancel:
            return const UnknownFailure('So\'rov bekor qilindi');
          default:
            return const NetworkFailure();
        }

      default:
        if (statusCode >= 500) return const ServerFailure();
        return UnknownFailure(_extractPlainMessage(data) ?? 'Kutilmagan xatolik yuz berdi');
    }
  }

  String _extractBusinessMessage(Map data) {
    final error = data['error'];
    if (error is Map && error['message'] is String) return error['message'] as String;
    if (data['message'] is String) return data['message'] as String;
    return 'Xatolik yuz berdi';
  }

  String? _extractPlainMessage(dynamic data) {
    if (data is Map && data['message'] is String) return data['message'] as String;
    return null;
  }

  Map<String, String> _extractValidationErrors(dynamic data) {
    final result = <String, String>{};
    if (data is Map && data['errors'] is Map) {
      (data['errors'] as Map).forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          result[key.toString()] = value.first.toString();
        } else if (value is String) {
          result[key.toString()] = value;
        }
      });
    }
    return result;
  }
}
