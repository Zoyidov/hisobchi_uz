/// Limit progress (MOBILE_APP_TZ.md 13.2). `-1` — cheksiz.
class UsageLimit {
  const UsageLimit({required this.current, required this.max, required this.extra});
  final int current;
  final int max;
  final Map<String, dynamic> extra;

  bool get isUnlimited => max == -1;
  double get percentage => isUnlimited || max == 0 ? 0 : (current / max).clamp(0, 1).toDouble();
  bool get canAdd => extra['can_add'] as bool? ?? extra['can_send'] as bool? ?? (isUnlimited || current < max);

  factory UsageLimit.fromJson(Map<String, dynamic> json) => UsageLimit(
        current: json['current'] as int? ?? 0,
        max: json['max'] as int? ?? 0,
        extra: json,
      );

  static const empty = UsageLimit(current: 0, max: 0, extra: {});
}

class SubscriptionUsage {
  const SubscriptionUsage({required this.customers, required this.projects, required this.users, required this.sms});
  final UsageLimit customers;
  final UsageLimit projects;
  final UsageLimit users;
  final UsageLimit sms;

  factory SubscriptionUsage.fromJson(Map<String, dynamic> json) => SubscriptionUsage(
        customers: UsageLimit.fromJson(json['customers'] as Map<String, dynamic>? ?? const {}),
        projects: UsageLimit.fromJson(json['projects'] as Map<String, dynamic>? ?? const {}),
        users: UsageLimit.fromJson(json['users'] as Map<String, dynamic>? ?? const {}),
        sms: UsageLimit.fromJson(json['sms'] as Map<String, dynamic>? ?? const {}),
      );

  static const empty = SubscriptionUsage(customers: UsageLimit.empty, projects: UsageLimit.empty, users: UsageLimit.empty, sms: UsageLimit.empty);
}

/// Joriy obuna (MOBILE_APP_TZ.md 13.2).
class SubscriptionInfo {
  const SubscriptionInfo({
    required this.hasSubscription,
    this.planName,
    this.planDisplayName,
    this.status,
    this.statusLabel,
    this.billingCycle,
    this.periodStart,
    this.periodEnd,
    this.daysUntilDue,
    this.isOverdue = false,
    required this.usage,
  });

  final bool hasSubscription;
  final String? planName;
  final String? planDisplayName;
  final String? status;
  final String? statusLabel;
  final String? billingCycle;
  final String? periodStart;
  final String? periodEnd;
  final int? daysUntilDue;
  final bool isOverdue;
  final SubscriptionUsage usage;

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    if (json['has_subscription'] != true || json['subscription'] == null) {
      return const SubscriptionInfo(hasSubscription: false, usage: SubscriptionUsage.empty);
    }
    final sub = json['subscription'] as Map<String, dynamic>;
    final plan = sub['plan'] as Map<String, dynamic>? ?? const {};
    final period = sub['current_period'] as Map<String, dynamic>? ?? const {};
    return SubscriptionInfo(
      hasSubscription: true,
      planName: plan['name'] as String?,
      planDisplayName: plan['display_name'] as String?,
      status: sub['status'] as String?,
      statusLabel: sub['status_label'] as String?,
      billingCycle: sub['billing_cycle'] as String?,
      periodStart: period['start'] as String?,
      periodEnd: period['end'] as String?,
      daysUntilDue: sub['days_until_due'] as int?,
      isOverdue: sub['is_overdue'] as bool? ?? false,
      usage: SubscriptionUsage.fromJson(sub['usage'] as Map<String, dynamic>? ?? const {}),
    );
  }
}

/// Bitta narx varianti (MOBILE_APP_TZ.md 13.3).
class PriceOption {
  const PriceOption({
    required this.currentlySubscribed,
    required this.amount,
    required this.formatted,
    this.discount,
    this.description,
  });

  final bool currentlySubscribed;
  final num amount;
  final String formatted;
  final int? discount;
  final String? description;

  factory PriceOption.fromJson(Map<String, dynamic> json) => PriceOption(
        currentlySubscribed: json['currently_subscribed'] as bool? ?? false,
        amount: json['amount'] as num? ?? 0,
        formatted: json['formatted'] as String? ?? '',
        discount: json['discount'] as int?,
        description: json['description'] as String?,
      );
}

/// Tarif (MOBILE_APP_TZ.md 13.3).
class PricingPlan {
  const PricingPlan({
    required this.id,
    required this.name,
    required this.displayName,
    this.monthly,
    this.semiAnnual,
    this.annual,
    required this.maxCustomers,
    required this.maxProjects,
    required this.maxUsers,
    required this.smsPerMonth,
    required this.features,
    required this.currentlySubscribed,
    required this.canSubscribe,
    required this.downgradeWarnings,
  });

  final int id;
  final String name;
  final String displayName;
  final PriceOption? monthly;
  final PriceOption? semiAnnual;
  final PriceOption? annual;
  final int maxCustomers;
  final int maxProjects;
  final int maxUsers;
  final int smsPerMonth;
  final List<String> features;
  final bool currentlySubscribed;
  final bool canSubscribe;
  final List<String> downgradeWarnings;

  factory PricingPlan.fromJson(Map<String, dynamic> json) => PricingPlan(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        displayName: json['display_name'] as String? ?? json['name'] as String? ?? '',
        monthly: json['monthly_price'] != null ? PriceOption.fromJson(json['monthly_price'] as Map<String, dynamic>) : null,
        semiAnnual: json['semi_annual_price'] != null ? PriceOption.fromJson(json['semi_annual_price'] as Map<String, dynamic>) : null,
        annual: json['annual_price'] != null ? PriceOption.fromJson(json['annual_price'] as Map<String, dynamic>) : null,
        maxCustomers: json['max_customers'] as int? ?? 0,
        maxProjects: json['max_projects'] as int? ?? 0,
        maxUsers: json['max_users'] as int? ?? 0,
        smsPerMonth: json['sms_per_month'] as int? ?? 0,
        features: (json['features'] as List? ?? const []).cast<String>(),
        currentlySubscribed: json['currently_subscribed'] as bool? ?? false,
        canSubscribe: json['can_subscribe'] as bool? ?? true,
        downgradeWarnings: (json['downgrade_warnings'] as List? ?? const []).cast<String>(),
      );
}

enum BillingCycle { monthly, semiAnnual, annual }

extension BillingCycleX on BillingCycle {
  String get apiValue => switch (this) {
        BillingCycle.monthly => 'MONTHLY',
        BillingCycle.semiAnnual => 'SEMI_ANNUAL',
        BillingCycle.annual => 'ANNUAL',
      };

  String get label => switch (this) {
        BillingCycle.monthly => 'Oylik',
        BillingCycle.semiAnnual => '6 oylik',
        BillingCycle.annual => 'Yillik',
      };
}

class PurchaseOrder {
  const PurchaseOrder({required this.orderId, required this.orderNumber, required this.amount, required this.paymentUrl});
  final int orderId;
  final String orderNumber;
  final num amount;
  final String paymentUrl;

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) => PurchaseOrder(
        orderId: json['order_id'] as int? ?? 0,
        orderNumber: json['order_number'] as String? ?? '',
        amount: json['amount'] as num? ?? 0,
        paymentUrl: json['payment_url'] as String? ?? '',
      );
}

enum OrderStatus { paid, pending, failed }

extension OrderStatusX on OrderStatus {
  static OrderStatus fromApi(String? value) => switch (value) {
        'PAID' => OrderStatus.paid,
        'FAILED' => OrderStatus.failed,
        _ => OrderStatus.pending,
      };
}

/// SMS paketi (MOBILE_APP_TZ.md 13.5).
class SmsPackage {
  const SmsPackage({
    required this.id,
    required this.displayName,
    this.description,
    required this.price,
    required this.formattedPrice,
    required this.smsCount,
  });

  final int id;
  final String displayName;
  final String? description;
  final num price;
  final String formattedPrice;
  final int smsCount;

  factory SmsPackage.fromJson(Map<String, dynamic> json) => SmsPackage(
        id: json['id'] as int,
        displayName: json['display_name'] as String? ?? json['name'] as String? ?? '',
        description: json['description'] as String?,
        price: json['price'] as num? ?? 0,
        formattedPrice: json['formatted_price'] as String? ?? '',
        smsCount: json['sms_count'] as int? ?? 0,
      );
}
