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

  factory Partner.fromJson(Map<String, dynamic> json) {
    final balance = json['balance'] as Map<String, dynamic>?;
    final installment = json['installment_remaining'] as Map<String, dynamic>?;
    return Partner(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      additionalPhone: json['additional_phone'] as String?,
      mainCurrencyTypeId: json['main_currency_type_id'] as int? ?? 1,
      mainCurrencyTypeName: json['main_currency_type_name'] as String? ?? 'UZS',
      balanceUzs: _currencyValue(balance, 'UZS'),
      balanceUsd: _currencyValue(balance, 'USD'),
      installmentRemainingUzs: _currencyValue(installment, 'UZS'),
      installmentRemainingUsd: _currencyValue(installment, 'USD'),
      sendOnKirim: json['send_on_kirim'] as bool? ?? true,
      sendOnChiqim: json['send_on_chiqim'] as bool? ?? true,
      createdAt: AppDateFormatter.parseFromBackend(json['created_at'] as String?),
      deletedAt: AppDateFormatter.parseFromBackend(json['deleted_at'] as String?),
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

  factory PartnerAccount.fromJson(Map<String, dynamic> json) => PartnerAccount(
        uzs: json['uzs_account'] != null
            ? PartnerCurrencyAccount.fromJson(json['uzs_account'] as Map<String, dynamic>)
            : PartnerCurrencyAccount.zero,
        usd: json['usd_account'] != null
            ? PartnerCurrencyAccount.fromJson(json['usd_account'] as Map<String, dynamic>)
            : PartnerCurrencyAccount.zero,
      );
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

  factory Wallet.fromJson(Map<String, dynamic> json) {
    final activity = json['activity'] as Map<String, dynamic>?;
    final performedBy = activity?['performed_by'] as Map<String, dynamic>?;
    return Wallet(
      id: json['id'] as int,
      partnerId: json['partner_id'] as int? ?? 0,
      partnerName: json['partner_name'] as String? ?? '',
      currencyTypeId: json['currency_type_id'] as int? ?? 1,
      currencyTypeName: json['currency_type_name'] as String? ?? 'UZS',
      summa: parseMoney(json['summa']),
      description: json['description'] as String?,
      returnDate: json['return_date'] != null
          ? DateTime.tryParse(json['return_date'] as String)
          : null,
      type: json['type'] as String? ?? 'debt',
      isCancelled: json['is_cancelled'] as bool? ?? false,
      cancelReason: json['cancel_reason'] as String?,
      createdAt: AppDateFormatter.parseFromBackend(json['created_at'] as String?),
      deletedAt: AppDateFormatter.parseFromBackend(json['deleted_at'] as String?),
      performedByName: performedBy?['name'] as String?,
    );
  }
}
