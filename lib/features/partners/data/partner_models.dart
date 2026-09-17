import 'package:decimal/decimal.dart';

import '../../../core/utils/formatters/date_formatter.dart';
import '../../../core/utils/money.dart';

/// Hamkorlar ro'yxati elementi (MOBILE_APP_TZ.md 8.2).
class Partner {
  const Partner({
    required this.id,
    required this.name,
    required this.phone,
    this.additionalPhone,
    required this.mainCurrencyTypeId,
    required this.mainCurrencyTypeName,
    required this.balanceUzs,
    required this.balanceUsd,
    required this.installmentRemainingUzs,
    required this.installmentRemainingUsd,
    required this.sendOnKirim,
    required this.sendOnChiqim,
    this.createdAt,
    this.deletedAt,
  });

  final int id;
  final String name;
  final String phone;
  final String? additionalPhone;
  final int mainCurrencyTypeId;
  final String mainCurrencyTypeName;
  final Decimal balanceUzs;
  final Decimal balanceUsd;
  final Decimal installmentRemainingUzs;
  final Decimal installmentRemainingUsd;
  final bool sendOnKirim;
  final bool sendOnChiqim;
  final DateTime? createdAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  /// Xaqdor (balans > 0) / Qarzdor (< 0) / Yopiq (= 0) — asosiy valyuta bo'yicha.
  PartnerBalanceStatus get status {
    final primary = mainCurrencyTypeId == 2 ? balanceUsd : balanceUzs;
    if (primary > Decimal.zero) return PartnerBalanceStatus.creditor;
    if (primary < Decimal.zero) return PartnerBalanceStatus.debtor;
    return PartnerBalanceStatus.closed;
  }

  static Decimal _currencyValue(Map<String, dynamic>? map, String code) {
    if (map == null) return Decimal.zero;
    return parseMoney(map[code]);
  }

  factory Partner.fromJson(Map<String, dynamic> rawJson) {
    var json = rawJson;
    if (json['partner'] is Map<String, dynamic>) {
      json = json['partner'] as Map<String, dynamic>;
    } else if (json['data'] is Map<String, dynamic>) {
      json = json['data'] as Map<String, dynamic>;
    }

    final idVal = json['id'];
    final id = idVal is int ? idVal : (int.tryParse('$idVal') ?? 0);

    final mainCurrencyVal = json['main_currency_type_id'];
    final mainCurrencyTypeId = mainCurrencyVal is int ? mainCurrencyVal : (int.tryParse('$mainCurrencyVal') ?? 1);

    final sendOnKirimVal = json['send_on_kirim'];
    final sendOnKirim = sendOnKirimVal == null ? true : (sendOnKirimVal == true || sendOnKirimVal == 1 || sendOnKirimVal == '1');

    final sendOnChiqimVal = json['send_on_chiqim'];
    final sendOnChiqim = sendOnChiqimVal == null ? true : (sendOnChiqimVal == true || sendOnChiqimVal == 1 || sendOnChiqimVal == '1');

    final balance = json['balance'] is Map<String, dynamic> ? json['balance'] as Map<String, dynamic> : null;
    final installment = json['installment_remaining'] is Map<String, dynamic> ? json['installment_remaining'] as Map<String, dynamic> : null;

    return Partner(
      id: id,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      additionalPhone: json['additional_phone']?.toString(),
      mainCurrencyTypeId: mainCurrencyTypeId,
      mainCurrencyTypeName: json['main_currency_type_name']?.toString() ?? (mainCurrencyTypeId == 2 ? 'USD' : 'UZS'),
      balanceUzs: _currencyValue(balance, 'UZS'),
      balanceUsd: _currencyValue(balance, 'USD'),
      installmentRemainingUzs: _currencyValue(installment, 'UZS'),
      installmentRemainingUsd: _currencyValue(installment, 'USD'),
      sendOnKirim: sendOnKirim,
      sendOnChiqim: sendOnChiqim,
      createdAt: AppDateFormatter.parseFromBackend(json['created_at']?.toString()),
      deletedAt: AppDateFormatter.parseFromBackend(json['deleted_at']?.toString()),
    );
  }
}

enum PartnerBalanceStatus { creditor, debtor, closed }

enum PartnerStatusFilter { all, creditor, debtor, overdueDebtor }

extension PartnerStatusFilterX on PartnerStatusFilter {
  String? get apiValue => switch (this) {
        PartnerStatusFilter.all => null,
        PartnerStatusFilter.creditor => 'xaqdor',
        PartnerStatusFilter.debtor => 'qarzdor',
        PartnerStatusFilter.overdueDebtor => 'muddati_otgan_qarzdor',
      };
}

enum PartnerSort { lastActivity, debtorUzs, debtorUsd, creditorUzs, creditorUsd }

extension PartnerSortX on PartnerSort {
  String? get apiValue => switch (this) {
        PartnerSort.lastActivity => null,
        PartnerSort.debtorUzs => 'qarzdor_uzs',
        PartnerSort.debtorUsd => 'qarzdor_usd',
        PartnerSort.creditorUzs => 'xaqdor_uzs',
        PartnerSort.creditorUsd => 'xaqdor_usd',
      };
}

/// Bitta valyuta bo'yicha hisob (MOBILE_APP_TZ.md 8.5).
class PartnerCurrencyAccount {
  const PartnerCurrencyAccount({
    required this.debt,
    required this.credit,
    required this.balance,
    required this.balanceWithInstallment,
  });

  final Decimal debt;
  final Decimal credit;
  final Decimal balance;
  final Decimal balanceWithInstallment;

  factory PartnerCurrencyAccount.fromJson(Map<String, dynamic> json) => PartnerCurrencyAccount(
        debt: parseMoney(json['debt']),
        credit: parseMoney(json['credit']),
        balance: parseMoney(json['balance']),
        balanceWithInstallment: parseMoney(json['balance_with_installment']),
      );

  static final zero = PartnerCurrencyAccount(
    debt: Decimal.zero,
    credit: Decimal.zero,
    balance: Decimal.zero,
    balanceWithInstallment: Decimal.zero,
  );
}

class PartnerAccount {
  const PartnerAccount({required this.uzs, required this.usd});
  final PartnerCurrencyAccount uzs;
  final PartnerCurrencyAccount usd;

  factory PartnerAccount.fromJson(Map<String, dynamic> rawJson) {
    var source = rawJson;
    if (source['account'] is Map<String, dynamic>) {
      source = source['account'] as Map<String, dynamic>;
    } else if (source['data'] is Map<String, dynamic>) {
      source = source['data'] as Map<String, dynamic>;
    } else if (source['result'] is Map<String, dynamic>) {
      source = source['result'] as Map<String, dynamic>;
    }
    return PartnerAccount(
      uzs: source['uzs_account'] is Map<String, dynamic>
          ? PartnerCurrencyAccount.fromJson(source['uzs_account'] as Map<String, dynamic>)
          : PartnerCurrencyAccount.zero,
      usd: source['usd_account'] is Map<String, dynamic>
          ? PartnerCurrencyAccount.fromJson(source['usd_account'] as Map<String, dynamic>)
          : PartnerCurrencyAccount.zero,
    );
  }
}

/// Kirim/Chiqim tranzaksiyasi (MOBILE_APP_TZ.md 8.6).
class Wallet {
  const Wallet({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    required this.currencyTypeId,
    required this.currencyTypeName,
    required this.summa,
    this.description,
    this.returnDate,
    required this.type,
    required this.isCancelled,
    this.cancelReason,
    this.createdAt,
    this.deletedAt,
    this.performedByName,
  });

  final int id;
  final int partnerId;
  final String partnerName;
  final int currencyTypeId;
  final String currencyTypeName;
  final Decimal summa;
  final String? description;
  final DateTime? returnDate;
  final String type; // credit | debt
  final bool isCancelled;
  final String? cancelReason;
  final DateTime? createdAt;
  final DateTime? deletedAt;
  final String? performedByName;

  bool get isExpense => type == 'credit';

  factory Wallet.fromJson(Map<String, dynamic> rawJson) {
    var json = rawJson;
    if (json['wallet'] is Map<String, dynamic>) {
      json = json['wallet'] as Map<String, dynamic>;
    } else if (json['data'] is Map<String, dynamic>) {
      json = json['data'] as Map<String, dynamic>;
    } else if (json['result'] is Map<String, dynamic>) {
      json = json['result'] as Map<String, dynamic>;
    }

    final idVal = json['id'];
    final id = idVal is int ? idVal : (int.tryParse('$idVal') ?? 0);

    final partnerIdVal = json['partner_id'];
    final partnerId = partnerIdVal is int ? partnerIdVal : (int.tryParse('$partnerIdVal') ?? 0);

    final currencyTypeIdVal = json['currency_type_id'];
    final currencyTypeId = currencyTypeIdVal is int ? currencyTypeIdVal : (int.tryParse('$currencyTypeIdVal') ?? 1);

    final cancelledVal = json['is_cancelled'];
    final isCancelled = cancelledVal == true || cancelledVal == 1 || cancelledVal == '1';

    final activity = json['activity'] is Map<String, dynamic>
        ? json['activity'] as Map<String, dynamic>
        : null;
    final performedBy = activity?['performed_by'] is Map<String, dynamic>
        ? activity!['performed_by'] as Map<String, dynamic>
        : null;

    return Wallet(
      id: id,
      partnerId: partnerId,
      partnerName: json['partner_name']?.toString() ?? '',
      currencyTypeId: currencyTypeId,
      currencyTypeName: json['currency_type_name']?.toString() ?? (currencyTypeId == 2 ? 'USD' : 'UZS'),
      summa: parseMoney(json['summa']),
      description: json['description']?.toString(),
      returnDate: AppDateFormatter.parseFromBackend(json['return_date']?.toString()),
      type: json['type']?.toString() ?? 'debt',
      isCancelled: isCancelled,
      cancelReason: json['cancel_reason']?.toString(),
      createdAt: AppDateFormatter.parseFromBackend(json['created_at']?.toString()),
      deletedAt: AppDateFormatter.parseFromBackend(json['deleted_at']?.toString()),
      performedByName: performedBy?['name']?.toString(),
    );
  }
}
