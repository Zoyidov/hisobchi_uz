import 'package:decimal/decimal.dart';

import '../../../core/utils/formatters/date_formatter.dart';
import '../../../core/utils/money.dart';

enum InstallmentScheduleType { equal, custom }

extension InstallmentScheduleTypeX on InstallmentScheduleType {
  String get apiValue => this == InstallmentScheduleType.equal ? 'equal' : 'custom';

  static InstallmentScheduleType fromApi(String? value) =>
      value == 'custom' ? InstallmentScheduleType.custom : InstallmentScheduleType.equal;
}

enum InstallmentPlanStatus { active, completed, cancelled }

extension InstallmentPlanStatusX on InstallmentPlanStatus {
  static InstallmentPlanStatus fromApi(String? value) => switch (value) {
        'completed' => InstallmentPlanStatus.completed,
        'cancelled' => InstallmentPlanStatus.cancelled,
        _ => InstallmentPlanStatus.active,
      };

  String get apiValue => switch (this) {
        InstallmentPlanStatus.active => 'active',
        InstallmentPlanStatus.completed => 'completed',
        InstallmentPlanStatus.cancelled => 'cancelled',
      };
}

/// Bo'lib to'lash rejasi (MOBILE_APP_TZ.md 9.3).
class InstallmentPlan {
  const InstallmentPlan({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    required this.partnerPhone,
    required this.currencyTypeId,
    required this.currencyTypeName,
    required this.totalAmount,
    required this.paidAmount,
    required this.remaining,
    required this.scheduleType,
    required this.hasAdvance,
    this.advanceAmount,
    this.startDate,
    this.note,
    required this.status,
    required this.statusLabel,
    required this.itemsCount,
    this.createdAt,
    this.items = const [],
  });

  final int id;
  final int partnerId;
  final String partnerName;
  final String partnerPhone;
  final int currencyTypeId;
  final String currencyTypeName;
  final Decimal totalAmount;
  final Decimal paidAmount;
  final Decimal remaining;
  final InstallmentScheduleType scheduleType;
  final bool hasAdvance;
  final Decimal? advanceAmount;
  final DateTime? startDate;
  final String? note;
  final InstallmentPlanStatus status;
  final String statusLabel;
  final int itemsCount;
  final DateTime? createdAt;
  final List<InstallmentItem> items;

  double get progress => totalAmount == Decimal.zero ? 0 : (paidAmount / totalAmount).toDouble();

  factory InstallmentPlan.fromJson(Map<String, dynamic> json) => InstallmentPlan(
        id: json['id'] as int,
        partnerId: json['partner_id'] as int? ?? 0,
        partnerName: json['partner_name'] as String? ?? '',
        partnerPhone: json['partner_phone'] as String? ?? '',
        currencyTypeId: json['currency_type_id'] as int? ?? 1,
        currencyTypeName: json['currency_type_name'] as String? ?? 'UZS',
        totalAmount: parseMoney(json['total_amount']),
        paidAmount: parseMoney(json['paid_amount']),
        remaining: parseMoney(json['remaining']),
        scheduleType: InstallmentScheduleTypeX.fromApi(json['schedule_type'] as String?),
        hasAdvance: json['has_advance'] as bool? ?? false,
        advanceAmount: json['advance_amount'] != null ? parseMoney(json['advance_amount']) : null,
        startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date'] as String) : null,
        note: json['note'] as String?,
        status: InstallmentPlanStatusX.fromApi(json['status'] as String?),
        statusLabel: json['status_label'] as String? ?? '',
        itemsCount: json['items_count'] as int? ?? (json['items'] as List?)?.length ?? 0,
        createdAt: AppDateFormatter.parseFromBackend(json['created_at'] as String?),
        items: (json['items'] as List? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(InstallmentItem.fromJson)
            .toList(),
      );
}

enum InstallmentItemStatus { pending, near, overdue, partial, paid }

extension InstallmentItemStatusX on InstallmentItemStatus {
  static InstallmentItemStatus fromApi(String? value) => switch (value) {
        'near' => InstallmentItemStatus.near,
        'overdue' => InstallmentItemStatus.overdue,
        'partial' => InstallmentItemStatus.partial,
        'paid' => InstallmentItemStatus.paid,
        _ => InstallmentItemStatus.pending,
      };
}

/// Reja qismi (MOBILE_APP_TZ.md 9.2, 9.5).
class InstallmentItem {
  const InstallmentItem({
    required this.id,
    required this.itemNumber,
    required this.isAdvance,
    required this.amount,
    required this.paidAmount,
    required this.remaining,
    required this.dueDate,
    required this.status,
    required this.statusLabel,
  });

  final int id;
  final int itemNumber;
  final bool isAdvance;
  final Decimal amount;
  final Decimal paidAmount;
  final Decimal remaining;
  final DateTime? dueDate;
  final InstallmentItemStatus status;
  final String statusLabel;

  factory InstallmentItem.fromJson(Map<String, dynamic> json) => InstallmentItem(
        id: json['id'] as int? ?? 0,
        itemNumber: json['item_number'] as int? ?? 0,
        isAdvance: json['is_advance'] as bool? ?? false,
        amount: parseMoney(json['amount']),
        paidAmount: parseMoney(json['paid_amount']),
        remaining: parseMoney(json['remaining']),
        dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date'] as String) : null,
        status: InstallmentItemStatusX.fromApi(json['status'] as String?),
        statusLabel: json['status_label'] as String? ?? '',
      );
}

/// To'lov tarixi yozuvi (MOBILE_APP_TZ.md 9.7).
class InstallmentPaymentRecord {
  const InstallmentPaymentRecord({
    required this.id,
    required this.receivedByName,
    required this.amount,
    required this.planPaidBefore,
    required this.planPaidAfter,
    this.note,
    required this.isCancelled,
    this.cancelledByName,
    this.cancelledAt,
    this.createdAt,
  });

  final int id;
  final String receivedByName;
  final Decimal amount;
  final Decimal planPaidBefore;
  final Decimal planPaidAfter;
  final String? note;
  final bool isCancelled;
  final String? cancelledByName;
  final DateTime? cancelledAt;
  final DateTime? createdAt;

  factory InstallmentPaymentRecord.fromJson(Map<String, dynamic> json) => InstallmentPaymentRecord(
        id: json['id'] as int,
        receivedByName: json['received_by_name'] as String? ?? '',
        amount: parseMoney(json['amount']),
        planPaidBefore: parseMoney(json['plan_paid_before']),
        planPaidAfter: parseMoney(json['plan_paid_after']),
        note: json['note'] as String?,
        isCancelled: json['is_cancelled'] as bool? ?? false,
        cancelledByName: json['cancelled_by_name'] as String?,
        cancelledAt: AppDateFormatter.parseFromBackend(json['cancelled_at'] as String?),
        createdAt: AppDateFormatter.parseFromBackend(json['created_at'] as String?),
      );
}

/// Client-side preview elementi — server yaratadigan grafikning aynan o'zi
/// (MOBILE_APP_TZ.md 9.4: "equal turida grafik client-side ham hisoblanadi").
class InstallmentPreviewItem {
  const InstallmentPreviewItem({
    required this.itemNumber,
    required this.amount,
    required this.dueDate,
    required this.isAdvance,
    this.note,
  });

  final int itemNumber;
  final Decimal amount;
  final DateTime dueDate;
  final bool isAdvance;
  final String? note;
}
