import 'dart:async';

/// A simple event bus that broadcasts session-expired events.
///
/// When the refresh token fails, [TokenInterceptor] pushes an event here.
/// The app's router / top-level widget listens and navigates to Login.
class SessionManager {
  SessionManager._();
  static final SessionManager instance = SessionManager._();

  final _controller = StreamController<SessionEvent>.broadcast();

  Stream<SessionEvent> get onSessionEvent => _controller.stream;

  void expireSession() {
    _controller.add(SessionEvent.expired);
  }

  void dispose() {
    _controller.close();
  }
}

enum SessionEvent { expired }
