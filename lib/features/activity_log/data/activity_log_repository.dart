import '../../../core/constants/app_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/paged_result.dart';
import 'activity_log_models.dart';

class ActivityLogRepository {
  ActivityLogRepository(this._client);

  final ApiClient _client;

  Future<ApiResult<StandardPage<ActivityLogEntry>>> getActivityLog({
    required int page,
    ActivityAction? action,
    String? modelType,
    int? performedBy,
  }) {
    return _client.getStandardPage(
      ApiEndpoints.activityLog,
      query: {
        'per_page': 20,
        'page': page,
        if (action != null) 'action': action.apiValue,
        if (modelType != null) 'model_type': modelType,
        if (performedBy != null) 'performed_by': performedBy,
      },
      fromJson: ActivityLogEntry.fromJson,
    );
  }
}
