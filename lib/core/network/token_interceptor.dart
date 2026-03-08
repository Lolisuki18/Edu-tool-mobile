import 'dart:async';

import 'package:dio/dio.dart';
import 'package:edutool/core/network/auth_interceptor.dart';
import 'package:edutool/core/network/session_manager.dart';

/// Intercepts 401 responses, refreshes the access token via
/// `POST /auth/refresh` (cookie-based), and retries the original request.
///
/// Flow:
/// 1. Catch 401 Unauthorized.
/// 2. Lock [_dio] so all other in-flight requests queue up.
/// 3. Call `POST /auth/refresh` (refresh token travels as HttpOnly cookie).
/// 4a. If refresh succeeds → save new access token, unlock, retry queued requests.
/// 4b. If refresh fails   → clear tokens, fire [SessionEvent.expired], reject.
class TokenInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final AuthInterceptor _authInterceptor;

  /// A **separate** Dio instance used *only* for the refresh call,
  /// so we don't deadlock the main [_dio] (which is locked).
  late final Dio _refreshDio;

  TokenInterceptor({required Dio dio, required AuthInterceptor authInterceptor})
    : _dio = dio,
      _authInterceptor = authInterceptor {
    // Clone only the base options + cookie jar from the parent Dio.
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: _dio.options.baseUrl,
        connectTimeout: _dio.options.connectTimeout,
        receiveTimeout: _dio.options.receiveTimeout,
        contentType: _dio.options.contentType,
      ),
    );

    // Copy the cookie interceptor so the HttpOnly cookie is sent.
    for (final interceptor in _dio.interceptors) {
      if (interceptor is! AuthInterceptor && interceptor is! TokenInterceptor) {
        _refreshDio.interceptors.add(interceptor);
      }
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 Unauthorized.
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Don't retry refresh endpoint itself to avoid infinite loop.
    final requestPath = err.requestOptions.path;
    if (requestPath.startsWith('/auth/')) {
      return handler.next(err);
    }

    try {
      // ── Step 1: Refresh ────────────────────────────────────────────
      final refreshResponse = await _refreshDio.post('/auth/refresh');
      final data = refreshResponse.data as Map<String, dynamic>?;

      final isSuccess = data?['isSuccess'] as bool? ?? false;
      final newToken =
          (data?['data'] as Map<String, dynamic>?)?['accessToken'] as String?;

      if (!isSuccess || newToken == null || newToken.isEmpty) {
        await _onRefreshFailed(err, handler);
        return;
      }

      // ── Step 2: Persist the new token ──────────────────────────────
      await _authInterceptor.saveAccessToken(newToken);

      // ── Step 3: Retry the original failed request ──────────────────
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newToken';

      final retryResponse = await _dio.fetch(retryOptions);
      return handler.resolve(retryResponse);
    } on DioException {
      await _onRefreshFailed(err, handler);
    }
  }

  /// Cleanup when the refresh token itself is invalid / expired.
  Future<void> _onRefreshFailed(
    DioException originalError,
    ErrorInterceptorHandler handler,
  ) async {
    await _authInterceptor.clearAccessToken();
    SessionManager.instance.expireSession();
    handler.reject(originalError);
  }
}
