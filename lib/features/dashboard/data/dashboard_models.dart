import 'package:decimal/decimal.dart';

import '../../../core/utils/formatters/date_formatter.dart';
import '../../../core/utils/money.dart';

/// `GET /reports/dashboard` javobi (MOBILE_APP_TZ.md 7.1).
class DashboardSummary {
  const DashboardSummary({
    required this.partnersCount,
    required this.qarzExpired,
    required this.qarzToday,
    required this.qarz3Days,
    required this.installmentExpired,
    required this.installmentToday,
    required this.installment3Days,
    required this.projectsCount,
    required this.projectsInProgress,
    required this.projectsFrozen,
    required this.projectsCompleted,
  });

  final int partnersCount;
  final int qarzExpired;
  final int qarzToday;
  final int qarz3Days;
  final int installmentExpired;
  final int installmentToday;
  final int installment3Days;
  final int projectsCount;
  final int projectsInProgress;
  final int projectsFrozen;
  final int projectsCompleted;

  static int _count(Map<String, dynamic>? details, String key) {
    final entry = details?[key] as Map<String, dynamic>?;
    return entry?['count'] as int? ?? 0;
  }

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final partners = json['partners'] as Map<String, dynamic>? ?? const {};
    final details = partners['details'] as Map<String, dynamic>? ?? const {};
    final projects = json['projects'] as Map<String, dynamic>? ?? const {};
    return DashboardSummary(
      partnersCount: partners['partners_count'] as int? ?? 0,
      qarzExpired: _count(details, 'qarz_expired'),
      qarzToday: _count(details, 'qarz_today'),
      qarz3Days: _count(details, 'qarz_3_days'),
      installmentExpired: _count(details, 'installment_expired'),
      installmentToday: _count(details, 'installment_today'),
      installment3Days: _count(details, 'installment_3_days'),
      projectsCount: projects['projects_count'] as int? ?? 0,
      projectsInProgress: projects['in_progress'] as int? ?? 0,
      projectsFrozen: projects['frozen'] as int? ?? 0,
      projectsCompleted: projects['completed'] as int? ?? 0,
    );
  }

  static const empty = DashboardSummary(
    partnersCount: 0,
    qarzExpired: 0,
    qarzToday: 0,
    qarz3Days: 0,
    installmentExpired: 0,
    installmentToday: 0,
    installment3Days: 0,
    projectsCount: 0,
    projectsInProgress: 0,
    projectsFrozen: 0,
    projectsCompleted: 0,
  );
}

enum DueDateType { qarzExpired, qarzToday, qarz3Days, installmentExpired, installmentToday, installment3Days }

extension DueDateTypeX on DueDateType {
  String get apiValue => switch (this) {
        DueDateType.qarzExpired => 'qarz_expired',
        DueDateType.qarzToday => 'qarz_today',
        DueDateType.qarz3Days => 'qarz_3_days',
        DueDateType.installmentExpired => 'installment_expired',
        DueDateType.installmentToday => 'installment_today',
        DueDateType.installment3Days => 'installment_3_days',
      };

  bool get isInstallment => this == DueDateType.installmentExpired ||
      this == DueDateType.installmentToday ||
      this == DueDateType.installment3Days;
}

/// Hamkor qarz muddati detali (MOBILE_APP_TZ.md 7.2-A).
class PartnerDueItem {
  const PartnerDueItem({
    required this.walletId,
    required this.partnerId,
    required this.partnerName,
    required this.partnerPhone,
    required this.type,
    required this.remainingAmount,
    required this.currencyTypeId,
    required this.currencyTypeName,
    required this.dueDate,
    required this.daysOverdue,
    required this.daysLeft,
    required this.status,
  });

  final int walletId;
  final int partnerId;
  final String partnerName;
  final String partnerPhone;
  final String type;
  final Decimal remainingAmount;
  final int currencyTypeId;
  final String currencyTypeName;
  final DateTime? dueDate;
  final int? daysOverdue;
  final int? daysLeft;
  final String status;

  factory PartnerDueItem.fromJson(Map<String, dynamic> json) => PartnerDueItem(
        walletId: json['wallet_id'] as int? ?? 0,
        partnerId: json['partner_id'] as int? ?? 0,
        partnerName: json['partner_name'] as String? ?? '',
        partnerPhone: json['partner_phone'] as String? ?? '',
        type: json['type'] as String? ?? 'credit',
        remainingAmount: parseMoney(json['remaining_amount']),
        currencyTypeId: json['currency_type_id'] as int? ?? 1,
        currencyTypeName: json['currency_type_name'] as String? ?? 'UZS',
        dueDate: AppDateFormatter.parseFromBackend(json['due_date'] as String?),
        daysOverdue: json['days_overdue'] as int?,
        daysLeft: json['days_left'] as int?,
        status: json['status'] as String? ?? '',
      );
}

/// Bo'lib to'lash muddati detali (MOBILE_APP_TZ.md 7.2-B).
class InstallmentDueItem {
  const InstallmentDueItem({
    required this.planId,
    required this.itemNumber,
    required this.isAdvance,
    required this.amount,
    required this.remaining,
    required this.partnerName,
    required this.partnerPhone,
    required this.dueDate,
    required this.daysOverdue,
    required this.daysLeft,
    required this.statusLabel,
  });

  final int planId;
  final int itemNumber;
  final bool isAdvance;
  final Decimal amount;
  final Decimal remaining;
  final String partnerName;
  final String partnerPhone;
  final DateTime? dueDate;
  final int? daysOverdue;
  final int? daysLeft;
  final String statusLabel;

  factory InstallmentDueItem.fromJson(Map<String, dynamic> json) => InstallmentDueItem(
        planId: json['plan_id'] as int? ?? 0,
        itemNumber: json['item_number'] as int? ?? 0,
        isAdvance: json['is_advance'] as bool? ?? false,
        amount: parseMoney(json['amount']),
        remaining: parseMoney(json['remaining']),
        partnerName: json['partner_name'] as String? ?? '',
        partnerPhone: json['partner_phone'] as String? ?? '',
        dueDate: AppDateFormatter.parseFromBackend(json['due_date'] as String?),
        daysOverdue: json['days_overdue'] as int?,
        daysLeft: json['days_left'] as int?,
        statusLabel: json['status_label'] as String? ?? '',
      );
}

class TutorialItem {
  const TutorialItem({required this.title, required this.url});
  final String title;
  final String url;

  factory TutorialItem.fromJson(Map<String, dynamic> json) =>
      TutorialItem(title: json['title'] as String? ?? '', url: json['url'] as String? ?? '');
}
