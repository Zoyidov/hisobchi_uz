import 'dart:async';

/// 401/owner-context xatoliklarini network qatlamidan UI/BLoC qatlamiga
/// uzatuvchi voqea-shinasi — interceptor to'g'ridan-to'g'ri Cubit/Router'ga
/// bog'lanmasligi uchun (MOBILE_APP_TZ.md 4.4, 6.3).
sealed class AuthSessionEvent {
  const AuthSessionEvent();
}

class UnauthenticatedEvent extends AuthSessionEvent {
  const UnauthenticatedEvent({this.otherDevice = false});
  final bool otherDevice;
}

class OwnerContextInvalidEvent extends AuthSessionEvent {
  const OwnerContextInvalidEvent();
}

class AuthSessionController {
  final _controller = StreamController<AuthSessionEvent>.broadcast();

  Stream<AuthSessionEvent> get events => _controller.stream;

  void notifyUnauthenticated({bool otherDevice = false}) {
    _controller.add(UnauthenticatedEvent(otherDevice: otherDevice));
  }

  void notifyOwnerContextInvalid() {
    _controller.add(const OwnerContextInvalidEvent());
  }

  void dispose() => _controller.close();
}
