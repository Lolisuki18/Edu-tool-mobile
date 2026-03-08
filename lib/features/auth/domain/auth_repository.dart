import 'package:edutool/features/auth/data/models/login_response.dart';

/// Contract for auth operations. Implementation lives in `data/`.
abstract class AuthRepository {
  /// Logs in with [username] (or email) and [password].
  Future<LoginResponse> login({
    required String username,
    required String password,
  });

  /// Registers a new account.
  Future<void> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
  });

  /// Logs the user out (calls `POST /auth/logout`, clears local tokens).
  Future<void> logout();
}
