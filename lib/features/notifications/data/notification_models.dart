import '../../../core/utils/formatters/date_formatter.dart';

/// Bildirishnoma (MOBILE_APP_TZ.md 14.2-14.3).
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.imageUrl,
    required this.isRead,
    this.createdAt,
  });

  final int id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final bool isRead;
  final DateTime? createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final notification = json['notification'] as Map<String, dynamic>? ?? json;
    return AppNotification(
      id: json['id'] as int? ?? notification['id'] as int? ?? 0,
      type: notification['type'] as String? ?? 'system',
      title: notification['title'] as String? ?? '',
      body: notification['body'] as String? ?? '',
      data: notification['data'] as Map<String, dynamic>?,
      imageUrl: notification['image_url'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: AppDateFormatter.parseFromBackend(json['created_at'] as String?) ??
          (json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null),
    );
  }
}
