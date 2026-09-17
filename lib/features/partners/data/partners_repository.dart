import '../../../core/constants/app_endpoints.dart';
import '../../../core/di/injector.dart';
import '../../../core/events/data_refresh_bus.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/paged_result.dart';
import '../../../core/utils/formatters/date_formatter.dart';
import '../../../core/utils/formatters/phone_formatter.dart';
import 'partner_models.dart';
import 'sms_models.dart';

class PartnersRepository {
  PartnersRepository(this._client);

  final ApiClient _client;

  Future<ApiResult<SimplePage<Partner>>> getPartners({
    required int page,
    String? search,
    PartnerStatusFilter status = PartnerStatusFilter.all,
    PartnerSort sort = PartnerSort.lastActivity,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return _client.getSimplePage(
      ApiEndpoints.partnersAccount,
      query: {
        'page': page,
        if (search != null && search.isNotEmpty) 'search': search,
        if (status.apiValue != null) 'status_filter': status.apiValue,
        if (sort.apiValue != null) 'sort': sort.apiValue,
        if (dateFrom != null) 'date[0]': AppDateFormatter.toApiFilterDate(dateFrom),
        if (dateTo != null) 'date[1]': AppDateFormatter.toApiFilterDate(dateTo),
      },
      fromJson: Partner.fromJson,
    );
  }

  /// Soddalashtirilgan ro'yxat — dropdown/selector uchun, balanssiz,
  /// paginatsiyasiz (MOBILE_APP_TZ.md 8.4).
  Future<ApiResult<List<Partner>>> getPartnersSimple({String? search}) {
    return _client.getList(
      ApiEndpoints.partnersSimple,
      query: {if (search != null && search.isNotEmpty) 'search': search},
      fromJson: Partner.fromJson,
    );
  }

  Future<ApiResult<Partner>> getPartner(int id) {
    return _client.get(ApiEndpoints.partnerById(id), parse: (r) => Partner.fromJson(r as Map<String, dynamic>));
  }

  Future<ApiResult<PartnerAccount>> getPartnerAccount(int id) {
    return _client.get(
      ApiEndpoints.partnerAccount(id),
      parse: (r) => PartnerAccount.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<Partner>> createPartner({
    required String name,
    required String phone,
    String? additionalPhone,
    required int currencyTypeId,
    List<int>? fileIds,
  }) {
    return _client.post(
      ApiEndpoints.partner,
      data: {
        'name': name,
        'phone': PhoneFormatter.toApi(phone),
        if (additionalPhone != null && additionalPhone.isNotEmpty)
          'additional_phone': PhoneFormatter.toApi(additionalPhone),
        'currency_type_id': currencyTypeId,
        if (fileIds != null) 'file_id': fileIds,
      },
      parse: (r) => Partner.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<Partner>> updatePartner({
    required int id,
    required String name,
    required String phone,
    String? additionalPhone,
    required int currencyTypeId,
    List<int>? fileIds,
  }) {
    return _client.put(
      ApiEndpoints.partnerById(id),
      data: {
        'name': name,
        'phone': PhoneFormatter.toApi(phone),
        if (additionalPhone != null && additionalPhone.isNotEmpty)
          'additional_phone': PhoneFormatter.toApi(additionalPhone),
        'currency_type_id': currencyTypeId,
        if (fileIds != null) 'file_id': fileIds,
      },
      parse: (r) => Partner.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<void>> deletePartner(int id) async {
    final res = await _client.delete(ApiEndpoints.partnerById(id), parse: (_) {});
    if (res.isSuccess) {
      getIt<DataRefreshBus>().notifyPartnersChanged(partnerId: id);
    }
    return res;
  }

  Future<ApiResult<void>> restorePartner(int id) async {
    final res = await _client.post(ApiEndpoints.partnerRestore(id), parse: (_) {});
    if (res.isSuccess) {
      getIt<DataRefreshBus>().notifyPartnersChanged(partnerId: id);
    }
    return res;
  }

  Future<ApiResult<void>> forceDeletePartner(int id) async {
    final res = await _client.delete(ApiEndpoints.partnerForceDelete(id), parse: (_) {});
    if (res.isSuccess) {
      getIt<DataRefreshBus>().notifyPartnersChanged(partnerId: id);
    }
    return res;
  }

  Future<ApiResult<SimplePage<SentSms>>> getSentSms(int partnerId, {int page = 1}) {
    return _client.getSimplePage(
      ApiEndpoints.partnerSentSms(partnerId),
      query: {'page': page},
      fromJson: SentSms.fromJson,
    );
  }

  Future<ApiResult<PartnerSmsSettings>> getSmsSettings(int partnerId) {
    return _client.get(
      ApiEndpoints.partnerSettings(partnerId),
      parse: (r) => PartnerSmsSettings.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<void>> updateSmsSettings(int partnerId, PartnerSmsSettings settings) {
    return _client.put(ApiEndpoints.partnerSettings(partnerId), data: settings.toJson(), parse: (_) {});
  }

  Future<ApiResult<List<int>>> exportPartnersExcel() async {
    final result = await _client.downloadBytes(ApiEndpoints.partnersExportExcel);
    return result;
  }

  Future<ApiResult<List<int>>> exportPartnerWalletsExcel(int partnerId) {
    return _client.downloadBytes(ApiEndpoints.partnerWalletsExportExcel(partnerId));
  }
}
