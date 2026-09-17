import 'package:decimal/decimal.dart';

import '../../../core/utils/money.dart';

/// Xarajat turi bo'yicha ulush (MOBILE_APP_TZ.md 12.4).
class CostBreakdownItem {
  const CostBreakdownItem({required this.costTypeName, required this.amount});
  final String costTypeName;
  final Decimal amount;

  factory CostBreakdownItem.fromJson(Map<String, dynamic> json) => CostBreakdownItem(
        costTypeName: json['cost_type_name'] as String? ?? json['name'] as String? ?? '',
        amount: parseMoney(json['amount'] ?? json['summa']),
      );
}

/// Loyiha balansi (MOBILE_APP_TZ.md 12.4).
class ProjectBalanceReport {
  const ProjectBalanceReport({
    required this.incomeUzs,
    required this.incomeUsd,
    required this.costsUzs,
    required this.costsUsd,
    required this.balanceUzs,
    required this.balanceUsd,
    required this.details,
  });

  final Decimal incomeUzs;
  final Decimal incomeUsd;
  final Decimal costsUzs;
  final Decimal costsUsd;
  final Decimal balanceUzs;
  final Decimal balanceUsd;
  final List<CostBreakdownItem> details;

  factory ProjectBalanceReport.fromJson(Map<String, dynamic> json) {
    final costs = json['costs'] as Map<String, dynamic>? ?? const {};
    return ProjectBalanceReport(
      incomeUzs: parseMoney(json['income_uzs']),
      incomeUsd: parseMoney(json['income_usd']),
      costsUzs: parseMoney(costs['total_uzs'] ?? json['costs_uzs']),
      costsUsd: parseMoney(costs['total_usd'] ?? json['costs_usd']),
      balanceUzs: parseMoney(json['balance_uzs']),
      balanceUsd: parseMoney(json['balance_usd']),
      details: ((costs['details'] ?? json['details']) as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(CostBreakdownItem.fromJson)
          .toList(),
    );
  }
}

/// Ishchi xarajati (MOBILE_APP_TZ.md 12.4).
class WorkerCostItem {
  const WorkerCostItem({required this.workerId, required this.workerName, required this.totalAmount});
  final int workerId;
  final String workerName;
  final Decimal totalAmount;

  factory WorkerCostItem.fromJson(Map<String, dynamic> json) => WorkerCostItem(
        workerId: json['worker_id'] as int? ?? json['id'] as int? ?? 0,
        workerName: json['worker_name'] as String? ?? json['name'] as String? ?? '',
        totalAmount: parseMoney(json['total_amount'] ?? json['summa']),
      );
}
