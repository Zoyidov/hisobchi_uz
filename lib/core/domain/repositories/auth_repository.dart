import '../../network/api_result.dart';
import '../entities/auth_results.dart';
import '../entities/user_entity.dart';

/// Auth kontrakti — core qatlami (router, cubitlar) shu interfeysga bog'lanadi,
/// haqiqiy implementatsiya esa `features/auth/data`da yashaydi (Dependency
/// Inversion — E_HISOB_FLUTTER_UI_UX_TZ.md 81-bo'lim).
abstract class AuthRepository {
  Future<ApiResult<VersionCheckResult>> checkVersion({
    required String appVersion,
    required String platformType,
  });

  Future<ApiResult<VerifyNumberResult>> verifyNumber(String phone);

  Future<ApiResult<void>> sendOtp(String phone);

  Future<ApiResult<OtpVerifyResult>> verifyOtp({required String phone, required String otpCode});

  Future<ApiResult<AuthTokenResult>> register({
    required String name,
    required String phone,
    required String password,
    required String verifyToken,
    required String deviceToken,
    required String deviceType,
  });

  Future<ApiResult<AuthTokenResult>> login({
    required String phone,
    required String password,
    required String deviceToken,
    required String deviceType,
  });

  Future<ApiResult<AuthTokenResult>> resetPassword({
    required String phone,
    required String otpCode,
    required String password,
  });

  Future<ApiResult<UserEntity>> me();

  Future<ApiResult<void>> logout(String deviceToken);

  Future<ApiResult<void>> deleteAccount();

  Future<ApiResult<void>> updateAppSettings({
    required int userId,
    String? language,
    String? mode,
    String? pincode,
  });

  Future<ApiResult<bool>> verifyPincode({required int userId, required String pincode});

  Future<ApiResult<void>> updateProfileName(String name);

  Future<ApiResult<void>> updatePassword({required String oldPassword, required String newPassword});

  /// `result.page == "otp_verify"` bo'lsa yangi raqamga OTP yuborish mumkin
  /// (MOBILE_APP_TZ.md 17.2).
  Future<ApiResult<String>> verifyNewPhone(String phone);

  Future<ApiResult<void>> confirmNewPhone({required String phone, required String otpCode});

  Future<ApiResult<void>> activateOwnAccount();
}
