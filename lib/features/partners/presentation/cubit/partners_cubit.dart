import '../../../../core/network/api_result.dart';
import '../../../../core/network/paged_result.dart';
import '../../../../core/paging/paged_list_cubit.dart';
import '../../data/partner_models.dart';
import '../../data/partners_repository.dart';

/// Hamkorlar ro'yxati — qidiruv, filtr, saralash (MOBILE_APP_TZ.md 8.2).
class PartnersCubit extends PagedListCubit<Partner> {
  PartnersCubit(this._repository);

  final PartnersRepository _repository;

  String _search = '';
  PartnerStatusFilter _status = PartnerStatusFilter.all;
  PartnerSort _sort = PartnerSort.lastActivity;

  String get search => _search;
  PartnerStatusFilter get status => _status;
  PartnerSort get sort => _sort;
  bool get hasActiveFilter => _status != PartnerStatusFilter.all;

  void updateSearch(String value) {
    _search = value;
    loadFirst();
  }

  void updateStatus(PartnerStatusFilter value) {
    _status = value;
    loadFirst();
  }

  void updateSort(PartnerSort value) {
    _sort = value;
    loadFirst();
  }

  void clearFilters() {
    _status = PartnerStatusFilter.all;
    loadFirst();
  }

  @override
  Future<ApiResult<SimplePage<Partner>>> fetchPage(int page) {
    return _repository.getPartners(page: page, search: _search, status: _status, sort: _sort);
  }
}
