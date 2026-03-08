import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_interceptor.dart';
import 'token_interceptor.dart';

/// Centralised Dio client for the EduTool app.
///
/// Usage (with get_it / injectable):
/// ```dart
/// final apiClient = ApiClient(baseUrl: 'http://10.0.2.2:8080');
/// final response = await apiClient.dio.get('/api/users/me');
/// ```
class ApiClient {
  late final Dio dio;
  late final AuthInterceptor authInterceptor;
  late final CookieJar cookieJar;

  ApiClient({required String baseUrl}) {
    // ── Cookie jar for HttpOnly refresh token ────────────────────────
    cookieJar = CookieJar();

    // ── Dio base options ─────────────────────────────────────────────
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    // ── Interceptors (order matters) ─────────────────────────────────
    // 1. Cookie manager – ensures refresh-token cookie is sent/received.
    dio.interceptors.add(CookieManager(cookieJar));

    // 2. Auth interceptor – attaches access token to non-auth requests.
    authInterceptor = AuthInterceptor(
      secureStorage: const FlutterSecureStorage(),
    );
    dio.interceptors.add(authInterceptor);

    // 3. Token interceptor – handles 401 → refresh → retry.
    //    Uses QueuedInterceptor so concurrent 401s don't cause multiple refreshes.
    dio.interceptors.add(
      TokenInterceptor(dio: dio, authInterceptor: authInterceptor),
    );
  }
}
