import 'package:decimal/decimal.dart';

import '../../../core/utils/money.dart';

/// Bitta valyuta bo'yicha umumiy hisobot (MOBILE_APP_TZ.md 12.1-A).
class PartnerSummaryReport {
  const PartnerSummaryReport({
    required this.debt,
    required this.credit,
    required this.balance,
    required this.partnersCount,
    required this.operationsCount,
    required this.creditorsCount,
    required this.debtorsCount,
  });

  final Decimal debt;
  final Decimal credit;
  final Decimal balance;
  final int partnersCount;
  final int operationsCount;
  final int creditorsCount;
  final int debtorsCount;

  factory PartnerSummaryReport.fromJson(Map<String, dynamic> json) =>
      PartnerSummaryReport(
        debt: parseMoney(json['debt']),
        credit: parseMoney(json['credit']),
        balance: parseMoney(json['balance']),
        partnersCount: int.tryParse('${json['partners_count']}') ?? 0,
        operationsCount:
            int.tryParse(
              '${(json['operations'] as Map<String, dynamic>?)?['count']}',
            ) ??
            0,
        creditorsCount:
            int.tryParse(
              '${(json['xaqdorlar'] as Map<String, dynamic>?)?['count']}',
            ) ??
            0,
        debtorsCount:
            int.tryParse(
              '${(json['qarzdorlar'] as Map<String, dynamic>?)?['count']}',
            ) ??
            0,
      );

  static final empty = PartnerSummaryReport(
    debt: Decimal.zero,
    credit: Decimal.zero,
    balance: Decimal.zero,
    partnersCount: 0,
    operationsCount: 0,
    creditorsCount: 0,
    debtorsCount: 0,
  );
}

/// Hisobot detali — hamkor balans bilan (MOBILE_APP_TZ.md 12.1-A: detail).
class PartnerReportDetailItem {
  const PartnerReportDetailItem({
    required this.partnerId,
    required this.partnerName,
    required this.balance,
  });
  final int partnerId;
  final String partnerName;
  final Decimal balance;

  factory PartnerReportDetailItem.fromJson(Map<String, dynamic> json) =>
      PartnerReportDetailItem(
        partnerId: int.tryParse('${json['partner_id'] ?? json['id']}') ?? 0,
        partnerName:
            json['name'] as String? ?? json['partner_name'] as String? ?? '',
        balance: parseMoney(json['balance']),
      );
}

/// Davr xulosasi (MOBILE_APP_TZ.md 12.1-B).
class PeriodSummary {
  const PeriodSummary({required this.debt, required this.credit});
  final Decimal debt;
  final Decimal credit;

  factory PeriodSummary.fromJson(Map<String, dynamic> json) => PeriodSummary(
    debt: parseMoney(json['debt']),
    credit: parseMoney(json['credit']),
  );

  static final zero = PeriodSummary(debt: Decimal.zero, credit: Decimal.zero);
}

/// Davr operatsiyasi (MOBILE_APP_TZ.md 12.1-B).
class PeriodOperation {
  const PeriodOperation({
    required this.id,
    required this.partnerName,
    required this.summa,
    required this.type,
    this.description,
    this.createdAt,
  });

  final int id;
  final String partnerName;
  final Decimal summa;
  final String type;
  final String? description;
  final String? createdAt;

  factory PeriodOperation.fromJson(Map<String, dynamic> json) =>
      PeriodOperation(
        id: json['id'] as int? ?? 0,
        partnerName: json['partner_name'] as String? ?? '',
        summa: parseMoney(json['summa']),
        type: json['type'] as String? ?? 'debt',
        description: json['description'] as String?,
        createdAt: json['created_at'] as String?,
      );
}

/// Qarz muddatlari xulosasi (MOBILE_APP_TZ.md 12.1-C).
class WarrantyPeriodsSummary {
  const WarrantyPeriodsSummary({
    required this.expired,
    required this.today,
    required this.in3Days,
  });
  final int expired;
  final int today;
  final int in3Days;

  factory WarrantyPeriodsSummary.fromJson(Map<String, dynamic> json) =>
      WarrantyPeriodsSummary(
        expired:
            (json['qarz_expired'] as Map<String, dynamic>?)?['count'] as int? ??
            json['qarz_expired'] as int? ??
            0,
        today:
            (json['qarz_today'] as Map<String, dynamic>?)?['count'] as int? ??
            json['qarz_today'] as int? ??
            0,
        in3Days:
            (json['qarz_3_days'] as Map<String, dynamic>?)?['count'] as int? ??
            json['qarz_3_days'] as int? ??
            0,
      );

  static const zero = WarrantyPeriodsSummary(expired: 0, today: 0, in3Days: 0);
}

/// Xodim xulosasi (MOBILE_APP_TZ.md 12.1-D).
class WorkerReportItem {
  const WorkerReportItem({
    required this.id,
    required this.name,
    this.role,
    required this.debt,
    required this.credit,
    required this.operationsCount,
  });

  final int id;
  final String name;
  final String? role;
  final Decimal debt;
  final Decimal credit;
  final int operationsCount;

  factory WorkerReportItem.fromJson(Map<String, dynamic> json) =>
      WorkerReportItem(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        role: json['role'] as String?,
        debt: parseMoney(json['debt']),
        credit: parseMoney(json['credit']),
        operationsCount: json['operations_count'] as int? ?? 0,
      );
}

/// Hamkor detal hisoboti — V2, UZS va USD valyutalari bilan (GET /reports/partners-v2/partner-details/$id).
class PartnerDetailsResult {
  const PartnerDetailsResult({required this.uzs, required this.usd});

  final PartnerDetailsCurrencyReport uzs;
  final PartnerDetailsCurrencyReport usd;

  factory PartnerDetailsResult.fromJson(Map<String, dynamic> json) =>
      PartnerDetailsResult(
        uzs: PartnerDetailsCurrencyReport.fromJson(
          json['UZS'] as Map<String, dynamic>? ?? const {},
        ),
        usd: PartnerDetailsCurrencyReport.fromJson(
          json['USD'] as Map<String, dynamic>? ?? const {},
        ),
      );
}

/// Har bir valyuta (UZS yoki USD) bo'yicha detal hisobot.
class PartnerDetailsCurrencyReport {
  const PartnerDetailsCurrencyReport({
    required this.balance,
    required this.income,
    required this.expense,
    required this.operationsCount,
    required this.qarzExpired,
    required this.qarzToday,
    required this.qarz3Days,
    required this.monthlyStatistics,
    required this.balanceDynamics,
  });

  final Decimal balance;
  final Decimal income;
  final Decimal expense;
  final int operationsCount;
  final int qarzExpired;
  final int qarzToday;
  final int qarz3Days;
  final List<MonthlyStat> monthlyStatistics;
  final List<BalancePoint> balanceDynamics;

  double get balanceAmount => balance.toDouble();
  double get incomeAmount => income.toDouble();
  double get expenseAmount => expense.toDouble();

  factory PartnerDetailsCurrencyReport.fromJson(Map<String, dynamic> json) {
    int parseCount(dynamic v) {
      if (v is Map) return int.tryParse('${v['count']}') ?? 0;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return PartnerDetailsCurrencyReport(
      balance: parseMoney(json['balance']),
      income: parseMoney(json['income']),
      expense: parseMoney(json['expense']),
      operationsCount: int.tryParse('${json['operations_count']}') ?? 0,
      qarzExpired: parseCount(json['qarz_expired']),
      qarzToday: parseCount(json['qarz_today']),
      qarz3Days: parseCount(json['qarz_3_days']),
      monthlyStatistics: (json['monthly_statistics'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(MonthlyStat.fromJson)
          .toList(),
      balanceDynamics: (json['balance_dynamics'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(BalancePoint.fromJson)
          .toList(),
    );
  }
}

typedef PartnerDetailReport = PartnerDetailsCurrencyReport;

class MonthlyStat {
  const MonthlyStat({
    required this.label,
    required this.income,
    required this.expense,
  });
  final String label;
  final Decimal income;
  final Decimal expense;

  double get incomeDouble => income.toDouble();
  double get expenseDouble => expense.toDouble();

  factory MonthlyStat.fromJson(Map<String, dynamic> json) => MonthlyStat(
    label: json['month'] as String? ?? json['label'] as String? ?? '',
    income: parseMoney(json['income'] ?? json['debt']),
    expense: parseMoney(json['expense'] ?? json['credit']),
  );
}

class BalancePoint {
  const BalancePoint({required this.label, required this.balance});
  final String label;
  final Decimal balance;

  double get balanceDouble => balance.toDouble();

  factory BalancePoint.fromJson(Map<String, dynamic> json) => BalancePoint(
    label: json['date'] as String? ?? json['label'] as String? ?? '',
    balance: parseMoney(json['balance']),
  );
}
