import 'package:equatable/equatable.dart';

import '../localization/app_localization_extension.dart';

/// Markazlashgan xatolik turlari — Error-Interceptor (MOBILE_APP_TZ.md 4.4)
/// natijasida hosil bo'ladigan yagona shakl. UI faqat shu turlarni biladi,
/// `DioException` yoki boshqa xom xatolarni hech qachon ko'rmaydi.
///
/// [serverMessage] — backend qaytargan matn (u allaqachon foydalanuvchi
/// tilida). U bo'lmasa, [message] har bir tur uchun lokalizatsiya qilingan
/// standart matnni **o'qilgan paytdagi** til bo'yicha qaytaradi — shuning
/// uchun til almashtirilganda ham to'g'ri ko'rinadi.
sealed class Failure extends Equatable {
  const Failure([this.serverMessage]);

  /// Backend qaytargan xabar (bo'lishi shart emas).
  final String? serverMessage;

  /// Foydalanuvchiga to'g'ridan-to'g'ri ko'rsatiladigan matn.
  String get message {
    final server = serverMessage;
    if (server != null && server.trim().isNotEmpty) return server;
    return defaultMessage(AppL10n.current);
  }

  /// Tur bo'yicha standart, lokalizatsiya qilingan xabar.
  String defaultMessage(AppLocalizations l10n);

  @override
  List<Object?> get props => [runtimeType, serverMessage];
}

/// HTTP 200 + `status:false` yoki umumiy biznes-xatolik.
final class BusinessFailure extends Failure {
  const BusinessFailure([super.serverMessage]);

  @override
  String defaultMessage(AppLocalizations l10n) => l10n.errorGeneric;
}

/// HTTP 422 — maydon bo'yicha validatsiya xatolari.
final class ValidationFailure extends Failure {
  const ValidationFailure(this.fieldErrors);

  final Map<String, String> fieldErrors;

  @override
  String defaultMessage(AppLocalizations l10n) => l10n.errorValidation;

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// HTTP 401 — sessiya tugagan.
final class AuthFailure extends Failure {
  const AuthFailure([super.serverMessage]);

  @override
  String defaultMessage(AppLocalizations l10n) => l10n.errorSessionExpired;
}

/// HTTP 403 — ruxsat yo'q.
final class PermissionFailure extends Failure {
  const PermissionFailure([super.serverMessage]);

  @override
  String defaultMessage(AppLocalizations l10n) => l10n.errorNoPermission;
}

/// HTTP 5xx.
final class ServerFailure extends Failure {
  const ServerFailure([super.serverMessage]);

  @override
  String defaultMessage(AppLocalizations l10n) => l10n.errorServer;
}

/// Internet yo'q / timeout.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.serverMessage]);

  @override
  String defaultMessage(AppLocalizations l10n) => l10n.errorNoInternet;
}

/// Rate limit (429 ekvivalenti — backendda 200 + status:false bilan keladi,
/// lekin interceptor xabar matnidan aniqlab shu turga map qiladi).
final class ThrottleFailure extends Failure {
  const ThrottleFailure([super.serverMessage]);

  @override
  String defaultMessage(AppLocalizations l10n) => l10n.errorTooManyRequests;
}

/// Kutilmagan xatolik — Crashlytics'ga yuboriladi.
final class UnknownFailure extends Failure {
  const UnknownFailure([super.serverMessage]);

  @override
  String defaultMessage(AppLocalizations l10n) => l10n.errorUnknown;
}
