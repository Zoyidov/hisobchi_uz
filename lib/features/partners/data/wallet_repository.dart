import 'package:decimal/decimal.dart';

import '../../../core/constants/app_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/utils/formatters/date_formatter.dart';
import '../../../core/utils/money.dart';
import 'partner_models.dart';

class WalletRepository {
  WalletRepository(this._client);

  final ApiClient _client;

  /// Paginatsiyasiz — barcha yozuvlar bir marta keladi (MOBILE_APP_TZ.md 8.6).
  Future<ApiResult<List<Wallet>>> getWallets({
    required int partnerId,
    String? search,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? type,
    int? currencyTypeId,
  }) {
    return _client.getList(
      ApiEndpoints.wallets,
      query: {
        'partner_id': partnerId,
        if (search != null && search.isNotEmpty) 'search': search,
        if (dateFrom != null) 'date[0]': AppDateFormatter.toApiFilterDate(dateFrom),
        if (dateTo != null) 'date[1]': AppDateFormatter.toApiFilterDate(dateTo),
        if (type != null) 'type': type,
        if (currencyTypeId != null) 'currency_type_id': currencyTypeId,
      },
      fromJson: Wallet.fromJson,
    );
  }

  Future<ApiResult<Wallet>> createWallet({
    required int partnerId,
    required int currencyTypeId,
    required Decimal summa,
    required String type,
    String? description,
    DateTime? returnDate,
    List<int>? fileIds,
  }) {
    return _client.post(
      ApiEndpoints.wallet,
      data: {
        'partner_id': partnerId,
        'currency_type_id': currencyTypeId,
        'summa': moneyToApi(summa),
        'type': type,
        if (description != null && description.isNotEmpty) 'description': description,
        if (returnDate != null) 'return_date': AppDateFormatter.toApiDate(returnDate),
        if (fileIds != null) 'file_id': fileIds,
      },
      parse: (r) => Wallet.fromJson(r as Map<String, dynamic>),
    );
  }

  /// Faqat `credit` (Chiqim) tahrirlanadi — `debt` (Kirim) uchun server
  /// xatolik qaytaradi (MOBILE_APP_TZ.md 8.8).
  Future<ApiResult<Wallet>> updateWallet({
    required int id,
    required int partnerId,
    required int currencyTypeId,
    required Decimal summa,
    required String type,
    String? description,
    DateTime? returnDate,
    List<int>? fileIds,
  }) {
    return _client.put(
      ApiEndpoints.walletById(id),
      data: {
        'partner_id': partnerId,
        'currency_type_id': currencyTypeId,
        'summa': moneyToApi(summa),
        'type': type,
        if (description != null && description.isNotEmpty) 'description': description,
        if (returnDate != null) 'return_date': AppDateFormatter.toApiDate(returnDate),
        if (fileIds != null) 'file_id': fileIds,
      },
      parse: (r) => Wallet.fromJson(r as Map<String, dynamic>),
    );
  }

  Future<ApiResult<void>> cancelWallet(int id, String reason) {
    return _client.put(ApiEndpoints.walletCancel(id), data: {'cancel_reason': reason}, parse: (_) {});
  }

  Future<ApiResult<void>> deleteWallet(int id) => _client.delete(ApiEndpoints.walletById(id), parse: (_) {});

  Future<ApiResult<void>> restoreWallet(int id) =>
      _client.post(ApiEndpoints.walletRestore(id), parse: (_) {});
}
