import '../../../core/constants/app_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/paged_result.dart';
import '../../../core/utils/formatters/date_formatter.dart';
import 'installment_report_models.dart';
import 'partner_installment_report_models.dart';
import 'partner_operation_models.dart';
import 'partner_report_models.dart';
import 'project_report_models.dart';

class ReportsRepository {
  ReportsRepository(this._client);

  final ApiClient _client;

  // ---------------- Partners V3 ----------------

  Future<ApiResult<Map<String, PartnerSummaryReport>>>
  getPartnersSummaryReports() => _client.get(
    ApiEndpoints.partnersV3Summary,
    parse: (result) {
      final map = result as Map<String, dynamic>;
      return {
        for (final currency in ['UZS', 'USD'])
          currency: PartnerSummaryReport.fromJson(
            map[currency] as Map<String, dynamic>? ?? const {},
          ),
      };
    },
  );

  Future<ApiResult<SimplePage<PartnerOperation>>> getPartnersMainOperations({
    required int currencyTypeId,
    int page = 1,
  }) => _operationPage(ApiEndpoints.partnerSummarySectionOne, {
    'type': 'oparation',
    'currency_type_id': currencyTypeId,
    'page': page,
  });

  Future<ApiResult<SimplePage<PartnerOperation>>>
  getPartnersWarrantyOperations({
    required String type,
    required int currencyTypeId,
    int page = 1,
  }) => _operationPage(ApiEndpoints.partnersV3WarrantyPeriodsDetails, {
    'type': type,
    'currency_type_id': currencyTypeId,
    'page': page,
  });

  Future<ApiResult<SimplePage<PartnerOperation>>> getPartnersPeriodOperations({
    required String type,
    required int currencyTypeId,
    required DateTime from,
    required DateTime to,
    int page = 1,
  }) => _operationPage(ApiEndpoints.partnersV3PeriodsOperations, {
    'type': type,
    'currency_type_id': currencyTypeId,
    'date[]': [
      AppDateFormatter.toApiFilterDate(from),
      AppDateFormatter.toApiFilterDate(to),
    ],
    'page': page,
  });

  Future<ApiResult<SimplePage<PartnerOperation>>> _operationPage(
    String path,
    Map<String, dynamic> query,
  ) => _client.get(
    path,
    query: query,
    parse: (result) {
      final map = result as Map<String, dynamic>;
      return SimplePage(
        items: (map['data'] as List? ?? const [])
            .map((e) => PartnerOperation.fromJson(e as Map<String, dynamic>))
            .toList(),
        hasNext:
            map['next_page_url'] != null ||
            (map['links'] as Map<String, dynamic>?)?['next'] != null,
      );
    },
  );

  Future<ApiResult<PartnerSummaryReport>> getPartnersSummary(
    int currencyTypeId,
  ) {
    return _client.get(
      ApiEndpoints.partnersV3Summary,
      parse: (r) {
        final map = r as Map<String, dynamic>;
        final key = currencyTypeId == 2 ? 'USD' : 'UZS';
        return PartnerSummaryReport.fromJson(
          map[key] as Map<String, dynamic>? ?? const {},
        );
      },
    );
  }

  Future<ApiResult<SimplePage<PartnerReportDetailItem>>>
  getPartnersSummaryDetails({
    required String type,
    required int currencyTypeId,
    int page = 1,
  }) {
    return _client.get(
      ApiEndpoints.partnerSummarySectionTwo,
      query: {'type': type, 'currency_type_id': currencyTypeId, 'page': page},
      parse: (result) {
        final map = result as Map<String, dynamic>;
        return SimplePage(
          items: (map['data'] as List? ?? const [])
              .map(
                (e) =>
                    PartnerReportDetailItem.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
          hasNext:
              map['next_page_url'] != null ||
              (map['links'] as Map<String, dynamic>?)?['next'] != null,
        );
      },
    );
  }

  Future<ApiResult<Map<String, PeriodSummary>>> getPartnersPeriods({
    required DateTime from,
    required DateTime to,
  }) {
    return _client.get(
      ApiEndpoints.partnersV3Periods,
      data: {
        'date': [
          AppDateFormatter.toApiFilterDate(from),
          AppDateFormatter.toApiFilterDate(to),
        ],
      },
      parse: (r) {
        final map = r as Map<String, dynamic>;
        return {
          'UZS': PeriodSummary.fromJson(
            map['UZS'] as Map<String, dynamic>? ?? const {},
          ),
          'USD': PeriodSummary.fromJson(
            map['USD'] as Map<String, dynamic>? ?? const {},
          ),
        };
      },
    );
  }

  Future<ApiResult<SimplePage<PeriodOperation>>> getPartnersPeriodsOperations({
    required int currencyTypeId,
    required String type,
    required DateTime from,
    required DateTime to,
    int page = 1,
  }) {
    return _client.getSimplePage(
      ApiEndpoints.partnersV3PeriodsOperations,
      query: {
        'currency_type_id': currencyTypeId,
        'type': type,
        'date[0]': AppDateFormatter.toApiFilterDate(from),
        'date[1]': AppDateFormatter.toApiFilterDate(to),
        'page': page,
      },
      fromJson: PeriodOperation.fromJson,
    );
  }

  Future<ApiResult<Map<String, WarrantyPeriodsSummary>>> getWarrantyPeriods() {
    return _client.get(
      ApiEndpoints.partnersV3WarrantyPeriods,
      parse: (r) {
        final map = r as Map<String, dynamic>;
        return {
          'UZS': WarrantyPeriodsSummary.fromJson(
            map['UZS'] as Map<String, dynamic>? ?? const {},
          ),
          'USD': WarrantyPeriodsSummary.fromJson(
            map['USD'] as Map<String, dynamic>? ?? const {},
          ),
        };
      },
    );
  }

  Future<ApiResult<SimplePage<PartnerReportDetailItem>>>
  getWarrantyPeriodsDetails({
    required String type,
    required int currencyTypeId,
    int page = 1,
  }) {
    return _client.getSimplePage(
      ApiEndpoints.partnersV3WarrantyPeriodsDetails,
      query: {'type': type, 'currency_type_id': currencyTypeId, 'page': page},
      fromJson: PartnerReportDetailItem.fromJson,
    );
  }

  Future<ApiResult<Map<String, PeriodSummary>>> getWorkersSummary({
    DateTime? from,
    DateTime? to,
  }) => _client.get(
    ApiEndpoints.partnersV3Workers,
    query: {
      if (from != null && to != null)
        'date[]': [
          AppDateFormatter.toApiFilterDate(from),
          AppDateFormatter.toApiFilterDate(to),
        ],
    },
    parse: (result) {
      final map = result as Map<String, dynamic>;
      return {
        for (final currency in ['UZS', 'USD'])
          currency: PeriodSummary.fromJson(
            map[currency] as Map<String, dynamic>? ?? const {},
          ),
      };
    },
  );

  Future<ApiResult<List<WorkerReportItem>>> getWorkersReport({
    required int currencyTypeId,
    DateTime? from,
    DateTime? to,
  }) {
    return _client.getList(
      ApiEndpoints.partnersV3WorkersLists,
      query: {
        'currency_type_id': currencyTypeId,
        if (from != null && to != null)
          'date[]': [
            AppDateFormatter.toApiFilterDate(from),
            AppDateFormatter.toApiFilterDate(to),
          ],
      },
      fromJson: WorkerReportItem.fromJson,
    );
  }

  // ---------------- Partner detail V2 ----------------

  Future<ApiResult<PartnerDetailsResult>> getPartnerDetailReport(
    int partnerId,
  ) {
    return _client.get(
      ApiEndpoints.partnerDetailsV2(partnerId),
      parse: (r) => PartnerDetailsResult.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<PartnerInstallmentReportModel>> getPartnerInstallmentReport(
    int partnerId, {
    int? currencyTypeId,
    String? status,
    int? year,
  }) {
    return _client.get(
      ApiEndpoints.installmentReportPartner(partnerId),
      query: {
        if (currencyTypeId != null) 'currency_type_id': currencyTypeId,
        if (status != null && status != 'all') 'status': status,
        if (year != null) 'year': year,
      },
      parse: (r) =>
          PartnerInstallmentReportModel.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<SimplePage<PartnerOperation>>> getPartnerDebtOperations({
    required int partnerId,
    required String type,
    required int currencyTypeId,
    int page = 1,
  }) {
    return _client.getSimplePage(
      ApiEndpoints.partnerDetailsSectionOne,
      query: {
        'partner_id': partnerId,
        'type': type,
        'currency_type_id': currencyTypeId,
        'page': page,
      },
      fromJson: PartnerOperation.fromJson,
    );
  }

  // ---------------- Installments ----------------

  Future<ApiResult<InstallmentReportSummary>> getInstallmentSummary(
    int currencyTypeId,
  ) {
    return _client.get(
      ApiEndpoints.installmentReportSummary,
      query: {'currency_type_id': currencyTypeId},
      parse: (result) {
        if (result is List) {
          // The API returns one summary per currency; never mix currencies.
          for (final entry in result) {
            final row = entry as Map<String, dynamic>;
            if (int.tryParse('${row['currency_type_id']}') == currencyTypeId) {
              return InstallmentReportSummary.fromJson(row);
            }
          }
          return InstallmentReportSummary.fromJson(const {});
        }
        return InstallmentReportSummary.fromJson(
          result as Map<String, dynamic>,
        );
      },
    );
  }

  Future<ApiResult<SimplePage<InstallmentPartnerRanking>>>
  getInstallmentPartners(
    int currencyTypeId, {
    int page = 1,
    String sort = 'remaining',
  }) {
    return _client.get(
      ApiEndpoints.installmentReportPartners,
      query: {'currency_type_id': currencyTypeId, 'page': page, 'sort': sort},
      parse: (result) {
        final map = result as Map<String, dynamic>;
        return SimplePage(
          items: (map['data'] as List)
              .map(
                (item) => InstallmentPartnerRanking.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
          hasNext:
              map['next_page_url'] != null ||
              (map['links'] as Map<String, dynamic>?)?['next'] != null,
        );
      },
    );
  }

  Future<ApiResult<List<RiskyPartner>>> getRiskyPartners(int currencyTypeId) {
    return _client.getList(
      ApiEndpoints.installmentReportRisky,
      query: {'currency_type_id': currencyTypeId},
      fromJson: RiskyPartner.fromJson,
    );
  }

  Future<ApiResult<RecoveryReport>> getRecoveryReport(int currencyTypeId) {
    return _client.get(
      ApiEndpoints.installmentReportRecovery,
      query: {'currency_type_id': currencyTypeId},
      parse: (r) =>
          RecoveryReport.fromJson(_installmentCurrencyRow(r, currencyTypeId)),
    );
  }

  Future<ApiResult<List<MonthlyInstallmentStat>>> getMonthlyInstallments({
    required int year,
    int? currencyTypeId,
  }) {
    return _client.get(
      ApiEndpoints.installmentReportMonthly,
      query: {
        'year': year,
        if (currencyTypeId != null) 'currency_type_id': currencyTypeId,
      },
      parse: (result) {
        final rows = result as List;
        if (rows.isEmpty) return <MonthlyInstallmentStat>[];
        if ((rows.first as Map<String, dynamic>).containsKey('months')) {
          final row = _installmentCurrencyRow(rows, currencyTypeId ?? 1);
          return (row['months'] as List? ?? const [])
              .map(
                (e) =>
                    MonthlyInstallmentStat.fromJson(e as Map<String, dynamic>),
              )
              .toList();
        }
        return rows
            .map(
              (e) => MonthlyInstallmentStat.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      },
    );
  }

  Future<ApiResult<InstallmentForecast>> getInstallmentForecast({
    required int currencyTypeId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) {
    return _client.get(
      ApiEndpoints.installmentReportForecast,
      query: {
        'currency_type_id': currencyTypeId,
        'date_from': AppDateFormatter.display(dateFrom),
        'date_to': AppDateFormatter.display(dateTo),
      },
      parse: (result) => InstallmentForecast.fromJson(
        _installmentCurrencyRow(result, currencyTypeId),
      ),
    );
  }

  Future<ApiResult<SimplePage<InstallmentReportItem>>>
  getInstallmentReportItems({
    required int currencyTypeId,
    required String status,
    int page = 1,
  }) {
    return _client.get(
      ApiEndpoints.installmentReportItems,
      query: {
        'currency_type_id': currencyTypeId,
        'status': status,
        'page': page,
      },
      parse: (result) {
        final map = result as Map<String, dynamic>;
        return SimplePage(
          items: (map['data'] as List? ?? const [])
              .map(
                (e) =>
                    InstallmentReportItem.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
          hasNext:
              map['next_page_url'] != null ||
              (map['links'] as Map<String, dynamic>?)?['next'] != null,
        );
      },
    );
  }

  static Map<String, dynamic> _installmentCurrencyRow(
    dynamic result,
    int currencyTypeId,
  ) {
    if (result is Map<String, dynamic>) return result;
    for (final entry in result as List) {
      final row = entry as Map<String, dynamic>;
      if (int.tryParse('${row['currency_type_id']}') == currencyTypeId) {
        return row;
      }
    }
    return const {};
  }

  // ---------------- Projects ----------------

  Future<ApiResult<ProjectBalanceReport>> getProjectBalance(int projectId) {
    return _client.get(
      ApiEndpoints.projectReportBalance,
      query: {'project_id': projectId},
      parse: (r) => ProjectBalanceReport.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<List<WorkerCostItem>>> getProjectWorkersCosts(
    int projectId,
  ) {
    return _client.getList(
      ApiEndpoints.projectReportWorkersCosts,
      query: {'project_id': projectId},
      fromJson: WorkerCostItem.fromJson,
    );
  }
}
