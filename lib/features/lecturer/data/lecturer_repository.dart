import 'package:dio/dio.dart';

import 'package:edutool/core/errors/server_exception.dart';
import 'package:edutool/core/network/api_client.dart';
import 'package:edutool/core/network/base_response.dart';
import 'package:edutool/shared/models/models.dart';
import 'package:edutool/features/project/data/models/group_detail_response.dart';
import 'package:edutool/features/project/data/models/github_repo_response.dart';
import 'package:edutool/features/project/data/models/project_response.dart';

/// Repository handling Lecturer-side API calls.
class LecturerRepository {
  final ApiClient _apiClient;

  LecturerRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// GET /api/users/me
  Future<User> getMe() async {
    try {
      final response = await _apiClient.dio.get('/api/users/me');
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
      final response = await _apiClient.dio.get('/courses');
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
        '/api/projects',
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
        '/api/github/repositories/course/$courseId/groups',
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
        '/api/github/repositories',
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
        '/api/github/repositories',
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
        '/api/github/repositories/$repoId/select',
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
        '/api/github/repositories/$repoId',
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
        '/api/github/repositories/project/$projectId/report/json',
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
        '/api/projects',
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
        '/api/enrollments',
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
        '/api/users/me/password',
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
