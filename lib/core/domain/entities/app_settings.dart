class AppSettingsEntity {
  const AppSettingsEntity({this.language, this.mode, this.pincode});

  final String? language;
  final String? mode;
  final String? pincode;

  factory AppSettingsEntity.fromJson(Map<String, dynamic> json) => AppSettingsEntity(
        language: json['language'] as String?,
        mode: json['mode'] as String?,
        pincode: json['pincode'] as String?,
      );

  static const empty = AppSettingsEntity();
}
