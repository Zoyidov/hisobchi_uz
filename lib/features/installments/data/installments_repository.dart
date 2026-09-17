import 'package:decimal/decimal.dart';

import '../../../core/constants/app_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/paged_result.dart';
import '../../../core/utils/formatters/date_formatter.dart';
import '../../../core/utils/money.dart';
import 'installment_models.dart';

class InstallmentsRepository {
  InstallmentsRepository(this._client);

  final ApiClient _client;

  Future<ApiResult<SimplePage<InstallmentPlan>>> getInstallments({
    required int page,
    int? partnerId,
    InstallmentPlanStatus? status,
    int? currencyTypeId,
    String? search,
  }) {
    return _client.getSimplePage(
      ApiEndpoints.installments,
      query: {
        'page': page,
        if (partnerId != null) 'partner_id': partnerId,
        if (status != null) 'status': status.apiValue,
        if (currencyTypeId != null) 'currency_type_id': currencyTypeId,
        if (search != null && search.isNotEmpty) 'search': search,
      },
      fromJson: InstallmentPlan.fromJson,
    );
  }

  /// Hamkorning barcha rejalari — paginatsiyasiz (MOBILE_APP_TZ.md 9.9).
  Future<ApiResult<List<InstallmentPlan>>> getPartnerInstallments(int partnerId) {
    return _client.getList(ApiEndpoints.partnerInstallments(partnerId), fromJson: InstallmentPlan.fromJson);
  }

  Future<ApiResult<InstallmentPlan>> getInstallment(int id) {
    return _client.get(ApiEndpoints.installmentById(id), parse: (r) => InstallmentPlan.fromJson(r as Map<String, dynamic>));
  }

  Future<ApiResult<InstallmentPlan>> createEqual({
    required int partnerId,
    required int currencyTypeId,
    required Decimal totalAmount,
    required bool hasAdvance,
    Decimal? advanceAmount,
    required DateTime startDate,
    required int installmentCount,
    String? note,
    List<int>? fileIds,
  }) {
    return _client.post(
      ApiEndpoints.installments,
      data: {
        'partner_id': partnerId,
        'currency_type_id': currencyTypeId,
        'total_amount': moneyToApi(totalAmount),
        'schedule_type': 'equal',
        'has_advance': hasAdvance,
        if (hasAdvance && advanceAmount != null) 'advance_amount': moneyToApi(advanceAmount),
        'start_date': AppDateFormatter.toApiDate(startDate),
        'installment_count': installmentCount,
        if (note != null && note.isNotEmpty) 'note': note,
        if (fileIds != null) 'file_ids': fileIds,
      },
      parse: (r) => InstallmentPlan.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<InstallmentPlan>> createCustom({
    required int partnerId,
    required int currencyTypeId,
    required Decimal totalAmount,
    required bool hasAdvance,
    Decimal? advanceAmount,
    required List<InstallmentPreviewItem> items,
    String? note,
    List<int>? fileIds,
  }) {
    return _client.post(
      ApiEndpoints.installments,
      data: {
        'partner_id': partnerId,
        'currency_type_id': currencyTypeId,
        'total_amount': moneyToApi(totalAmount),
        'schedule_type': 'custom',
        'has_advance': hasAdvance,
        if (hasAdvance && advanceAmount != null) 'advance_amount': moneyToApi(advanceAmount),
        'items': items
            .map((i) => {
                  'amount': moneyToApi(i.amount),
                  'due_date': AppDateFormatter.toApiDate(i.dueDate),
                  if (i.note != null) 'note': i.note,
                })
            .toList(),
        if (note != null && note.isNotEmpty) 'note': note,
        if (fileIds != null) 'file_ids': fileIds,
      },
      parse: (r) => InstallmentPlan.fromJson(r as Map<String, dynamic>),
    );
  }

  /// Faqat `note` va `file_ids` tahrirlanadi (MOBILE_APP_TZ.md 9.8).
  Future<ApiResult<InstallmentPlan>> updateNote(int id, {String? note, List<int>? fileIds}) {
    return _client.put(
      ApiEndpoints.installmentById(id),
      data: {if (note != null) 'note': note, if (fileIds != null) 'file_ids': fileIds},
      parse: (r) => InstallmentPlan.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<void>> cancel(int id) => _client.delete(ApiEndpoints.installmentById(id), parse: (_) {});

  Future<ApiResult<InstallmentPlan>> makePayment(int id, {required Decimal amount, String? note, required DateTime paidAt}) {
    return _client.post(
      ApiEndpoints.installmentPayment(id),
      data: {
        'amount': moneyToApi(amount),
        if (note != null && note.isNotEmpty) 'note': note,
        'paid_at': AppDateFormatter.toApiDate(paidAt),
      },
      parse: (r) => InstallmentPlan.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<List<InstallmentPaymentRecord>>> getPaymentHistory(int id) {
    return _client.getList(ApiEndpoints.installmentPaymentHistory(id), fromJson: InstallmentPaymentRecord.fromJson);
  }

  Future<ApiResult<void>> cancelPayment(int planId, int paymentId) =>
      _client.delete(ApiEndpoints.installmentPaymentCancel(planId, paymentId), parse: (_) {});
}
