import 'package:dio/dio.dart';

import 'package:edutool/core/errors/server_exception.dart';
import 'package:edutool/core/network/api_client.dart';
import 'package:edutool/core/network/base_response.dart';
import 'package:edutool/features/auth/data/models/login_request.dart';
import 'package:edutool/features/auth/data/models/login_response.dart';
import 'package:edutool/features/auth/domain/auth_repository.dart';

/// Concrete implementation of [AuthRepository] backed by Dio.
class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: LoginRequest(username: username, password: password).toJson(),
      );

      final base = BaseResponse<LoginResponse>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
      );

      if (!base.isSuccess || base.data == null) {
        throw ServerException(
          message: base.message,
          code: base.code,
          errors: base.errors,
        );
      }

      // Persist access token right after a successful login.
      await _apiClient.authInterceptor.saveAccessToken(base.data!.accessToken);

      return base.data!;
    } on DioException catch (e) {
      // Try to extract the server message from the response body.
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        throw ServerException(
          message: data['message'] as String? ?? 'Đăng nhập thất bại',
          code: e.response?.statusCode ?? 0,
          errors:
              (data['errors'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const [],
        );
      }
      throw ServerException(
        message: e.message ?? 'Lỗi kết nối đến server',
        code: e.response?.statusCode ?? 0,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } finally {
      await _apiClient.authInterceptor.clearAccessToken();
      _apiClient.cookieJar.deleteAll();
    }
  }
}
