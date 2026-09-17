import 'package:flutter_bloc/flutter_bloc.dart';

/// `X-Subscription-Status` javob headeri (MOBILE_APP_TZ.md 4.6).
enum SubscriptionStatus { active, gracePeriod, readOnly, archived, none }

SubscriptionStatus subscriptionStatusFromHeader(String? raw) {
  switch (raw) {
    case 'ACTIVE':
      return SubscriptionStatus.active;
    case 'GRACE_PERIOD':
      return SubscriptionStatus.gracePeriod;
    case 'READ_ONLY':
      return SubscriptionStatus.readOnly;
    case 'ARCHIVED':
      return SubscriptionStatus.archived;
    default:
      return SubscriptionStatus.none;
  }
}

/// Global obuna holati — har bir javobda yangilanadi va butun ilova bo'ylab
/// mutatsiya tugmalarini bloklash/banner ko'rsatish uchun ishlatiladi
/// (MOBILE_APP_TZ.md 4.6, E_HISOB_FLUTTER_UI_UX_TZ.md 78-bo'lim).
class SubscriptionCubit extends Cubit<SubscriptionStatus> {
  SubscriptionCubit() : super(SubscriptionStatus.active);

  void updateFromHeader(String? header) {
    final status = subscriptionStatusFromHeader(header);
    if (status != state) emit(status);
  }

  void reset() => emit(SubscriptionStatus.active);

  bool get canMutate =>
      state == SubscriptionStatus.active || state == SubscriptionStatus.gracePeriod;
}
