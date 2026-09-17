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

  factory InstallmentPlan.fromJson(Map<String, dynamic> rawJson) {
    var json = rawJson;
    if (json['plan'] is Map<String, dynamic>) {
      json = json['plan'] as Map<String, dynamic>;
    } else if (json['data'] is Map<String, dynamic>) {
      json = json['data'] as Map<String, dynamic>;
    }
    final idVal = json['id'];
    final id = idVal is int ? idVal : (int.tryParse('$idVal') ?? 0);
    final partnerVal = json['partner_id'];
    final partnerId = partnerVal is int ? partnerVal : (int.tryParse('$partnerVal') ?? 0);
    final currVal = json['currency_type_id'];
    final currencyTypeId = currVal is int ? currVal : (int.tryParse('$currVal') ?? 1);
    final advanceVal = json['has_advance'];
    final hasAdvance = advanceVal == true || advanceVal == 1 || advanceVal == '1';

    return InstallmentPlan(
      id: id,
      partnerId: partnerId,
      partnerName: json['partner_name']?.toString() ?? '',
      partnerPhone: json['partner_phone']?.toString() ?? '',
      currencyTypeId: currencyTypeId,
      currencyTypeName: json['currency_type_name']?.toString() ?? (currencyTypeId == 2 ? 'USD' : 'UZS'),
      totalAmount: parseMoney(json['total_amount']),
      paidAmount: parseMoney(json['paid_amount']),
      remaining: parseMoney(json['remaining']),
      scheduleType: InstallmentScheduleTypeX.fromApi(json['schedule_type']?.toString()),
      hasAdvance: hasAdvance,
      advanceAmount: json['advance_amount'] != null ? parseMoney(json['advance_amount']) : null,
      startDate: AppDateFormatter.parseFromBackend(json['start_date']?.toString()),
      note: json['note']?.toString(),
      status: InstallmentPlanStatusX.fromApi(json['status']?.toString()),
      statusLabel: json['status_label']?.toString() ?? '',
      itemsCount: (json['items_count'] as num?)?.toInt() ?? (json['items'] as List?)?.length ?? 0,
      createdAt: AppDateFormatter.parseFromBackend(json['created_at']?.toString()),
      items: (json['items'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(InstallmentItem.fromJson)
          .toList(),
    );
  }
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

  factory InstallmentItem.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'];
    final id = idVal is int ? idVal : (int.tryParse('$idVal') ?? 0);
    final numVal = json['item_number'];
    final itemNumber = numVal is int ? numVal : (int.tryParse('$numVal') ?? 0);
    final advanceVal = json['is_advance'];
    final isAdvance = advanceVal == true || advanceVal == 1 || advanceVal == '1';

    return InstallmentItem(
      id: id,
      itemNumber: itemNumber,
      isAdvance: isAdvance,
      amount: parseMoney(json['amount']),
      paidAmount: parseMoney(json['paid_amount']),
      remaining: parseMoney(json['remaining']),
      dueDate: AppDateFormatter.parseFromBackend(json['due_date']?.toString()),
      status: InstallmentItemStatusX.fromApi(json['status']?.toString()),
      statusLabel: json['status_label']?.toString() ?? '',
    );
  }
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

  factory InstallmentPaymentRecord.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'];
    final id = idVal is int ? idVal : (int.tryParse('$idVal') ?? 0);
    final cancelledVal = json['is_cancelled'];
    final isCancelled = cancelledVal == true || cancelledVal == 1 || cancelledVal == '1';

    return InstallmentPaymentRecord(
      id: id,
      receivedByName: json['received_by_name']?.toString() ?? '',
      amount: parseMoney(json['amount']),
      planPaidBefore: parseMoney(json['plan_paid_before']),
      planPaidAfter: parseMoney(json['plan_paid_after']),
      note: json['note']?.toString(),
      isCancelled: isCancelled,
      cancelledByName: json['cancelled_by_name']?.toString(),
      cancelledAt: AppDateFormatter.parseFromBackend(json['cancelled_at']?.toString()),
      createdAt: AppDateFormatter.parseFromBackend(json['created_at']?.toString()),
    );
  }
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
