import '../../../core/constants/app_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/paged_result.dart';
import '../../../core/utils/formatters/date_formatter.dart';
import 'installment_report_models.dart';
import 'partner_report_models.dart';
import 'project_report_models.dart';

class ReportsRepository {
  ReportsRepository(this._client);

  final ApiClient _client;

  // ---------------- Partners V3 ----------------

  Future<ApiResult<PartnerSummaryReport>> getPartnersSummary(int currencyTypeId) {
    return _client.get(
      ApiEndpoints.partnersV3Summary,
      parse: (r) {
        final map = r as Map<String, dynamic>;
        final key = currencyTypeId == 2 ? 'USD' : 'UZS';
        return PartnerSummaryReport.fromJson(map[key] as Map<String, dynamic>? ?? const {});
      },
    );
  }

  Future<ApiResult<SimplePage<PartnerReportDetailItem>>> getPartnersSummaryDetails({
    required String type,
    required int currencyTypeId,
    int page = 1,
  }) {
    return _client.getSimplePage(
      ApiEndpoints.partnersV3SummaryDetails,
      query: {'type': type, 'currency_type_id': currencyTypeId, 'page': page},
      fromJson: PartnerReportDetailItem.fromJson,
    );
  }

  Future<ApiResult<Map<String, PeriodSummary>>> getPartnersPeriods({
    required DateTime from,
    required DateTime to,
  }) {
    return _client.get(
      ApiEndpoints.partnersV3Periods,
      query: {'date[0]': AppDateFormatter.toApiFilterDate(from), 'date[1]': AppDateFormatter.toApiFilterDate(to)},
      parse: (r) {
        final map = r as Map<String, dynamic>;
        return {
          'UZS': PeriodSummary.fromJson(map['UZS'] as Map<String, dynamic>? ?? const {}),
          'USD': PeriodSummary.fromJson(map['USD'] as Map<String, dynamic>? ?? const {}),
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
          'UZS': WarrantyPeriodsSummary.fromJson(map['UZS'] as Map<String, dynamic>? ?? const {}),
          'USD': WarrantyPeriodsSummary.fromJson(map['USD'] as Map<String, dynamic>? ?? const {}),
        };
      },
    );
  }

  Future<ApiResult<SimplePage<PartnerReportDetailItem>>> getWarrantyPeriodsDetails({
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

  Future<ApiResult<List<WorkerReportItem>>> getWorkersReport({required DateTime from, required DateTime to}) {
    return _client.getList(
      ApiEndpoints.partnersV3WorkersLists,
      query: {'date[0]': AppDateFormatter.toApiFilterDate(from), 'date[1]': AppDateFormatter.toApiFilterDate(to)},
      fromJson: WorkerReportItem.fromJson,
    );
  }

  // ---------------- Partner detail V2 ----------------

  Future<ApiResult<PartnerDetailReport>> getPartnerDetailReport(int partnerId) {
    return _client.get(
      ApiEndpoints.partnerDetailsV2(partnerId),
      parse: (r) => PartnerDetailReport.fromJson(r as Map<String, dynamic>),
    );
  }

  // ---------------- Installments ----------------

  Future<ApiResult<InstallmentReportSummary>> getInstallmentSummary(int currencyTypeId) {
    return _client.get(
      ApiEndpoints.installmentReportSummary,
      query: {'currency_type_id': currencyTypeId},
      parse: (r) => InstallmentReportSummary.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<List<InstallmentPartnerRanking>>> getInstallmentPartners(int currencyTypeId) {
    return _client.getList(
      ApiEndpoints.installmentReportPartners,
      query: {'currency_type_id': currencyTypeId},
      fromJson: InstallmentPartnerRanking.fromJson,
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
      parse: (r) => RecoveryReport.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<List<MonthlyInstallmentStat>>> getMonthlyInstallments({required int year, int? currencyTypeId}) {
    return _client.getList(
      ApiEndpoints.installmentReportMonthly,
      query: {'year': year, if (currencyTypeId != null) 'currency_type_id': currencyTypeId},
      fromJson: MonthlyInstallmentStat.fromJson,
    );
  }

  // ---------------- Projects ----------------

  Future<ApiResult<ProjectBalanceReport>> getProjectBalance(int projectId) {
    return _client.get(
      ApiEndpoints.projectReportBalance,
      query: {'project_id': projectId},
      parse: (r) => ProjectBalanceReport.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<List<WorkerCostItem>>> getProjectWorkersCosts(int projectId) {
    return _client.getList(
      ApiEndpoints.projectReportWorkersCosts,
      query: {'project_id': projectId},
      fromJson: WorkerCostItem.fromJson,
    );
  }
}
