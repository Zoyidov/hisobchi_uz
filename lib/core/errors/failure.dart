import 'package:equatable/equatable.dart';

/// Markazlashgan xatolik turlari — Error-Interceptor (MOBILE_APP_TZ.md 4.4)
/// natijasida hosil bo'ladigan yagona shakl. UI faqat shu turlarni biladi,
/// `DioException` yoki boshqa xom xatolarni hech qachon ko'rmaydi.
sealed class Failure extends Equatable {
  const Failure(this.message);

  /// Foydalanuvchiga to'g'ridan-to'g'ri ko'rsatiladigan matn.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// HTTP 200 + `status:false` yoki umumiy biznes-xatolik.
final class BusinessFailure extends Failure {
  const BusinessFailure(super.message);
}

/// HTTP 422 — maydon bo'yicha validatsiya xatolari.
final class ValidationFailure extends Failure {
  const ValidationFailure(this.fieldErrors)
      : super('Kiritilgan ma\'lumotlarda xatolik bor');

  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => [message, fieldErrors];
}

/// HTTP 401 — sessiya tugagan.
final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Sessiya tugadi, qaytadan kiring']);
}

/// HTTP 403 — ruxsat yo'q.
final class PermissionFailure extends Failure {
  const PermissionFailure(
      [super.message = 'Bu amalni bajarish uchun ruxsatingiz yo\'q.']);
}

/// HTTP 5xx.
final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Serverda xatolik. Keyinroq urinib ko\'ring']);
}

/// Internet yo'q / timeout.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Internet aloqasi yo\'q']);
}

/// Rate limit (429 ekvivalenti — backendda 200 + status:false bilan keladi,
/// lekin interceptor xabar matnidan aniqlab shu turga map qiladi).
final class ThrottleFailure extends Failure {
  const ThrottleFailure(
      [super.message = 'Juda ko\'p urinish. Biroz kutib qayta urining.']);
}

/// Kutilmagan xatolik — Crashlytics'ga yuboriladi.
final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Kutilmagan xatolik yuz berdi']);
}
