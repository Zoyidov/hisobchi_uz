import 'package:decimal/decimal.dart';

import '../../../core/utils/money.dart';

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

  factory InstallmentReportSummary.fromJson(Map<String, dynamic> json) => InstallmentReportSummary(
        activeCount: json['active_count'] as int? ?? 0,
        completedCount: json['completed_count'] as int? ?? 0,
        cancelledCount: json['cancelled_count'] as int? ?? 0,
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
  });

  final int partnerId;
  final String partnerName;
  final Decimal totalGiven;
  final Decimal remaining;
  final Decimal overdue;

  factory InstallmentPartnerRanking.fromJson(Map<String, dynamic> json) => InstallmentPartnerRanking(
        partnerId: json['partner_id'] as int? ?? json['id'] as int? ?? 0,
        partnerName: json['partner_name'] as String? ?? json['name'] as String? ?? '',
        totalGiven: parseMoney(json['total_given']),
        remaining: parseMoney(json['remaining']),
        overdue: parseMoney(json['overdue']),
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
  });

  final int partnerId;
  final String partnerName;
  final num riskScore;
  final String riskLevel;
  final num averageDelayDays;

  factory RiskyPartner.fromJson(Map<String, dynamic> json) => RiskyPartner(
        partnerId: json['partner_id'] as int? ?? json['id'] as int? ?? 0,
        partnerName: json['partner_name'] as String? ?? json['name'] as String? ?? '',
        riskScore: json['risk_score'] as num? ?? 0,
        riskLevel: json['risk_level'] as String? ?? '',
        averageDelayDays: json['average_delay_days'] as num? ?? json['avg_delay'] as num? ?? 0,
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
  });

  final num recoveryRate;
  final num overdueRate;
  final String ratingLabel;
  final Decimal recoveredAmount;
  final Decimal overdueAmount;

  factory RecoveryReport.fromJson(Map<String, dynamic> json) => RecoveryReport(
        recoveryRate: json['recovery_rate'] as num? ?? 0,
        overdueRate: json['overdue_rate'] as num? ?? 0,
        ratingLabel: json['rating_label'] as String? ?? '',
        recoveredAmount: parseMoney(json['recovered'] ?? json['recovered_amount']),
        overdueAmount: parseMoney(json['overdue'] ?? json['overdue_amount']),
      );

  static final zero = RecoveryReport(recoveryRate: 0, overdueRate: 0, ratingLabel: '', recoveredAmount: Decimal.zero, overdueAmount: Decimal.zero);
}

/// Oylik dinamika (MOBILE_APP_TZ.md 12.3).
class MonthlyInstallmentStat {
  const MonthlyInstallmentStat({required this.month, required this.amount});
  final String month;
  final Decimal amount;

  factory MonthlyInstallmentStat.fromJson(Map<String, dynamic> json) => MonthlyInstallmentStat(
        month: json['month'] as String? ?? '',
        amount: parseMoney(json['amount'] ?? json['total']),
      );
}
