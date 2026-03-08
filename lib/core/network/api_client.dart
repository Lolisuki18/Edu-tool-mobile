import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_interceptor.dart';
import 'token_interceptor.dart';

// Conditional imports — only available on native (dart:io) platforms.
// On web these are never used.
import 'cookie_helper_stub.dart'
    if (dart.library.io) 'cookie_helper_native.dart'
    as cookie_helper;

/// Centralised Dio client for the EduTool app.
///
/// Usage:
/// ```dart
/// final apiClient = ApiClient(baseUrl: 'http://10.0.2.2:8080');
/// final response = await apiClient.dio.get('/api/users/me');
/// ```
class ApiClient {
  late final Dio dio;
  late final AuthInterceptor authInterceptor;

  ApiClient({required String baseUrl}) {
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
    // 1. Cookie manager – native only (on web the browser handles cookies).
    if (!kIsWeb) {
      cookie_helper.addCookieInterceptor(dio);
    }

    // 2. Auth interceptor – attaches access token to non-auth requests.
    authInterceptor = AuthInterceptor(
      secureStorage: const FlutterSecureStorage(),
    );
    dio.interceptors.add(authInterceptor);

    // 3. Token interceptor – handles 401 → refresh → retry.
    dio.interceptors.add(
      TokenInterceptor(dio: dio, authInterceptor: authInterceptor),
    );
  }
}
