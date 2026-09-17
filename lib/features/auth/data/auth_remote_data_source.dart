import '../../../core/constants/app_endpoints.dart';
import '../../../core/domain/entities/auth_results.dart';
import '../../../core/domain/entities/user_entity.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';

/// Xom API chaqiruvlari — model/parse mantiqi shu yerda, biznes qoidalar
/// repository qatlamida (MOBILE_APP_TZ.md bo'lim 5).
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<ApiResult<VersionCheckResult>> checkVersion({
    required String appVersion,
    required String platformType,
  }) {
    return _client.post(
      ApiEndpoints.checkVersion,
      data: {'app_version': appVersion, 'platform_type': platformType},
      parse: (r) => VersionCheckResult.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<VerifyNumberResult>> verifyNumber(String phone) {
    return _client.post(
      ApiEndpoints.verifyNumber,
      data: {'phone': phone},
      parse: (r) => VerifyNumberResult.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<void>> sendOtp(String phone) {
    return _client.post(ApiEndpoints.otp, data: {'phone': phone}, parse: (_) {});
  }

  Future<ApiResult<OtpVerifyResult>> verifyOtp({required String phone, required String otpCode}) {
    return _client.post(
      ApiEndpoints.otpVerify,
      data: {'phone': phone, 'otp_code': otpCode},
      parse: (r) => OtpVerifyResult.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<AuthTokenResult>> register(Map<String, dynamic> body) {
    return _client.post(
      ApiEndpoints.register,
      data: body,
      parse: (r) => AuthTokenResult.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<AuthTokenResult>> login(Map<String, dynamic> body) {
    return _client.post(
      ApiEndpoints.login,
      data: body,
      parse: (r) => AuthTokenResult.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<AuthTokenResult>> resetPassword(Map<String, dynamic> body) {
    return _client.post(
      ApiEndpoints.resetPassword,
      data: body,
      parse: (r) => AuthTokenResult.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<UserEntity>> me() {
    return _client.get(
      ApiEndpoints.me,
      parse: (r) => UserEntity.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<void>> logout(String deviceToken) {
    return _client.get(ApiEndpoints.logout(deviceToken), parse: (_) {});
  }

  Future<ApiResult<void>> deleteAccount() {
    return _client.delete(ApiEndpoints.deleteAccount, parse: (_) {});
  }

  Future<ApiResult<void>> updateAppSettings(int userId, Map<String, dynamic> body) {
    return _client.post(ApiEndpoints.appSettings(userId), data: body, parse: (_) {});
  }

  Future<ApiResult<bool>> verifyPincode(int userId, String pincode) {
    return _client.post(
      ApiEndpoints.loginPincode(userId),
      data: {'pincode': pincode},
      parse: (r) => true,
    );
  }

  Future<ApiResult<void>> updateProfileInfo(String name) {
    return _client.put(ApiEndpoints.updateProfileInfo, data: {'name': name}, parse: (_) {});
  }

  Future<ApiResult<void>> updatePassword(String oldPassword, String newPassword) {
    return _client.post(
      ApiEndpoints.updatePassword,
      data: {'old_password': oldPassword, 'new_password': newPassword},
      parse: (_) {},
    );
  }

  Future<ApiResult<String>> updateProfilePhoneVerify(String phone) {
    return _client.post(
      ApiEndpoints.updateProfilePhoneVerify,
      data: {'phone': phone},
      parse: (r) => (r as Map<String, dynamic>)['page'] as String? ?? '',
    );
  }

  Future<ApiResult<void>> updateProfilePhoneCheckOtp(String phone, String otpCode) {
    return _client.post(
      ApiEndpoints.updateProfilePhoneCheckOtp,
      data: {'phone': phone, 'otp_code': otpCode},
      parse: (_) {},
    );
  }

  Future<ApiResult<void>> activateOwnAccount() => _client.post(ApiEndpoints.activateOwnAccount, parse: (_) {});
}
