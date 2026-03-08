import 'package:dio/dio.dart';

import 'package:edutool/core/errors/server_exception.dart';
import 'package:edutool/core/network/api_client.dart';
import 'package:edutool/core/network/base_response.dart';
import 'package:edutool/features/project/data/models/github_repo_response.dart';
import 'package:edutool/features/project/data/models/group_detail_response.dart';
import 'package:edutool/features/project/data/models/project_response.dart';
import 'package:edutool/features/project/data/models/submit_repo_request.dart';
import 'package:edutool/features/project/domain/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ApiClient _apiClient;

  ProjectRepositoryImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  // ── Projects ───────────────────────────────────────────────────────────────

  @override
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
        throw ServerException(
          message: base.message,
          code: base.code,
          errors: base.errors,
        );
      }

      return base.data!
          .map((e) => ProjectResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e, 'Không thể tải danh sách project');
    }
  }

  // ── Groups (members + repos per project in a course) ───────────────────────

  @override
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
        throw ServerException(
          message: base.message,
          code: base.code,
          errors: base.errors,
        );
      }

      return base.data!
          .map((e) => GroupDetailResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e, 'Không thể tải thông tin nhóm');
    }
  }

  // ── GitHub Repositories ────────────────────────────────────────────────────

  @override
  Future<GithubRepoResponse> submitRepo({
    required int projectId,
    required String repoUrl,
    String? repoName,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/github/repositories',
        data: SubmitRepoRequest(
          projectId: projectId,
          repoUrl: repoUrl,
          repoName: repoName,
        ).toJson(),
      );

      final base = BaseResponse<GithubRepoResponse>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => GithubRepoResponse.fromJson(json as Map<String, dynamic>),
      );

      if (!base.isSuccess || base.data == null) {
        throw ServerException(
          message: base.message,
          code: base.code,
          errors: base.errors,
        );
      }

      return base.data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Không thể nộp repository');
    }
  }

  @override
  Future<List<GithubRepoResponse>> getReposByProject(int projectId) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/github/repositories',
        queryParameters: {'projectId': projectId},
      );

      final base = BaseResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as List<dynamic>,
      );

      if (!base.isSuccess || base.data == null) {
        throw ServerException(
          message: base.message,
          code: base.code,
          errors: base.errors,
        );
      }

      return base.data!
          .map((e) => GithubRepoResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e, 'Không thể tải danh sách repository');
    }
  }

  @override
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
        throw ServerException(
          message: base.message,
          code: base.code,
          errors: base.errors,
        );
      }

      return base.data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Không thể chọn repository');
    }
  }

  // ── Export commit report ───────────────────────────────────────────────────

  @override
  Future<String> exportCommitReport({
    required int projectId,
    String? since,
    String? until,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (since != null) queryParams['since'] = since;
      if (until != null) queryParams['until'] = until;

      final response = await _apiClient.dio.get(
        '/api/github/repositories/project/$projectId/report/json',
        queryParameters: queryParams,
      );

      final base = BaseResponse<dynamic>.fromJson(
        response.data as Map<String, dynamic>,
        null,
      );

      if (!base.isSuccess) {
        throw ServerException(
          message: base.message,
          code: base.code,
          errors: base.errors,
        );
      }

      return base.message;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Không thể xuất báo cáo commit');
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  ServerException _mapDioError(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return ServerException(
        message: data['message'] as String? ?? fallback,
        code: e.response?.statusCode ?? 0,
        errors:
            (data['errors'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );
    }
    return ServerException(
      message: e.message ?? fallback,
      code: e.response?.statusCode ?? 0,
    );
  }
}
