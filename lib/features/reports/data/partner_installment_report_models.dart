import 'package:flutter/material.dart';

/// Full Partner Installment Report Model (wraps GET /reports/installments/partner/$partnerId)
class PartnerInstallmentReportModel {
  final int partnerId;
  final String partnerName;
  final String partnerPhone;
  final List<PartnerInstallmentStatModel> stats;
  final List<PartnerInstallmentPlanModel> plans;
  final List<PartnerInstallmentPaymentModel> payments;
  final List<PartnerInstallmentItemModel> items;
  final List<PartnerMonthlyDynamicModel> monthlyDynamics;

  const PartnerInstallmentReportModel({
    required this.partnerId,
    required this.partnerName,
    required this.partnerPhone,
    required this.stats,
    required this.plans,
    required this.payments,
    required this.items,
    required this.monthlyDynamics,
  });

  factory PartnerInstallmentReportModel.fromJson(Map<String, dynamic> json) {
    return PartnerInstallmentReportModel(
      partnerId: (json['partner_id'] as num?)?.toInt() ?? 0,
      partnerName: json['partner_name'] as String? ?? '',
      partnerPhone: json['partner_phone'] as String? ?? '',
      stats: (json['stats'] as List? ?? [])
          .map((e) => PartnerInstallmentStatModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      plans: (json['plans'] as List? ?? [])
          .map((e) => PartnerInstallmentPlanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      payments: (json['payments'] as List? ?? [])
          .map((e) => PartnerInstallmentPaymentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      items: (json['items'] as List? ?? [])
          .map((e) => PartnerInstallmentItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      monthlyDynamics: (json['monthly_dynamics'] as List? ?? [])
          .map((e) => PartnerMonthlyDynamicModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static const empty = PartnerInstallmentReportModel(
    partnerId: 0,
    partnerName: '',
    partnerPhone: '',
    stats: [],
    plans: [],
    payments: [],
    items: [],
    monthlyDynamics: [],
  );
}

/// Installment stats per currency
class PartnerInstallmentStatModel {
  final int currencyTypeId;
  final String currencyTypeName;
  final int activePlans;
  final int completedPlans;
  final int cancelledPlans;
  final String totalGiven;
  final String totalPaid;
  final String totalRemaining;
  final String overdueAmount;

  const PartnerInstallmentStatModel({
    required this.currencyTypeId,
    required this.currencyTypeName,
    required this.activePlans,
    required this.completedPlans,
    required this.cancelledPlans,
    required this.totalGiven,
    required this.totalPaid,
    required this.totalRemaining,
    required this.overdueAmount,
  });

  bool get hasOverdue => (double.tryParse(overdueAmount) ?? 0) > 0;
  int get totalPlans => activePlans + completedPlans + cancelledPlans;

  factory PartnerInstallmentStatModel.fromJson(Map<String, dynamic> json) {
    return PartnerInstallmentStatModel(
      currencyTypeId: (json['currency_type_id'] as num?)?.toInt() ?? 1,
      currencyTypeName: json['currency_type_name'] as String? ?? 'UZS',
      activePlans: (json['active_plans'] as num?)?.toInt() ?? 0,
      completedPlans: (json['completed_plans'] as num?)?.toInt() ?? 0,
      cancelledPlans: (json['cancelled_plans'] as num?)?.toInt() ?? 0,
      totalGiven: json['total_given']?.toString() ?? '0',
      totalPaid: json['total_paid']?.toString() ?? '0',
      totalRemaining: json['total_remaining']?.toString() ?? '0',
      overdueAmount: json['overdue_amount']?.toString() ?? '0',
    );
  }
}

/// Installment plan
class PartnerInstallmentPlanModel {
  final int id;
  final String status;
  final String statusLabel;
  final int currencyTypeId;
  final String currencyTypeName;
  final String totalAmount;
  final String paidAmount;
  final String totalRemaining;
  final String scheduleType;
  final bool hasAdvance;
  final String? advanceAmount;
  final String startDate;
  final String? note;
  final int itemsCount;
  final int overdueItemsCount;
  final int nearItemsCount;
  final String createdAt;

  const PartnerInstallmentPlanModel({
    required this.id,
    required this.status,
    required this.statusLabel,
    required this.currencyTypeId,
    required this.currencyTypeName,
    required this.totalAmount,
    required this.paidAmount,
    required this.totalRemaining,
    required this.scheduleType,
    required this.hasAdvance,
    this.advanceAmount,
    required this.startDate,
    this.note,
    required this.itemsCount,
    required this.overdueItemsCount,
    required this.nearItemsCount,
    required this.createdAt,
  });

  double get totalAmountDouble => double.tryParse(totalAmount) ?? 0;
  double get paidAmountDouble => double.tryParse(paidAmount) ?? 0;
  double get remainingDouble => double.tryParse(totalRemaining) ?? 0;
  double get progress =>
      totalAmountDouble > 0 ? (paidAmountDouble / totalAmountDouble).clamp(0.0, 1.0) : 0.0;

  Color get statusColor {
    switch (status) {
      case 'active':
        return const Color(0xFF6366F1);
      case 'completed':
        return const Color(0xFF22C55E);
      case 'cancelled':
        return const Color(0xFF94A3B8);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color get statusBgColor => statusColor.withValues(alpha: 0.12);

  factory PartnerInstallmentPlanModel.fromJson(Map<String, dynamic> json) {
    return PartnerInstallmentPlanModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'active',
      statusLabel: json['status_label'] as String? ?? '',
      currencyTypeId: (json['currency_type_id'] as num?)?.toInt() ?? 1,
      currencyTypeName: json['currency_type_name'] as String? ?? 'UZS',
      totalAmount: json['total_amount']?.toString() ?? '0',
      paidAmount: json['paid_amount']?.toString() ?? '0',
      totalRemaining: json['total_remaining']?.toString() ?? '0',
      scheduleType: json['schedule_type'] as String? ?? 'equal',
      hasAdvance: json['has_advance'] as bool? ?? false,
      advanceAmount: json['advance_amount']?.toString(),
      startDate: json['start_date'] as String? ?? '',
      note: json['note'] as String?,
      itemsCount: (json['items_count'] as num?)?.toInt() ?? 0,
      overdueItemsCount: (json['overdue_items_count'] as num?)?.toInt() ?? 0,
      nearItemsCount: (json['near_items_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

/// Installment payment history record
class PartnerInstallmentPaymentModel {
  final int id;
  final int planId;
  final String amount;
  final String planPaidBefore;
  final String planPaidAfter;
  final String? note;
  final bool isCancelled;
  final String? cancelledAt;
  final String createdAt;

  const PartnerInstallmentPaymentModel({
    required this.id,
    required this.planId,
    required this.amount,
    required this.planPaidBefore,
    required this.planPaidAfter,
    this.note,
    required this.isCancelled,
    this.cancelledAt,
    required this.createdAt,
  });

  double get amountDouble => double.tryParse(amount) ?? 0;

  factory PartnerInstallmentPaymentModel.fromJson(Map<String, dynamic> json) {
    return PartnerInstallmentPaymentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      planId: (json['plan_id'] as num?)?.toInt() ?? 0,
      amount: json['amount']?.toString() ?? '0',
      planPaidBefore: json['plan_paid_before']?.toString() ?? '0',
      planPaidAfter: json['plan_paid_after']?.toString() ?? '0',
      note: json['note'] as String?,
      isCancelled: json['is_cancelled'] as bool? ?? false,
      cancelledAt: json['cancelled_at'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

/// Installment scheduled item
class PartnerInstallmentItemModel {
  final int id;
  final int planId;
  final int itemNumber;
  final bool isAdvance;
  final String amount;
  final String paidAmount;
  final String remaining;
  final String dueDate;
  final String? paidAt;
  final String status;
  final String statusLabel;

  const PartnerInstallmentItemModel({
    required this.id,
    required this.planId,
    required this.itemNumber,
    required this.isAdvance,
    required this.amount,
    required this.paidAmount,
    required this.remaining,
    required this.dueDate,
    this.paidAt,
    required this.status,
    required this.statusLabel,
  });

  double get amountDouble => double.tryParse(amount) ?? 0;
  double get paidDouble => double.tryParse(paidAmount) ?? 0;
  double get remainingDouble => double.tryParse(remaining) ?? 0;
  double get progress =>
      amountDouble > 0 ? (paidDouble / amountDouble).clamp(0.0, 1.0) : 0.0;

  Color get statusColor {
    switch (status) {
      case 'paid':
        return const Color(0xFF22C55E);
      case 'partial':
        return const Color(0xFF3B82F6);
      case 'near':
        return const Color(0xFFF59E0B);
      case 'overdue':
        return const Color(0xFFEF4444);
      case 'pending':
      default:
        return const Color(0xFF94A3B8);
    }
  }

  Color get statusBgColor => statusColor.withValues(alpha: 0.12);

  factory PartnerInstallmentItemModel.fromJson(Map<String, dynamic> json) {
    return PartnerInstallmentItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      planId: (json['plan_id'] as num?)?.toInt() ?? 0,
      itemNumber: (json['item_number'] as num?)?.toInt() ?? 0,
      isAdvance: json['is_advance'] as bool? ?? false,
      amount: json['amount']?.toString() ?? '0',
      paidAmount: json['paid_amount']?.toString() ?? '0',
      remaining: json['remaining']?.toString() ?? '0',
      dueDate: json['due_date'] as String? ?? '',
      paidAt: json['paid_at'] as String?,
      status: json['status'] as String? ?? 'pending',
      statusLabel: json['status_label'] as String? ?? '',
    );
  }
}

/// Installment monthly dynamics
class PartnerMonthlyDynamicModel {
  final int month;
  final String monthLabel;
  final String planned;
  final String collected;

  const PartnerMonthlyDynamicModel({
    required this.month,
    required this.monthLabel,
    required this.planned,
    required this.collected,
  });

  double get plannedAmount => double.tryParse(planned) ?? 0;
  double get collectedAmount => double.tryParse(collected) ?? 0;
  double get maxValue =>
      plannedAmount > collectedAmount ? plannedAmount : collectedAmount;
  bool get hasData => plannedAmount > 0 || collectedAmount > 0;

  static const _uzLabels = [
    '',
    'Yan',
    'Fev',
    'Mar',
    'Apr',
    'May',
    'Iyun',
    'Iyul',
    'Avg',
    'Sen',
    'Okt',
    'Noy',
    'Dek',
  ];

  String get uzLabel =>
      month >= 1 && month <= 12 ? _uzLabels[month] : monthLabel;

  factory PartnerMonthlyDynamicModel.fromJson(Map<String, dynamic> json) {
    return PartnerMonthlyDynamicModel(
      month: (json['month'] as num?)?.toInt() ?? 0,
      monthLabel: json['month_label'] as String? ?? '',
      planned: json['planned']?.toString() ?? '0',
      collected: json['collected']?.toString() ?? '0',
    );
  }
}
