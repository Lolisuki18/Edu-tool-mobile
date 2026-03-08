import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

/// Native implementation — adds a [CookieManager] so the HttpOnly
/// refresh-token cookie is stored and sent automatically.
void addCookieInterceptor(Dio dio) {
  final cookieJar = CookieJar();
  dio.interceptors.add(CookieManager(cookieJar));
}
