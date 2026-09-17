import '../../../core/domain/entities/auth_results.dart';
import '../../../core/domain/entities/user_entity.dart';
import '../../../core/domain/repositories/auth_repository.dart';
import '../../../core/network/api_result.dart';
import '../../../core/utils/formatters/phone_formatter.dart';
import 'auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<ApiResult<VersionCheckResult>> checkVersion({
    required String appVersion,
    required String platformType,
  }) {
    return _remote.checkVersion(appVersion: appVersion, platformType: platformType);
  }

  @override
  Future<ApiResult<VerifyNumberResult>> verifyNumber(String phone) {
    return _remote.verifyNumber(PhoneFormatter.toApi(phone));
  }

  @override
  Future<ApiResult<void>> sendOtp(String phone) => _remote.sendOtp(PhoneFormatter.toApi(phone));

  @override
  Future<ApiResult<OtpVerifyResult>> verifyOtp({required String phone, required String otpCode}) {
    return _remote.verifyOtp(phone: PhoneFormatter.toApi(phone), otpCode: otpCode);
  }

  @override
  Future<ApiResult<AuthTokenResult>> register({
    required String name,
    required String phone,
    required String password,
    required String verifyToken,
    required String deviceToken,
    required String deviceType,
  }) {
    return _remote.register({
      'name': name,
      'phone': PhoneFormatter.toApi(phone),
      'password': password,
      'verify_token': verifyToken,
      'device_name': deviceType == 'ios' ? 'iPhone' : 'Android',
      'device_token': deviceToken,
      'device_type': deviceType,
    });
  }

  @override
  Future<ApiResult<AuthTokenResult>> login({
    required String phone,
    required String password,
    required String deviceToken,
    required String deviceType,
  }) {
    return _remote.login({
      'phone': PhoneFormatter.toApi(phone),
      'password': password,
      'device_name': deviceType == 'ios' ? 'iPhone' : 'Android',
      'device_token': deviceToken,
      'device_type': deviceType,
    });
  }

  @override
  Future<ApiResult<AuthTokenResult>> resetPassword({
    required String phone,
    required String otpCode,
    required String password,
  }) {
    return _remote.resetPassword({
      'phone': PhoneFormatter.toApi(phone),
      'otp_code': otpCode,
      'password': password,
    });
  }

  @override
  Future<ApiResult<UserEntity>> me() => _remote.me();

  @override
  Future<ApiResult<void>> logout(String deviceToken) => _remote.logout(deviceToken);

  @override
  Future<ApiResult<void>> deleteAccount() => _remote.deleteAccount();

  @override
  Future<ApiResult<void>> updateAppSettings({
    required int userId,
    String? language,
    String? mode,
    String? pincode,
  }) {
    final body = <String, dynamic>{};
    if (language != null) body['language'] = language;
    if (mode != null) body['mode'] = mode;
    if (pincode != null) body['pincode'] = pincode;
    return _remote.updateAppSettings(userId, body);
  }

  @override
  Future<ApiResult<bool>> verifyPincode({required int userId, required String pincode}) {
    return _remote.verifyPincode(userId, pincode);
  }

  @override
  Future<ApiResult<void>> updateProfileName(String name) => _remote.updateProfileInfo(name);

  @override
  Future<ApiResult<void>> updatePassword({required String oldPassword, required String newPassword}) =>
      _remote.updatePassword(oldPassword, newPassword);

  @override
  Future<ApiResult<String>> verifyNewPhone(String phone) =>
      _remote.updateProfilePhoneVerify(PhoneFormatter.toApi(phone));

  @override
  Future<ApiResult<void>> confirmNewPhone({required String phone, required String otpCode}) =>
      _remote.updateProfilePhoneCheckOtp(PhoneFormatter.toApi(phone), otpCode);

  @override
  Future<ApiResult<void>> activateOwnAccount() => _remote.activateOwnAccount();
}
