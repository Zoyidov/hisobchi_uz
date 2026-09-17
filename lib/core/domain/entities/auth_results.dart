import 'user_entity.dart';

class VersionCheckResult {
  const VersionCheckResult({
    required this.updateRequired,
    required this.updateStatus,
    required this.storeVersion,
  });

  final bool updateRequired;
  final String updateStatus; // hard | soft
  final String storeVersion;

  factory VersionCheckResult.fromJson(Map<String, dynamic> json) => VersionCheckResult(
        updateRequired: json['update'] as bool? ?? false,
        updateStatus: json['update_status'] as String? ?? 'soft',
        storeVersion: json['current_version_play_market'] as String? ?? '',
      );
}

class VerifyNumberResult {
  const VerifyNumberResult({required this.page});

  /// `login` | `register`
  final String page;

  factory VerifyNumberResult.fromJson(Map<String, dynamic> json) =>
      VerifyNumberResult(page: json['page'] as String? ?? 'login');
}

class OtpVerifyResult {
  const OtpVerifyResult({required this.verifyToken, required this.expiresIn});

  final String verifyToken;
  final int expiresIn;

  factory OtpVerifyResult.fromJson(Map<String, dynamic> json) => OtpVerifyResult(
        verifyToken: json['verify_token'] as String? ?? '',
        expiresIn: json['expires_in'] as int? ?? 120,
      );
}

class AuthTokenResult {
  const AuthTokenResult({required this.token});
  final String token;

  factory AuthTokenResult.fromJson(Map<String, dynamic> json) =>
      AuthTokenResult(token: json['token'] as String? ?? '');
}

class PermissionCategory {
  const PermissionCategory({required this.category, required this.items});
  final String category;
  final List<PermissionItem> items;
}

class PermissionItem {
  const PermissionItem({required this.key, required this.label});
  final String key;
  final String label;
}

typedef MeResult = UserEntity;
