import 'package:decimal/decimal.dart';

import '../../../core/utils/money.dart';
import '../../../core/utils/formatters/date_formatter.dart';

/// Umumiy ko'rinish (MOBILE_APP_TZ.md 12.3).
class InstallmentReportSummary {
  const InstallmentReportSummary({
    required this.activeCount,
    required this.completedCount,
    required this.cancelledCount,
    required this.totalGiven,
    required this.totalPaid,
    required this.totalRemaining,
    required this.overdueAmount,
  });

  final int activeCount;
  final int completedCount;
  final int cancelledCount;
  final Decimal totalGiven;
  final Decimal totalPaid;
  final Decimal totalRemaining;
  final Decimal overdueAmount;

  bool get isEmpty =>
      activeCount == 0 &&
      completedCount == 0 &&
      cancelledCount == 0 &&
      totalGiven == Decimal.zero &&
      totalPaid == Decimal.zero &&
      totalRemaining == Decimal.zero &&
      overdueAmount == Decimal.zero;

  factory InstallmentReportSummary.fromJson(
    Map<String, dynamic> json,
  ) => InstallmentReportSummary(
    activeCount:
        int.tryParse('${json['active_plans'] ?? json['active_count']}') ?? 0,
    completedCount:
        int.tryParse('${json['completed_plans'] ?? json['completed_count']}') ??
        0,
    cancelledCount:
        int.tryParse('${json['cancelled_plans'] ?? json['cancelled_count']}') ??
        0,
    totalGiven: parseMoney(json['total_given']),
    totalPaid: parseMoney(json['total_paid']),
    totalRemaining: parseMoney(json['total_remaining']),
    overdueAmount: parseMoney(json['overdue_amount']),
  );
}

/// Hamkorlar reytingi (MOBILE_APP_TZ.md 12.3).
class InstallmentPartnerRanking {
  const InstallmentPartnerRanking({
    required this.partnerId,
    required this.partnerName,
    required this.totalGiven,
    required this.remaining,
    required this.overdue,
    this.phone = '',
    this.activePlans = 0,
    this.totalPaid,
    this.lastPaymentAt,
  });

  final int partnerId;
  final String partnerName;
  final Decimal totalGiven;
  final Decimal remaining;
  final Decimal overdue;
  final String phone;
  final int activePlans;
  final Decimal? totalPaid;
  final String? lastPaymentAt;

  factory InstallmentPartnerRanking.fromJson(Map<String, dynamic> json) =>
      InstallmentPartnerRanking(
        partnerId: json['partner_id'] as int? ?? json['id'] as int? ?? 0,
        partnerName:
            json['partner_name'] as String? ?? json['name'] as String? ?? '',
        totalGiven: parseMoney(json['total_given']),
        remaining: parseMoney(json['total_remaining'] ?? json['remaining']),
        overdue: parseMoney(json['overdue_amount'] ?? json['overdue']),
        phone: json['partner_phone'] as String? ?? '',
        activePlans: int.tryParse('${json['active_plans']}') ?? 0,
        totalPaid: parseMoney(json['total_paid']),
        lastPaymentAt: json['last_payment_at'] as String?,
      );
}

/// Muammoli hamkor (MOBILE_APP_TZ.md 12.3).
class RiskyPartner {
  const RiskyPartner({
    required this.partnerId,
    required this.partnerName,
    required this.riskScore,
    required this.riskLevel,
    required this.averageDelayDays,
    this.phone = '',
    this.overdueItems = 0,
    this.overdueAmount,
    this.totalRemaining,
  });

  final int partnerId;
  final String partnerName;
  final num riskScore;
  final String riskLevel;
  final num averageDelayDays;
  final String phone;
  final int overdueItems;
  final Decimal? overdueAmount;
  final Decimal? totalRemaining;

  factory RiskyPartner.fromJson(Map<String, dynamic> json) => RiskyPartner(
    partnerId: json['partner_id'] as int? ?? json['id'] as int? ?? 0,
    partnerName:
        json['partner_name'] as String? ?? json['name'] as String? ?? '',
    riskScore: num.tryParse('${json['risk_score']}') ?? 0,
    riskLevel: json['risk_level'] as String? ?? '',
    averageDelayDays:
        num.tryParse(
          '${json['avg_days_overdue'] ?? json['average_delay_days'] ?? json['avg_delay']}',
        ) ??
        0,
    phone: json['partner_phone'] as String? ?? '',
    overdueItems: int.tryParse('${json['overdue_items']}') ?? 0,
    overdueAmount: parseMoney(json['overdue_amount']),
    totalRemaining: parseMoney(json['total_remaining']),
  );
}

/// Undirish samaradorligi (MOBILE_APP_TZ.md 12.3).
class RecoveryReport {
  const RecoveryReport({
    required this.recoveryRate,
    required this.overdueRate,
    required this.ratingLabel,
    required this.recoveredAmount,
    required this.overdueAmount,
    this.totalGiven,
    this.totalRemaining,
    this.byItems = const {},
  });

  final Decimal? totalGiven;
  final Decimal? totalRemaining;
  final Map<String, int> byItems;
  final num recoveryRate;
  final num overdueRate;
  final String ratingLabel;
  final Decimal recoveredAmount;
  final Decimal overdueAmount;

  factory RecoveryReport.fromJson(Map<String, dynamic> json) => RecoveryReport(
    recoveryRate: num.tryParse('${json['recovery_rate']}') ?? 0,
    overdueRate: num.tryParse('${json['overdue_rate']}') ?? 0,
    ratingLabel: json['rating_label'] as String? ?? '',
    recoveredAmount: parseMoney(
      json['total_collected'] ?? json['recovered'] ?? json['recovered_amount'],
    ),
    overdueAmount: parseMoney(json['overdue'] ?? json['overdue_amount']),
    totalGiven: parseMoney(json['total_given']),
    totalRemaining: parseMoney(json['total_remaining']),
    byItems: (json['by_items'] as Map<String, dynamic>? ?? const {}).map(
      (key, value) => MapEntry(key, int.tryParse('$value') ?? 0),
    ),
  );

  static final zero = RecoveryReport(
    recoveryRate: 0,
    overdueRate: 0,
    ratingLabel: '',
    recoveredAmount: Decimal.zero,
    overdueAmount: Decimal.zero,
  );
}

/// Oylik dinamika (MOBILE_APP_TZ.md 12.3).
class MonthlyInstallmentStat {
  const MonthlyInstallmentStat({
    required this.month,
    required this.amount,
    this.paymentsCount = 0,
  });
  final int paymentsCount;
  final String month;
  final Decimal amount;

  factory MonthlyInstallmentStat.fromJson(Map<String, dynamic> json) =>
      MonthlyInstallmentStat(
        month: '${json['month_label'] ?? json['month'] ?? ''}',
        amount: parseMoney(
          json['total_amount'] ?? json['amount'] ?? json['total'],
        ),
        paymentsCount: int.tryParse('${json['payments_count']}') ?? 0,
      );
}

class InstallmentForecast {
  const InstallmentForecast({
    required this.expectedAmount,
    required this.itemsCount,
    required this.partnersCount,
    required this.dateFrom,
    required this.dateTo,
  });
  final Decimal expectedAmount;
  final int itemsCount;
  final int partnersCount;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  factory InstallmentForecast.fromJson(Map<String, dynamic> json) =>
      InstallmentForecast(
        expectedAmount: parseMoney(json['expected_amount']),
        itemsCount: int.tryParse('${json['items_count']}') ?? 0,
        partnersCount: int.tryParse('${json['partners_count']}') ?? 0,
        dateFrom:
            DateTime.tryParse('${json['date_from']}') ??
            AppDateFormatter.parseFromBackend(json['date_from'] as String?),
        dateTo:
            DateTime.tryParse('${json['date_to']}') ??
            AppDateFormatter.parseFromBackend(json['date_to'] as String?),
      );
}

class InstallmentReportItem {
  const InstallmentReportItem({
    required this.planId,
    required this.partnerName,
    required this.number,
    required this.amount,
    required this.paidAmount,
    required this.remaining,
    required this.dueDate,
    required this.statusLabel,
  });
  final int planId;
  final String partnerName;
  final int number;
  final Decimal amount;
  final Decimal paidAmount;
  final Decimal remaining;
  final DateTime? dueDate;
  final String statusLabel;
  factory InstallmentReportItem.fromJson(Map<String, dynamic> json) =>
      InstallmentReportItem(
        planId: int.tryParse('${json['plan_id']}') ?? 0,
        partnerName: json['partner_name'] as String? ?? '',
        number: int.tryParse('${json['item_number']}') ?? 0,
        amount: parseMoney(json['amount']),
        paidAmount: parseMoney(json['paid_amount']),
        remaining: parseMoney(json['remaining']),
        dueDate:
            DateTime.tryParse('${json['due_date']}') ??
            AppDateFormatter.parseFromBackend(json['due_date'] as String?),
        statusLabel: json['status_label'] as String? ?? '',
      );
}
