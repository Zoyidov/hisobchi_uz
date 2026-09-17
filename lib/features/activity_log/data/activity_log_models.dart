import '../../../core/utils/formatters/date_formatter.dart';

enum ActivityAction { created, updated, cancelled, deleted, restored }

extension ActivityActionX on ActivityAction {
  static ActivityAction fromApi(String? value) => switch (value) {
        'updated' => ActivityAction.updated,
        'cancelled' => ActivityAction.cancelled,
        'deleted' => ActivityAction.deleted,
        'restored' => ActivityAction.restored,
        _ => ActivityAction.created,
      };

  String get apiValue => switch (this) {
        ActivityAction.created => 'created',
        ActivityAction.updated => 'updated',
        ActivityAction.cancelled => 'cancelled',
        ActivityAction.deleted => 'deleted',
        ActivityAction.restored => 'restored',
      };

  /// Amallar lug'ati (MOBILE_APP_TZ.md 16-bo'lim).
  String get label => switch (this) {
        ActivityAction.created => 'yaratdi',
        ActivityAction.updated => 'tahrirladi',
        ActivityAction.cancelled => 'bekor qildi',
        ActivityAction.deleted => "o'chirdi",
        ActivityAction.restored => 'tikladi',
      };
}

/// Faollik jurnali yozuvi (MOBILE_APP_TZ.md 16-bo'lim).
class ActivityLogEntry {
  const ActivityLogEntry({
    required this.id,
    required this.action,
    required this.modelType,
    required this.modelId,
    required this.performedByName,
    this.description,
    this.createdAt,
  });

  final int id;
  final ActivityAction action;
  final String modelType;
  final int modelId;
  final String performedByName;
  final Map<String, dynamic>? description;
  final DateTime? createdAt;

  static const _modelLabels = {
    'Wallet': 'tranzaksiyani',
    'Partner': 'hamkorni',
    'Project': 'loyihani',
    'InstallmentPlan': 'bo\'lib to\'lash rejasini',
  };

  String get summary => '$performedByName ${_modelLabels[modelType] ?? ''} ${action.label}'.replaceAll('  ', ' ');

  factory ActivityLogEntry.fromJson(Map<String, dynamic> json) => ActivityLogEntry(
        id: json['id'] as int,
        action: ActivityActionX.fromApi(json['action'] as String?),
        modelType: json['model_type'] as String? ?? '',
        modelId: json['model_id'] as int? ?? 0,
        performedByName: (json['performed_by'] as Map<String, dynamic>?)?['name'] as String? ?? '',
        description: json['description'] as Map<String, dynamic>?,
        createdAt: json['created_at'] != null
            ? (DateTime.tryParse(json['created_at'] as String) ?? AppDateFormatter.parseFromBackend(json['created_at'] as String))
            : null,
      );
}
