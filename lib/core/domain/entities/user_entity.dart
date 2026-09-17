import '../../cubits/owner_context_cubit.dart';
import 'app_settings.dart';
import 'works_for_entry.dart';

/// `GET /auth/me` javobi (MOBILE_APP_TZ.md 6.1).
class UserEntity {
  const UserEntity({
    required this.userId,
    required this.name,
    required this.phone,
    this.image,
    required this.role,
    required this.permissions,
    required this.worksFor,
    required this.appSettings,
    required this.xZiffler,
  });

  final int userId;
  final String name;
  final String phone;
  final String? image;
  final List<String> role;
  final List<String> permissions;
  final List<WorksForEntry> worksFor;
  final AppSettingsEntity appSettings;
  final bool xZiffler;

  bool get isOwner => role.contains('user');
  bool get isStaff => role.contains('staff');
  bool get hasMultipleContexts => isOwner && isStaff;

  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
        userId: json['user_id'] as int,
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        image: json['image'] as String?,
        role: (json['role'] as List? ?? const []).cast<String>(),
        permissions: (json['permissions'] as List? ?? const []).cast<String>(),
        worksFor: (json['works_for'] as List? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(WorksForEntry.fromJson)
            .toList(),
        appSettings: json['app_settings'] != null
            ? AppSettingsEntity.fromJson(json['app_settings'] as Map<String, dynamic>)
            : AppSettingsEntity.empty,
        xZiffler: json['x_ziffler'] as bool? ?? true,
      );

  /// Owner kontekstiga qarab amal qiluvchi ruxsatlar ro'yxati
  /// (MOBILE_APP_TZ.md 6.5.4).
  List<String> permissionsFor(OwnerContext context) {
    if (!context.isStaffMode) return permissions;
    for (final w in worksFor) {
      if (w.ownerId == context.ownerId) return w.permissions;
    }
    return const [];
  }

  bool hasPermission(String permission, OwnerContext context) =>
      permissionsFor(context).contains(permission);
}
