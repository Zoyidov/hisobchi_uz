import '../../../../core/network/api_result.dart';
import '../../../../core/network/paged_result.dart';
import '../../../../core/paging/paged_list_cubit.dart';
import '../../data/partners_repository.dart';
import '../../data/sms_models.dart';

/// SMS tarixi — simplePaginate (MOBILE_APP_TZ.md 8.9).
class PartnerSmsHistoryCubit extends PagedListCubit<SentSms> {
  PartnerSmsHistoryCubit(this._repository, this.partnerId);

  final PartnersRepository _repository;
  final int partnerId;

  @override
  Future<ApiResult<SimplePage<SentSms>>> fetchPage(int page) => _repository.getSentSms(partnerId, page: page);
}
