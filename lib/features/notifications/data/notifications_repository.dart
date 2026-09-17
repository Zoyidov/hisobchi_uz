import '../../../core/constants/app_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import 'notification_models.dart';

class NotificationsPage {
  const NotificationsPage({required this.items, required this.currentPage, required this.lastPage});
  final List<AppNotification> items;
  final int currentPage;
  final int lastPage;
  bool get hasNext => currentPage < lastPage;
}

class NotificationsRepository {
  NotificationsRepository(this._client);

  final ApiClient _client;

  /// Laravel standart paginator formati — `meta.last_page` bilan
  /// (MOBILE_APP_TZ.md 14.2).
  Future<ApiResult<NotificationsPage>> getNotifications({required int page}) {
    return _client.get(
      ApiEndpoints.notifications,
      query: {'page': page},
      parse: (r) {
        final map = r as Map<String, dynamic>;
        final data = (map['data'] as List? ?? const []).cast<Map<String, dynamic>>().map(AppNotification.fromJson).toList();
        final meta = map['meta'] as Map<String, dynamic>? ?? const {};
        return NotificationsPage(
          items: data,
          currentPage: meta['current_page'] as int? ?? 1,
          lastPage: meta['last_page'] as int? ?? 1,
        );
      },
    );
  }

  Future<ApiResult<int>> getUnreadCount() {
    return _client.get(ApiEndpoints.notificationsUnreadCount, parse: (r) => (r as Map<String, dynamic>)['unread_count'] as int? ?? 0);
  }

  Future<ApiResult<void>> markAsRead(int notificationId) {
    return _client.post(ApiEndpoints.notificationMarkAsRead(notificationId), parse: (_) {});
  }
}
