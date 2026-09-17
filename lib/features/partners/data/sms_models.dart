import '../../../core/utils/formatters/date_formatter.dart';

/// Yuborilgan SMS yozuvi (MOBILE_APP_TZ.md 8.9).
class SentSms {
  const SentSms({required this.id, required this.message, required this.status, this.sentAt});

  final int id;
  final String message;
  final String status; // success | failed
  final DateTime? sentAt;

  bool get isSuccess => status == 'success';

  factory SentSms.fromJson(Map<String, dynamic> json) => SentSms(
        id: json['id'] as int,
        message: json['message'] as String? ?? '',
        status: json['status'] as String? ?? 'failed',
        sentAt: AppDateFormatter.parseFromBackend(json['sent_at'] as String?),
      );
}

/// Hamkor bo'yicha SMS sozlamalari (MOBILE_APP_TZ.md 8.10).
class PartnerSmsSettings {
  const PartnerSmsSettings({
    required this.enabled,
    required this.sendOnKirim,
    required this.sendOnChiqim,
    required this.remindBeforeDays,
    required this.sendOnDueDate,
    required this.sendAfterDueDays,
    required this.sendDate,
    required this.remindBeforeOptions,
    required this.sendAfterOptions,
  });

  final bool enabled;
  final bool sendOnKirim;
  final bool sendOnChiqim;
  final int remindBeforeDays;
  final bool sendOnDueDate;
  final int sendAfterDueDays;
  final String sendDate;
  final List<int> remindBeforeOptions;
  final List<int> sendAfterOptions;

  factory PartnerSmsSettings.fromJson(Map<String, dynamic> json) {
    final body = json['body'] as Map<String, dynamic>? ?? json;
    final options = json['options'] as Map<String, dynamic>? ?? const {};
    return PartnerSmsSettings(
      enabled: body['enabled'] as bool? ?? true,
      sendOnKirim: body['send_on_kirim'] as bool? ?? true,
      sendOnChiqim: body['send_on_chiqim'] as bool? ?? true,
      remindBeforeDays: body['remind_before_days'] as int? ?? 1,
      sendOnDueDate: body['send_on_due_date'] as bool? ?? true,
      sendAfterDueDays: body['send_after_due_days'] as int? ?? 1,
      sendDate: body['send_date'] as String? ?? '10:00',
      remindBeforeOptions: (options['remind_before_days'] as List? ?? [1, 3, 5]).cast<int>(),
      sendAfterOptions: (options['send_after_due_days'] as List? ?? [1, 3, 5]).cast<int>(),
    );
  }

  PartnerSmsSettings copyWith({
    bool? enabled,
    bool? sendOnKirim,
    bool? sendOnChiqim,
    int? remindBeforeDays,
    bool? sendOnDueDate,
    int? sendAfterDueDays,
  }) {
    return PartnerSmsSettings(
      enabled: enabled ?? this.enabled,
      sendOnKirim: sendOnKirim ?? this.sendOnKirim,
      sendOnChiqim: sendOnChiqim ?? this.sendOnChiqim,
      remindBeforeDays: remindBeforeDays ?? this.remindBeforeDays,
      sendOnDueDate: sendOnDueDate ?? this.sendOnDueDate,
      sendAfterDueDays: sendAfterDueDays ?? this.sendAfterDueDays,
      sendDate: sendDate,
      remindBeforeOptions: remindBeforeOptions,
      sendAfterOptions: sendAfterOptions,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'send_on_kirim': sendOnKirim,
        'send_on_chiqim': sendOnChiqim,
        'remind_before_days': remindBeforeDays,
        'send_on_due_date': sendOnDueDate,
        'send_after_due_days': sendAfterDueDays,
      };
}
