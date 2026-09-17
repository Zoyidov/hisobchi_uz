import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/notifications_repository.dart';

/// Global — Dashboard/Profil qo'ng'iroq belgisidagi son (MOBILE_APP_TZ.md 14.4).
/// Push (FCM) ulanmagunicha ekran ochilganda so'ralib turadi.
class NotificationBadgeCubit extends Cubit<int> {
  NotificationBadgeCubit(this._repository) : super(0);

  final NotificationsRepository _repository;

  Future<void> refresh() async {
    final result = await _repository.getUnreadCount();
    result.when(success: (count) => emit(count), failure: (_) {});
  }
}
