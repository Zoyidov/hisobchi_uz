import '../../../core/constants/app_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import 'staff_models.dart';

class StaffRepository {
  StaffRepository(this._client);

  final ApiClient _client;

  Future<ApiResult<List<StaffMember>>> getStaff() =>
      _client.getList(ApiEndpoints.staff, fromJson: StaffMember.fromJson);

  Future<ApiResult<List<PermissionGroup>>> getPermissionGroups() {
    return _client.get<List<PermissionGroup>>(
      ApiEndpoints.staffPermissions,
      parse: (result) {
        final groups = <PermissionGroup>[];
        if (result is Map<String, dynamic>) {
          result.forEach((category, items) {
            if (items is! List) return;
            final options = items.map((item) {
              if (item is Map<String, dynamic>) return PermissionOption.fromJson(item);
              final key = item.toString();
              final label = key.contains('.') ? key.split('.').last : key;
              return PermissionOption(key: key, label: label);
            }).toList();
            groups.add(PermissionGroup(category: category, items: options));
          });
        }
        return groups;
      },
    );
  }

  Future<ApiResult<void>> sendOtp(String phone) =>
      _client.post(ApiEndpoints.staffSendOtp, data: {'phone': phone}, parse: (_) {});

  Future<ApiResult<String>> verifyOtp({required String phone, required String otpCode}) {
    return _client.post(
      ApiEndpoints.staffVerifyOtp,
      data: {'phone': phone, 'otp_code': otpCode},
      parse: (r) => (r as Map<String, dynamic>)['verify_token'] as String? ?? '',
    );
  }

  Future<ApiResult<void>> createStaff({
    required String phone,
    required String verifyToken,
    required String name,
    required String password,
    required List<String> permissions,
  }) {
    return _client.post(
      ApiEndpoints.staff,
      data: {
        'phone': phone,
        'verify_token': verifyToken,
        'name': name,
        'password': password,
        'permissions': permissions,
      },
      parse: (_) {},
    );
  }

  Future<ApiResult<void>> updateStaff(int id, {required List<String> permissions, required bool isActive}) {
    return _client.put(
      ApiEndpoints.staffById(id),
      data: {'permissions': permissions, 'is_active': isActive},
      parse: (_) {},
    );
  }

  Future<ApiResult<void>> deleteStaff(int id) => _client.delete(ApiEndpoints.staffById(id), parse: (_) {});

  Future<ApiResult<void>> activateOwnAccount() =>
      _client.post(ApiEndpoints.activateOwnAccount, parse: (_) {});
}
