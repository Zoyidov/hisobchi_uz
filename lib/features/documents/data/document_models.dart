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

  factory SimpleDocument.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'];
    final id = idVal is int ? idVal : (int.tryParse('$idVal') ?? 0);
    return SimpleDocument(
      id: id,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      deletedAt: AppDateFormatter.parseFromBackend(json['deleted_at']?.toString()),
    );
  }
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

  factory CostType.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'];
    final id = idVal is int ? idVal : (int.tryParse('$idVal') ?? 0);
    final workerJoinVal = json['is_worker_join'];
    final isWorkerJoin = workerJoinVal == true || workerJoinVal == 1 || workerJoinVal == '1';
    final updateDeleteVal = json['is_update_and_delete'];
    final isSystem = updateDeleteVal == false || updateDeleteVal == 0 || updateDeleteVal == '0';
    return CostType(
      id: id,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      isWorkerJoin: isWorkerJoin,
      isSystem: isSystem,
      deletedAt: AppDateFormatter.parseFromBackend(json['deleted_at']?.toString()),
    );
  }
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

  factory Worker.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'];
    final id = idVal is int ? idVal : (int.tryParse('$idVal') ?? 0);
    final posVal = json['worker_position_id'];
    final positionId = posVal is int ? posVal : int.tryParse('$posVal');
    return Worker(
      id: id,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      additionalPhone: json['additional_phone']?.toString(),
      positionId: positionId,
      positionName: json['worker_position_name']?.toString(),
      description: json['description']?.toString(),
      deletedAt: AppDateFormatter.parseFromBackend(json['deleted_at']?.toString()),
    );
  }
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
