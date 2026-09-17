import '../../../core/utils/formatters/date_formatter.dart';

/// Ish turi / Lavozim — `name` + `description` (MOBILE_APP_TZ.md 11-bo'lim).
class SimpleDocument {
  const SimpleDocument({
    required this.id,
    required this.name,
    this.description,
    this.deletedAt,
  });

  final int id;
  final String name;
  final String? description;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  factory SimpleDocument.fromJson(Map<String, dynamic> json) => SimpleDocument(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        deletedAt: AppDateFormatter.parseFromBackend(json['deleted_at'] as String?),
      );
}

/// Xarajat turi — qo'shimcha `is_worker_join` va `is_update_and_delete` bayrog'i.
class CostType {
  const CostType({
    required this.id,
    required this.name,
    this.description,
    required this.isWorkerJoin,
    required this.isSystem,
    this.deletedAt,
  });

  final int id;
  final String name;
  final String? description;
  final bool isWorkerJoin;

  /// `is_update_and_delete = false` bo'lsa tizim yozuvi — tahrirlanmaydi.
  final bool isSystem;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  factory CostType.fromJson(Map<String, dynamic> json) => CostType(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        isWorkerJoin: json['is_worker_join'] as bool? ?? false,
        isSystem: json['is_update_and_delete'] == false,
        deletedAt: AppDateFormatter.parseFromBackend(json['deleted_at'] as String?),
      );
}

/// Ishchi (MOBILE_APP_TZ.md 11-bo'lim).
class Worker {
  const Worker({
    required this.id,
    required this.name,
    required this.phone,
    this.additionalPhone,
    this.positionId,
    this.positionName,
    this.description,
    this.deletedAt,
  });

  final int id;
  final String name;
  final String phone;
  final String? additionalPhone;
  final int? positionId;
  final String? positionName;
  final String? description;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  factory Worker.fromJson(Map<String, dynamic> json) => Worker(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        additionalPhone: json['additional_phone'] as String?,
        positionId: json['worker_position_id'] as int?,
        positionName: json['worker_position_name'] as String?,
        description: json['description'] as String?,
        deletedAt: AppDateFormatter.parseFromBackend(json['deleted_at'] as String?),
      );
}

/// CBU valyuta kursi (MOBILE_APP_TZ.md 11: `currencys-exchange-rates`).
class CurrencyExchangeRate {
  const CurrencyExchangeRate({
    required this.code,
    required this.nameUz,
    required this.nameRu,
    required this.nominal,
    required this.rate,
    required this.diff,
    required this.date,
  });

  final String code;
  final String nameUz;
  final String nameRu;
  final double nominal;
  final double rate;
  final double diff;
  final String date;

  factory CurrencyExchangeRate.fromJson(Map<String, dynamic> json) => CurrencyExchangeRate(
        code: json['Ccy'] as String? ?? '',
        nameUz: json['CcyNm_UZ'] as String? ?? '',
        nameRu: json['CcyNm_RU'] as String? ?? '',
        nominal: double.tryParse('${json['Nominal']}') ?? 1,
        rate: double.tryParse('${json['Rate']}') ?? 0,
        diff: double.tryParse('${json['Diff']}') ?? 0,
        date: json['Date'] as String? ?? '',
      );
}
