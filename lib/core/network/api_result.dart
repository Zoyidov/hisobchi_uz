import '../errors/failure.dart';

/// Barcha repository metodlarining yagona qaytish turi. Feature qatlami hech
/// qachon `try/catch` bilan `DioException` ushlamaydi — bu network qatlamida
/// tugaydi (MOBILE_APP_TZ.md 4.3–4.4).
sealed class ApiResult<T> {
  const ApiResult();

  const factory ApiResult.success(T data) = ApiSuccess<T>;
  const factory ApiResult.failure(Failure failure) = ApiFailureResult<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    if (self is ApiSuccess<T>) return success(self.data);
    if (self is ApiFailureResult<T>) return failure(self.failure);
    throw StateError('Unreachable');
  }

  bool get isSuccess => this is ApiSuccess<T>;

  T? get dataOrNull => this is ApiSuccess<T> ? (this as ApiSuccess<T>).data : null;
}

final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);
  final T data;
}

final class ApiFailureResult<T> extends ApiResult<T> {
  const ApiFailureResult(this.failure);
  final Failure failure;
}
