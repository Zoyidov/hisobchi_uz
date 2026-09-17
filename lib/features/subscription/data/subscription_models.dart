import 'dart:convert';

/// Limit progress (MOBILE_APP_TZ.md 13.2). `-1` — cheksiz.
class UsageLimit {
  const UsageLimit({required this.current, required this.max, required this.extra});
  final int current;
  final int max;
  final Map<String, dynamic> extra;

  bool get isUnlimited => max == -1;
  double get percentage => isUnlimited || max == 0 ? 0 : (current / max).clamp(0, 1).toDouble();
  bool get canAdd => extra['can_add'] as bool? ?? extra['can_send'] as bool? ?? (isUnlimited || current < max);

  factory UsageLimit.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.round();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return UsageLimit(
      current: parseInt(json['current']),
      max: parseInt(json['max']),
      extra: json,
    );
  }

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

    int? parseDaysUntilDue(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      if (val is num) return val.round();
      if (val is String) return int.tryParse(val);
      return null;
    }

    return SubscriptionInfo(
      hasSubscription: true,
      planName: plan['name'] as String?,
      planDisplayName: plan['display_name'] as String?,
      status: sub['status'] as String?,
      statusLabel: sub['status_label'] as String?,
      billingCycle: sub['billing_cycle'] as String?,
      periodStart: period['start'] as String?,
      periodEnd: period['end'] as String?,
      daysUntilDue: parseDaysUntilDue(sub['days_until_due']),
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
    this.description1,
  });

  final bool currentlySubscribed;
  final num amount;
  final String formatted;
  final int? discount;
  final String? description;
  final String? description1;

  factory PriceOption.fromJson(Map<String, dynamic> json) {
    num parsedAmount = 0;
    final rawAmount = json['amount'];
    if (rawAmount is num) {
      parsedAmount = rawAmount;
    } else if (rawAmount is String) {
      parsedAmount = num.tryParse(rawAmount) ?? 0;
    }

    int? parsedDiscount;
    final rawDiscount = json['discount'];
    if (rawDiscount is int) {
      parsedDiscount = rawDiscount;
    } else if (rawDiscount is num) {
      parsedDiscount = rawDiscount.round();
    } else if (rawDiscount is String) {
      parsedDiscount = double.tryParse(rawDiscount)?.round();
    }

    return PriceOption(
      currentlySubscribed: json['currently_subscribed'] as bool? ?? false,
      amount: parsedAmount,
      formatted: json['formatted'] as String? ?? '',
      discount: parsedDiscount,
      description: json['description'] as String?,
      description1: json['description1'] as String?,
    );
  }
}

/// Tarif (MOBILE_APP_TZ.md 13.3).
class PricingPlan {
  const PricingPlan({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
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
  final String? description;
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

  /// `-1` bu cheksiz (unlimited) degani
  bool get isUnlimitedCustomers => maxCustomers == -1;
  bool get isUnlimitedProjects => maxProjects == -1;
  bool get isUnlimitedUsers => maxUsers == -1;
  bool get isUnlimitedSms => smsPerMonth == -1;

  String get customersLabel => isUnlimitedCustomers ? 'Cheksiz' : '$maxCustomers';
  String get projectsLabel => isUnlimitedProjects ? 'Cheksiz' : '$maxProjects';
  String get usersLabel => isUnlimitedUsers ? 'Cheksiz' : '$maxUsers';
  String get smsLabel => isUnlimitedSms ? 'Cheksiz' : '$smsPerMonth';

  factory PricingPlan.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val, int defaultValue) {
      if (val == null) return defaultValue;
      if (val is int) return val;
      if (val is num) return val.round();
      if (val is String) return int.tryParse(val) ?? defaultValue;
      return defaultValue;
    }

    List<String> parseFeatures(dynamic raw) {
      if (raw == null) return const [];
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      if (raw is String) {
        if (raw.trim().isEmpty) return const [];
        try {
          final decoded = jsonDecode(raw);
          return parseFeatures(decoded);
        } catch (_) {
          return [raw];
        }
      }
      if (raw is Map) {
        return raw.entries
            .where((e) => e.value == true || e.value == 1)
            .map((e) => e.key.toString())
            .toList();
      }
      return const [];
    }

    List<String> parseDowngradeWarnings(dynamic raw) {
      if (raw == null) return const [];
      if (raw is List) {
        final list = <String>[];
        for (final item in raw) {
          if (item is String && item.isNotEmpty) {
            list.add(item);
          } else if (item is Map) {
            final msg = item['message']?.toString();
            if (msg != null && msg.isNotEmpty) {
              list.add(msg);
            }
          }
        }
        return list;
      }
      return const [];
    }

    return PricingPlan(
      id: parseInt(json['id'], 0),
      name: json['name'] as String? ?? '',
      displayName: json['display_name'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String?,
      monthly: json['monthly_price'] != null && json['monthly_price'] is Map<String, dynamic>
          ? PriceOption.fromJson(json['monthly_price'] as Map<String, dynamic>)
          : null,
      semiAnnual: json['semi_annual_price'] != null && json['semi_annual_price'] is Map<String, dynamic>
          ? PriceOption.fromJson(json['semi_annual_price'] as Map<String, dynamic>)
          : null,
      annual: json['annual_price'] != null && json['annual_price'] is Map<String, dynamic>
          ? PriceOption.fromJson(json['annual_price'] as Map<String, dynamic>)
          : null,
      maxCustomers: parseInt(json['max_customers'], 0),
      maxProjects: parseInt(json['max_projects'], 0),
      maxUsers: parseInt(json['max_users'], 0),
      smsPerMonth: parseInt(json['sms_per_month'], 0),
      features: parseFeatures(json['features']),
      currentlySubscribed: json['currently_subscribed'] as bool? ?? false,
      canSubscribe: json['can_subscribe'] as bool? ?? true,
      downgradeWarnings: parseDowngradeWarnings(json['downgrade_warnings']),
    );
  }
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

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    int parseOrderId(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.round();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    num parseAmount(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val;
      if (val is String) return num.tryParse(val) ?? 0;
      return 0;
    }

    return PurchaseOrder(
      orderId: parseOrderId(json['order_id']),
      orderNumber: json['order_number']?.toString() ?? '',
      amount: parseAmount(json['amount']),
      paymentUrl: json['payment_url'] as String? ?? '',
    );
  }
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
    this.name,
    required this.displayName,
    this.description,
    required this.price,
    required this.formattedPrice,
    required this.smsCount,
  });

  final int id;
  final String? name;
  final String displayName;
  final String? description;
  final num price;
  final String formattedPrice;
  final int smsCount;

  /// `-1` cheksiz bo'lsa
  bool get isUnlimited => smsCount == -1;
  String get countLabel => isUnlimited ? 'Cheksiz' : '$smsCount';

  factory SmsPackage.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val, int defaultValue) {
      if (val == null) return defaultValue;
      if (val is int) return val;
      if (val is num) return val.round();
      if (val is String) return int.tryParse(val) ?? defaultValue;
      return defaultValue;
    }

    num parseNum(dynamic val, num defaultValue) {
      if (val == null) return defaultValue;
      if (val is num) return val;
      if (val is String) return num.tryParse(val) ?? defaultValue;
      return defaultValue;
    }

    return SmsPackage(
      id: parseInt(json['id'], 0),
      name: json['name'] as String?,
      displayName: json['display_name'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String?,
      price: parseNum(json['price'], 0),
      formattedPrice: json['formatted_price'] as String? ?? '${json['price'] ?? 0} UZS',
      smsCount: parseInt(json['sms_count'], 0),
    );
  }
}
