/// Partner operations detail model (GET /reports/partners-v2/summary-details-section-one)
class PartnerOperation {
  final int id;
  final int partnerId;
  final String partnerName;
  final String? partnerPhone;
  final String? description;
  final String type;
  final String? scheduledAmount;
  final String remainingAmount;
  final String? paidAmount;
  final int currencyTypeId;
  final String currencyTypeName;
  final String? dueDate;
  final int? daysOverdue;
  final int? daysLeft;
  final String? status;
  final String createdAt;

  PartnerOperation({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    this.partnerPhone,
    this.description,
    required this.type,
    this.scheduledAmount,
    required this.remainingAmount,
    this.paidAmount,
    required this.currencyTypeId,
    required this.currencyTypeName,
    this.dueDate,
    this.daysOverdue,
    this.daysLeft,
    this.status,
    required this.createdAt,
  });

  bool get isCredit => type.toLowerCase() == 'credit';
  bool get isIncoming => !isCredit;

  factory PartnerOperation.fromJson(Map<String, dynamic> json) {
    return PartnerOperation(
      id: (json['id'] as num?)?.toInt() ?? 0,
      partnerId: (json['partner_id'] as num?)?.toInt() ?? 0,
      partnerName: json['partner_name'] as String? ?? '',
      partnerPhone: json['partner_phone'] as String?,
      description: json['description'] as String?,
      type: json['type'] as String? ?? '',
      scheduledAmount: json['scheduled_amount']?.toString(),
      remainingAmount: json['remaining_amount']?.toString() ?? '0.00',
      paidAmount: json['paid_amount']?.toString(),
      currencyTypeId: (json['currency_type_id'] as num?)?.toInt() ?? 1,
      currencyTypeName: json['currency_type_name'] as String? ?? 'UZS',
      dueDate: json['due_date'] as String?,
      daysOverdue: (json['days_overdue'] as num?)?.toInt(),
      daysLeft: (json['days_left'] as num?)?.toInt(),
      status: json['status'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}
