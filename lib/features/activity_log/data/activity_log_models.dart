import '../../../core/localization/app_localization_extension.dart';
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

  /// Amallar lug'ati (MOBILE_APP_TZ.md 16-bo'lim) — fe'l, joriy tilda.
  String label(AppLocalizations l10n) => switch (this) {
    ActivityAction.created => l10n.activityActionCreated,
    ActivityAction.updated => l10n.activityActionUpdated,
    ActivityAction.cancelled => l10n.activityActionCancelled,
    ActivityAction.deleted => l10n.activityActionDeleted,
    ActivityAction.restored => l10n.activityActionRestored,
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

  /// Amal obyekti (tushum kelishigida): "hamkorni", "партнёра".
  String? _modelLabel(AppLocalizations l10n) => switch (modelType) {
    'Wallet' => l10n.activityModelWallet,
    'Partner' => l10n.activityModelPartner,
    'Project' => l10n.activityModelProject,
    'InstallmentPlan' => l10n.activityModelInstallmentPlan,
    _ => null,
  };

  /// "Ali hamkorni yaratdi" / "Али создал(а) партнёра" — so'z tartibi tilga
  /// qarab `activitySummary` shablonida belgilanadi.
  String summary(AppLocalizations l10n) => l10n
      .activitySummary(
        performedByName,
        _modelLabel(l10n) ?? '',
        action.label(l10n),
      )
      .replaceAll(RegExp(r'\s{2,}'), ' ')
      .trim();

  factory ActivityLogEntry.fromJson(
    Map<String, dynamic> json,
  ) => ActivityLogEntry(
    id: json['id'] as int,
    action: ActivityActionX.fromApi(json['action'] as String?),
    modelType: json['model_type'] as String? ?? '',
    modelId: json['model_id'] as int? ?? 0,
    performedByName:
        (json['performed_by'] as Map<String, dynamic>?)?['name'] as String? ??
        '',
    description: json['description'] as Map<String, dynamic>?,
    createdAt: json['created_at'] != null
        ? (DateTime.tryParse(json['created_at'] as String) ??
              AppDateFormatter.parseFromBackend(json['created_at'] as String))
        : null,
  );
}
