import 'dart:async';

import 'package:dio/dio.dart';
import 'package:edutool/core/network/auth_interceptor.dart';
import 'package:edutool/core/network/session_manager.dart';
import 'package:edutool/core/constants/api_endpoints.dart';

/// Intercepts 401/403 responses, refreshes the access token via
/// `POST /api/auth/refresh` (body + cookie), and retries the original request.
///
/// Flow:
/// 1. Catch 401 Unauthorized or 403 Forbidden.
/// 2. QueuedInterceptor handles locking and queuing automatically.
/// 3. Call `POST /api/auth/refresh` with refresh token in body.
/// 4a. If refresh succeeds → save new access token, retry queued requests.
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
    final statusCode = err.response?.statusCode;
    // Handle both 401 and 403, as backend might use either for expired tokens.
    if (statusCode != 401 && statusCode != 403) {
      return handler.next(err);
    }

    // Don't retry refresh or login endpoints to avoid infinite loops or unnecessary overhead.
    final requestPath = err.requestOptions.path;
    if (requestPath.contains(ApiEndpoints.refresh) || 
        requestPath.contains(ApiEndpoints.login)) {
      return handler.next(err);
    }

    try {
      // ── Step 1: Refresh ────────────────────────────────────────────
      final refreshToken = await _authInterceptor.getRefreshToken();
      
      final refreshResponse = await _refreshDio.post(
        ApiEndpoints.refresh,
        data: refreshToken != null ? {'refreshToken': refreshToken} : null,
      );
      
      final data = refreshResponse.data as Map<String, dynamic>?;

      final isSuccess = data?['isSuccess'] as bool? ?? false;
      final responseData = data?['data'] as Map<String, dynamic>?;
      final newToken = responseData?['accessToken'] as String?;
      final newRefreshToken = responseData?['refreshToken'] as String?;

      if (!isSuccess || newToken == null || newToken.isEmpty) {
        await _onRefreshFailed(err, handler);
        return;
      }

      // ── Step 2: Persist the new tokens ──────────────────────────────
      await _authInterceptor.saveAccessToken(newToken);
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await _authInterceptor.saveRefreshToken(newRefreshToken);
      }

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
    await _authInterceptor.clearAllTokens();
    SessionManager.instance.expireSession();
    handler.reject(originalError);
  }
}
