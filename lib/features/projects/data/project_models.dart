import 'package:decimal/decimal.dart';

import '../../../core/utils/formatters/date_formatter.dart';
import '../../../core/utils/money.dart';

enum ProjectStatus { inProgress, frozen, completed }

extension ProjectStatusX on ProjectStatus {
  static ProjectStatus fromApi(String? value) => switch (value) {
        'frozen' => ProjectStatus.frozen,
        'completed' => ProjectStatus.completed,
        _ => ProjectStatus.inProgress,
      };

  String get apiValue => switch (this) {
        ProjectStatus.inProgress => 'in_progress',
        ProjectStatus.frozen => 'frozen',
        ProjectStatus.completed => 'completed',
      };

  String get label => switch (this) {
        ProjectStatus.inProgress => 'Jarayonda',
        ProjectStatus.frozen => 'Muzlatilgan',
        ProjectStatus.completed => 'Tugallangan',
      };
}

/// Loyiha (MOBILE_APP_TZ.md 10.2).
class Project {
  const Project({
    required this.id,
    required this.projectName,
    required this.projectOwner,
    required this.phone,
    this.address,
    this.location,
    required this.status,
    this.deletedAt,
    this.createdAt,
    this.accounts,
  });

  final int id;
  final String projectName;
  final String projectOwner;
  final String phone;
  final String? address;
  final String? location;
  final ProjectStatus status;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final ProjectAccounts? accounts;

  bool get isDeleted => deletedAt != null;

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as int,
        projectName: json['project_name'] as String? ?? '',
        projectOwner: json['project_owner'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        address: json['address'] as String?,
        location: json['location'] as String?,
        status: ProjectStatusX.fromApi(json['status'] as String?),
        deletedAt: AppDateFormatter.parseFromBackend(json['deleted_at'] as String?),
        createdAt: AppDateFormatter.parseFromBackend(json['created_at'] as String?),
        accounts: json['accounts'] != null ? ProjectAccounts.fromJson(json['accounts'] as Map<String, dynamic>) : null,
      );
}

class ProjectCurrencyAccount {
  const ProjectCurrencyAccount({required this.income, required this.cost, required this.balance});
  final Decimal income;
  final Decimal cost;
  final Decimal balance;

  static final zero = ProjectCurrencyAccount(income: Decimal.zero, cost: Decimal.zero, balance: Decimal.zero);
}

class ProjectAccounts {
  const ProjectAccounts({required this.uzs, required this.usd});
  final ProjectCurrencyAccount uzs;
  final ProjectCurrencyAccount usd;

  factory ProjectAccounts.fromJson(Map<String, dynamic> json) => ProjectAccounts(
        uzs: ProjectCurrencyAccount(
          income: parseMoney(json['income_uzs']),
          cost: parseMoney(json['costs_uzs'] ?? json['cost_uzs']),
          balance: parseMoney(json['balance_uzs']),
        ),
        usd: ProjectCurrencyAccount(
          income: parseMoney(json['income_usd']),
          cost: parseMoney(json['costs_usd'] ?? json['cost_usd']),
          balance: parseMoney(json['balance_usd']),
        ),
      );
}

/// Shartnoma (MOBILE_APP_TZ.md 10.4-A).
class ProjectContract {
  const ProjectContract({
    required this.id,
    required this.workTypeId,
    required this.workTypeName,
    required this.description,
    required this.summa,
    this.createdAt,
  });

  final int id;
  final int workTypeId;
  final String workTypeName;
  final String description;
  final Decimal summa;
  final DateTime? createdAt;

  factory ProjectContract.fromJson(Map<String, dynamic> json) => ProjectContract(
        id: json['id'] as int,
        workTypeId: json['work_type_id'] as int? ?? 0,
        workTypeName: json['work_type_name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        summa: parseMoney(json['summa']),
        createdAt: AppDateFormatter.parseFromBackend(json['created_at'] as String?),
      );
}

/// Daromad (MOBILE_APP_TZ.md 10.4-B).
class ProjectIncome {
  const ProjectIncome({
    required this.id,
    required this.currencyTypeId,
    required this.currencyTypeName,
    required this.summa,
    this.description,
    this.createdAt,
  });

  final int id;
  final int currencyTypeId;
  final String currencyTypeName;
  final Decimal summa;
  final String? description;
  final DateTime? createdAt;

  factory ProjectIncome.fromJson(Map<String, dynamic> json) => ProjectIncome(
        id: json['id'] as int,
        currencyTypeId: json['currency_type_id'] as int? ?? 1,
        currencyTypeName: json['currency_type_name'] as String? ?? 'UZS',
        summa: parseMoney(json['summa']),
        description: json['description'] as String?,
        createdAt: AppDateFormatter.parseFromBackend(json['created_at'] as String?),
      );
}

/// Xarajat (MOBILE_APP_TZ.md 10.4-C).
class ProjectCost {
  const ProjectCost({
    required this.id,
    required this.costTypeId,
    required this.costTypeName,
    required this.currencyTypeId,
    required this.currencyTypeName,
    required this.summa,
    this.description,
    this.workerId,
    this.workerName,
    this.createdAt,
  });

  final int id;
  final int costTypeId;
  final String costTypeName;
  final int currencyTypeId;
  final String currencyTypeName;
  final Decimal summa;
  final String? description;
  final int? workerId;
  final String? workerName;
  final DateTime? createdAt;

  factory ProjectCost.fromJson(Map<String, dynamic> json) => ProjectCost(
        id: json['id'] as int,
        costTypeId: json['cost_type_id'] as int? ?? 0,
        costTypeName: json['cost_type_name'] as String? ?? '',
        currencyTypeId: json['currency_type_id'] as int? ?? 1,
        currencyTypeName: json['currency_type_name'] as String? ?? 'UZS',
        summa: parseMoney(json['summa']),
        description: json['description'] as String?,
        workerId: json['worker_id'] as int?,
        workerName: json['worker_name'] as String?,
        createdAt: AppDateFormatter.parseFromBackend(json['created_at'] as String?),
      );
}

/// Loyihaga biriktirilgan ishchi (MOBILE_APP_TZ.md 10.4-D).
class ProjectWorker {
  const ProjectWorker({required this.id, required this.name, this.phone, this.positionName});
  final int id;
  final String name;
  final String? phone;
  final String? positionName;

  factory ProjectWorker.fromJson(Map<String, dynamic> json) => ProjectWorker(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String?,
        positionName: json['worker_position_name'] as String?,
      );
}
