import 'package:dio/dio.dart';

import 'package:edutool/core/constants/api_endpoints.dart';
import 'package:edutool/core/errors/server_exception.dart';
import 'package:edutool/core/network/api_client.dart';
import 'package:edutool/core/network/base_response.dart';
import 'package:edutool/shared/models/models.dart';
import 'package:edutool/features/project/data/models/group_detail_response.dart';
import 'package:edutool/features/project/data/models/github_repo_response.dart';
import 'package:edutool/features/project/data/models/project_response.dart';
import 'package:edutool/features/report/data/models/periodic_report_response.dart';

/// Repository handling Lecturer-side API calls.
class LecturerRepository {
  final ApiClient _apiClient;

  LecturerRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// GET /api/users/me
  Future<User> getMe() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.me);
      final base = BaseResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );
      if (!base.isSuccess || base.data == null) {
        throw ServerException(message: base.message, code: base.code);
      }
      return User.fromJson(base.data!);
    } on DioException catch (e) {
      throw _mapDio(e, 'Không thể tải thông tin người dùng');
    }
  }

  /// GET /courses — get all courses (lecturer will filter their own)
  Future<List<Course>> getCourses() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.courses);
      final base = BaseResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as List<dynamic>,
      );
      if (!base.isSuccess || base.data == null) {
        throw ServerException(message: base.message, code: base.code);
      }
      return base.data!
          .map((e) => Course.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDio(e, 'Không thể tải danh sách môn học');
    }
  }

  /// GET /api/projects?courseId={courseId}
  Future<List<ProjectResponse>> getProjectsByCourse(int courseId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.projects,
        queryParameters: {'courseId': courseId},
      );
      final base = BaseResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as List<dynamic>,
      );
      if (!base.isSuccess || base.data == null) {
        throw ServerException(message: base.message, code: base.code);
      }
      return base.data!
          .map((e) => ProjectResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDio(e, 'Không thể tải danh sách project');
    }
  }

  /// GET /api/github/repositories/course/{courseId}/groups
  Future<List<GroupDetailResponse>> getGroupsByCourse(int courseId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.repositoriesByCourse(courseId.toString()),
      );
      final base = BaseResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as List<dynamic>,
      );
      if (!base.isSuccess || base.data == null) {
        throw ServerException(message: base.message, code: base.code);
      }
      return base.data!
          .map((e) => GroupDetailResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDio(e, 'Không thể tải thông tin nhóm');
    }
  }

  /// GET /api/github/repositories?courseId={courseId}
  Future<List<GithubRepoResponse>> getReposByCourse(int courseId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.repositories,
        queryParameters: {'courseId': courseId},
      );
      final base = BaseResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as List<dynamic>,
      );
      if (!base.isSuccess || base.data == null) {
        throw ServerException(message: base.message, code: base.code);
      }
      return base.data!
          .map((e) => GithubRepoResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDio(e, 'Không thể tải danh sách repository');
    }
  }

  /// POST /api/github/repositories
  Future<GithubRepoResponse> submitRepo({
    required int projectId,
    required String repoUrl,
    String? repoName,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.repositories,
        data: {
          'projectId': projectId,
          'repoUrl': repoUrl,
          if (repoName != null) 'repoName': repoName,
        },
      );
      final base = BaseResponse<GithubRepoResponse>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => GithubRepoResponse.fromJson(json as Map<String, dynamic>),
      );
      if (!base.isSuccess || base.data == null) {
        throw ServerException(message: base.message, code: base.code);
      }
      return base.data!;
    } on DioException catch (e) {
      throw _mapDio(e, 'Không thể nộp repository');
    }
  }

  /// PATCH /api/github/repositories/{repoId}/select
  Future<GithubRepoResponse> selectRepo(int repoId) async {
    try {
      final response = await _apiClient.dio.patch(
        ApiEndpoints.repositorySelect(repoId.toString()),
      );
      final base = BaseResponse<GithubRepoResponse>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => GithubRepoResponse.fromJson(json as Map<String, dynamic>),
      );
      if (!base.isSuccess || base.data == null) {
        throw ServerException(message: base.message, code: base.code);
      }
      return base.data!;
    } on DioException catch (e) {
      throw _mapDio(e, 'Không thể chọn repository');
    }
  }

  /// DELETE /api/github/repositories/{repoId}
  Future<void> deleteRepo(int repoId) async {
    try {
      final response = await _apiClient.dio.delete(
        ApiEndpoints.repositoryById(repoId.toString()),
      );
      final base = BaseResponse<dynamic>.fromJson(
        response.data as Map<String, dynamic>,
        null,
      );
      if (!base.isSuccess) {
        throw ServerException(message: base.message, code: base.code);
      }
    } on DioException catch (e) {
      throw _mapDio(e, 'Không thể xóa repository');
    }
  }

  /// GET /api/github/repositories/project/{projectId}/report/json
  Future<Map<String, dynamic>> getCommitReport({
    required int projectId,
    String? since,
    String? until,
  }) async {
    try {
      final qp = <String, dynamic>{};
      if (since != null) qp['since'] = since;
      if (until != null) qp['until'] = until;

      final response = await _apiClient.dio.get(
        ApiEndpoints.reportJson(projectId.toString()),
        queryParameters: qp,
      );
      final base = BaseResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );
      if (!base.isSuccess || base.data == null) {
        throw ServerException(message: base.message, code: base.code);
      }
      return base.data!;
    } on DioException catch (e) {
      throw _mapDio(e, 'Không thể tải báo cáo commit');
    }
  }

  /// GET /api/github/repositories/project/{projectId}/report/storage-url
  /// Returns the URL of the report stored on Supabase
  Future<String> getReportStorageUrl(int projectId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.reportStorageUrl(projectId.toString()),
      );
      final base = BaseResponse<String>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as String,
      );
      if (!base.isSuccess || base.data == null) {
        throw ServerException(message: base.message, code: base.code);
      }
      return base.data!;
    } on DioException catch (e) {
      throw _mapDio(e, 'Không thể lấy link tải báo cáo');
    }
  }

  /// POST /api/projects
  Future<ProjectResponse> createProject({
    required String projectCode,
    required String projectName,
    required int courseId,
    String? description,
    String? technologies,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.projects,
        data: {
          'projectCode': projectCode,
          'projectName': projectName,
          'courseId': courseId,
          if (description != null) 'description': description,
          if (technologies != null) 'technologies': technologies,
        },
      );
      final base = BaseResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );
      if (!base.isSuccess || base.data == null) {
        throw ServerException(message: base.message, code: base.code);
      }
      return ProjectResponse.fromJson(base.data!);
    } on DioException catch (e) {
      throw _mapDio(e, 'Không thể tạo project');
    }
  }

  /// GET /api/enrollments?courseId={courseId}
  Future<List<Map<String, dynamic>>> getEnrollmentsByCourse(
    int courseId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.enrollments,
        queryParameters: {'courseId': courseId},
      );
      final base = BaseResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as List<dynamic>,
      );
      if (!base.isSuccess || base.data == null) {
        throw ServerException(message: base.message, code: base.code);
      }
      return base.data!.map((e) => e as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      throw _mapDio(e, 'Không thể tải danh sách sinh viên');
    }
  }

  /// PUT /api/users/me/password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        ApiEndpoints.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
      final base = BaseResponse<dynamic>.fromJson(
        response.data as Map<String, dynamic>,
        null,
      );
      if (!base.isSuccess) {
        throw ServerException(message: base.message, code: base.code);
      }
    } on DioException catch (e) {
      throw _mapDio(e, 'Không thể đổi mật khẩu');
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Periodic Reports
  // ═══════════════════════════════════════════════════════════════════

  /// GET /api/periodic-reports/courses/{courseId}
  Future<List<PeriodicReportResponse>> getPeriodicReportsByCourse(
    int courseId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.periodicReportsByCourse(courseId.toString()),
      );
      final base = BaseResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );
      if (!base.isSuccess || base.data == null) {
        throw ServerException(message: base.message, code: base.code);
      }
      final content = base.data!['content'] as List<dynamic>? ?? [];
      return content
          .map(
            (e) => PeriodicReportResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw _mapDio(e, 'Không thể tải báo cáo định kỳ');
    }
  }

  /// POST /api/periodic-reports
  Future<PeriodicReportResponse> createPeriodicReport({
    required int courseId,
    required String reportFromDate,
    required String reportToDate,
    required String submitStartAt,
    required String submitEndAt,
    String? description,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.periodicReports,
        data: {
          'courseId': courseId,
          'reportFromDate': reportFromDate,
          'reportToDate': reportToDate,
          'submitStartAt': submitStartAt,
          'submitEndAt': submitEndAt,
          if (description != null) 'description': description,
        },
      );
      final base = BaseResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );
      if (!base.isSuccess || base.data == null) {
        throw ServerException(message: base.message, code: base.code);
      }
      return PeriodicReportResponse.fromJson(base.data!);
    } on DioException catch (e) {
      throw _mapDio(e, 'Không thể tạo báo cáo');
    }
  }

  /// DELETE /api/periodic-reports/{reportId}
  Future<void> deletePeriodicReport(int reportId) async {
    try {
      final response = await _apiClient.dio.delete(
        ApiEndpoints.periodicReportById(reportId.toString()),
      );
      final base = BaseResponse<dynamic>.fromJson(
        response.data as Map<String, dynamic>,
        null,
      );
      if (!base.isSuccess) {
        throw ServerException(message: base.message, code: base.code);
      }
    } on DioException catch (e) {
      throw _mapDio(e, 'Không thể xóa báo cáo');
    }
  }

  /// PUT /api/enrollments/{id}
  Future<void> assignStudentToGroup({
    required int enrollmentId,
    required int projectId,
    required int groupNumber,
    String? role,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        ApiEndpoints.enrollmentById(enrollmentId.toString()),
        data: {
          'projectId': projectId,
          'groupNumber': groupNumber,
          if (role != null) 'roleInProject': role,
        },
      );
      final base = BaseResponse<dynamic>.fromJson(
        response.data as Map<String, dynamic>,
        null,
      );
      if (!base.isSuccess) {
        throw ServerException(message: base.message, code: base.code);
      }
    } on DioException catch (e) {
      throw _mapDio(e, 'Không thể gán sinh viên vào nhóm');
    }
  }

  /// PUT /api/users/{id}
  Future<User> updateMe(String userId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put(
        ApiEndpoints.userById(userId),
        data: data,
      );
      final base = BaseResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );
      if (!base.isSuccess || base.data == null) {
        throw ServerException(message: base.message, code: base.code);
      }
      return User.fromJson(base.data!);
    } on DioException catch (e) {
      throw _mapDio(e, 'Không thể cập nhật thông tin');
    }
  }

  ServerException _mapDio(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return ServerException(
        message: data['message'] as String? ?? fallback,
        code: e.response?.statusCode ?? 0,
      );
    }
    return ServerException(message: e.message ?? fallback, code: 0);
  }
}
