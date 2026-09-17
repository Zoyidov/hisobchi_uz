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

  factory Project.fromJson(Map<String, dynamic> rawJson) {
    var json = rawJson;
    if (json['project'] is Map<String, dynamic>) {
      json = json['project'] as Map<String, dynamic>;
    } else if (json['data'] is Map<String, dynamic>) {
      json = json['data'] as Map<String, dynamic>;
    }
    final idVal = json['id'];
    final id = idVal is int ? idVal : (int.tryParse('$idVal') ?? 0);
    return Project(
      id: id,
      projectName: json['project_name']?.toString() ?? '',
      projectOwner: json['project_owner']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString(),
      location: json['location']?.toString(),
      status: ProjectStatusX.fromApi(json['status']?.toString()),
      deletedAt: AppDateFormatter.parseFromBackend(json['deleted_at']?.toString()),
      createdAt: AppDateFormatter.parseFromBackend(json['created_at']?.toString()),
      accounts: json['accounts'] is Map<String, dynamic> ? ProjectAccounts.fromJson(json['accounts'] as Map<String, dynamic>) : null,
    );
  }
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

  factory ProjectContract.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'];
    final id = idVal is int ? idVal : (int.tryParse('$idVal') ?? 0);
    final workVal = json['work_type_id'];
    final workTypeId = workVal is int ? workVal : (int.tryParse('$workVal') ?? 0);
    return ProjectContract(
      id: id,
      workTypeId: workTypeId,
      workTypeName: json['work_type_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      summa: parseMoney(json['summa']),
      createdAt: AppDateFormatter.parseFromBackend(json['created_at']?.toString()),
    );
  }
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

  factory ProjectIncome.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'];
    final id = idVal is int ? idVal : (int.tryParse('$idVal') ?? 0);
    final currVal = json['currency_type_id'];
    final currencyTypeId = currVal is int ? currVal : (int.tryParse('$currVal') ?? 1);
    return ProjectIncome(
      id: id,
      currencyTypeId: currencyTypeId,
      currencyTypeName: json['currency_type_name']?.toString() ?? (currencyTypeId == 2 ? 'USD' : 'UZS'),
      summa: parseMoney(json['summa']),
      description: json['description']?.toString(),
      createdAt: AppDateFormatter.parseFromBackend(json['created_at']?.toString()),
    );
  }
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

  factory ProjectCost.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'];
    final id = idVal is int ? idVal : (int.tryParse('$idVal') ?? 0);
    final costVal = json['cost_type_id'];
    final costTypeId = costVal is int ? costVal : (int.tryParse('$costVal') ?? 0);
    final currVal = json['currency_type_id'];
    final currencyTypeId = currVal is int ? currVal : (int.tryParse('$currVal') ?? 1);
    final workerVal = json['worker_id'];
    final workerId = workerVal is int ? workerVal : int.tryParse('$workerVal');
    return ProjectCost(
      id: id,
      costTypeId: costTypeId,
      costTypeName: json['cost_type_name']?.toString() ?? '',
      currencyTypeId: currencyTypeId,
      currencyTypeName: json['currency_type_name']?.toString() ?? (currencyTypeId == 2 ? 'USD' : 'UZS'),
      summa: parseMoney(json['summa']),
      description: json['description']?.toString(),
      workerId: workerId,
      workerName: json['worker_name']?.toString(),
      createdAt: AppDateFormatter.parseFromBackend(json['created_at']?.toString()),
    );
  }
}

/// Loyihaga biriktirilgan ishchi (MOBILE_APP_TZ.md 10.4-D).
class ProjectWorker {
  const ProjectWorker({required this.id, required this.name, this.phone, this.positionName});
  final int id;
  final String name;
  final String? phone;
  final String? positionName;

  factory ProjectWorker.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'];
    final id = idVal is int ? idVal : (int.tryParse('$idVal') ?? 0);
    return ProjectWorker(
      id: id,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      positionName: json['worker_position_name']?.toString(),
    );
  }
}
