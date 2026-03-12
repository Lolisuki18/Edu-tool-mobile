import 'package:dio/dio.dart';

import 'package:edutool/core/errors/server_exception.dart';
import 'package:edutool/core/network/api_client.dart';
import 'package:edutool/core/network/base_response.dart';
import 'package:edutool/features/report/data/models/periodic_report_response.dart';
import 'package:edutool/features/report/domain/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ApiClient _apiClient;

  ReportRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<PeriodicReportResponse>> getActiveReports({
    required int courseId,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/periodic-reports/courses/$courseId/submissions/active',
        queryParameters: {'page': page, 'size': size},
      );

      final base = BaseResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );

      if (!base.isSuccess || base.data == null) {
        throw ServerException(
          message: base.message,
          code: base.code,
          errors: base.errors,
        );
      }

      // The paginated response has { "content": [...], "page": {...} }.
      final content = base.data!['content'] as List<dynamic>? ?? [];
      return content
          .map(
            (e) => PeriodicReportResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        throw ServerException(
          message:
              data['message'] as String? ?? 'Không thể tải danh sách báo cáo',
          code: e.response?.statusCode ?? 0,
          errors:
              (data['errors'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const [],
        );
      }
      throw ServerException(
        message: e.message ?? 'Không thể tải danh sách báo cáo',
        code: e.response?.statusCode ?? 0,
      );
    }
  }

  @override
  Future<List<PeriodicReportResponse>> getAllReports({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/periodic-reports',
        queryParameters: {'page': page, 'size': size},
      );

      final base = BaseResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );

      if (!base.isSuccess || base.data == null) {
        throw ServerException(
          message: base.message,
          code: base.code,
          errors: base.errors,
        );
      }

      final content = base.data!['content'] as List<dynamic>? ?? [];
      return content
          .map(
            (e) => PeriodicReportResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        throw ServerException(
          message:
              data['message'] as String? ?? 'Không thể tải danh sách báo cáo',
          code: e.response?.statusCode ?? 0,
          errors:
              (data['errors'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const [],
        );
      }
      throw ServerException(
        message: e.message ?? 'Không thể tải danh sách báo cáo',
        code: e.response?.statusCode ?? 0,
      );
    }
  }
}
