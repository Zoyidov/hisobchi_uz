import '../../../core/utils/formatters/date_formatter.dart';

/// Xodim (MOBILE_APP_TZ.md 15.2).
class StaffMember {
  const StaffMember({
    required this.id,
    required this.isActive,
    required this.userId,
    required this.name,
    required this.phone,
    required this.permissions,
    this.createdAt,
  });

  final int id;
  final bool isActive;
  final int userId;
  final String name;
  final String phone;
  final List<String> permissions;
  final DateTime? createdAt;

  factory StaffMember.fromJson(Map<String, dynamic> json) => StaffMember(
        id: json['id'] as int,
        isActive: json['is_active'] as bool? ?? true,
        userId: json['user_id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        permissions: (json['permissions'] as List? ?? const []).cast<String>(),
        createdAt: AppDateFormatter.parseFromBackend(json['created_at'] as String?),
      );
}

/// Ruxsat elementi — `GET /auth/staff/permissions` kategoriya ichida.
class PermissionOption {
  const PermissionOption({required this.key, required this.label});
  final String key;
  final String label;

  factory PermissionOption.fromJson(Map<String, dynamic> json) => PermissionOption(
        key: json['key'] as String? ?? json['value'] as String? ?? '',
        label: json['label'] as String? ?? json['name'] as String? ?? '',
      );
}

/// Kategoriya bo'yicha guruhlangan ruxsatlar ro'yxati (MOBILE_APP_TZ.md 6.4, 15.1).
class PermissionGroup {
  const PermissionGroup({required this.category, required this.items});
  final String category;
  final List<PermissionOption> items;

  factory PermissionGroup.fromJson(String category, List<dynamic> items) => PermissionGroup(
        category: category,
        items: items.cast<Map<String, dynamic>>().map(PermissionOption.fromJson).toList(),
      );
}
