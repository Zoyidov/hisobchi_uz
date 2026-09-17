class WorksForEntry {
  const WorksForEntry({
    required this.ownerId,
    required this.ownerName,
    required this.ownerPhone,
    required this.permissions,
  });

  final int ownerId;
  final String ownerName;
  final String ownerPhone;
  final List<String> permissions;

  factory WorksForEntry.fromJson(Map<String, dynamic> json) => WorksForEntry(
        ownerId: json['owner_id'] as int,
        ownerName: json['owner_name'] as String? ?? '',
        ownerPhone: json['owner_phone'] as String? ?? '',
        permissions: (json['permissions'] as List? ?? const []).cast<String>(),
      );
}
