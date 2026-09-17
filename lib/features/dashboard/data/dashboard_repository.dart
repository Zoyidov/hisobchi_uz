import '../../../core/constants/app_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/paged_result.dart';
import 'dashboard_models.dart';

class DashboardRepository {
  DashboardRepository(this._client);

  final ApiClient _client;

  Future<ApiResult<DashboardSummary>> getSummary() {
    return _client.get(
      ApiEndpoints.dashboard,
      parse: (r) => DashboardSummary.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<SimplePage<PartnerDueItem>>> getPartnerDueDates(DueDateType type, {int page = 1}) {
    return _client.getSimplePage(
      ApiEndpoints.dashboardDueDates,
      query: {'type': type.apiValue, 'page': page},
      fromJson: PartnerDueItem.fromJson,
    );
  }

  Future<ApiResult<SimplePage<InstallmentDueItem>>> getInstallmentDueDates(DueDateType type, {int page = 1}) {
    return _client.getSimplePage(
      ApiEndpoints.dashboardInstallmentDueDates,
      query: {'type': type.apiValue, 'page': page},
      fromJson: InstallmentDueItem.fromJson,
    );
  }

  Future<ApiResult<List<TutorialItem>>> getTutorials() {
    return _client.getList(ApiEndpoints.tutorials, fromJson: TutorialItem.fromJson);
  }
}
