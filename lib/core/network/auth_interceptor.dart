import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Attaches the stored access token to every request except `/auth/*` paths.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  static const _storageKey = 'access_token';

  AuthInterceptor({required FlutterSecureStorage secureStorage})
    : _secureStorage = secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth endpoints – they don't need a Bearer token.
    final path = options.path;
    if (path.startsWith('/api/auth/') || path.startsWith('/api/auth')) {
      return handler.next(options);
    }

    final token = await _secureStorage.read(key: _storageKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  // ── helpers for other layers ──────────────────────────────────────────

  Future<String?> getAccessToken() => _secureStorage.read(key: _storageKey);

  Future<void> saveAccessToken(String token) =>
      _secureStorage.write(key: _storageKey, value: token);

  Future<void> clearAccessToken() => _secureStorage.delete(key: _storageKey);
}
