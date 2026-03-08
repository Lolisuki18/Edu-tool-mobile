import 'package:dio/dio.dart';

import 'package:edutool/core/errors/server_exception.dart';
import 'package:edutool/core/network/api_client.dart';
import 'package:edutool/core/network/base_response.dart';
import 'package:edutool/shared/models/models.dart';
import 'package:edutool/features/project/data/models/group_detail_response.dart';
import 'package:edutool/features/report/data/models/periodic_report_response.dart';

/// Repository handling Student-side API calls.
class StudentRepository {
  final ApiClient _apiClient;

  StudentRepository({required ApiClient apiClient}) : _apiClient = apiClient;

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

  /// GET /api/enrollments?studentId={studentId}
  Future<List<EnrollmentDetail>> getMyEnrollments(String studentId) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/enrollments',
        queryParameters: {'studentId': studentId},
      );
      final base = BaseResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as List<dynamic>,
      );
      if (!base.isSuccess || base.data == null) {
        throw ServerException(message: base.message, code: base.code);
      }
      return base.data!
          .map((e) => EnrollmentDetail.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDio(e, 'Không thể tải danh sách môn học');
    }
  }

  /// GET /api/students?keyword={keyword} — to find the current student profile
  Future<Student?> getStudentByUserId(String userId) async {
    try {
      final response = await _apiClient.dio.get('/api/students');
      final base = BaseResponse<dynamic>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json,
      );
      if (!base.isSuccess || base.data == null) return null;

      // The API may return paginated data with 'content' or a list
      List<dynamic> items;
      if (base.data is Map && (base.data as Map).containsKey('content')) {
        items = (base.data as Map)['content'] as List<dynamic>;
      } else if (base.data is List) {
        items = base.data as List<dynamic>;
      } else {
        return null;
      }

      for (final item in items) {
        final map = item as Map<String, dynamic>;
        final user = map['user'] as Map<String, dynamic>?;
        if (user != null && user['userId']?.toString() == userId) {
          return Student.fromJson(map);
        }
      }
      return null;
    } on DioException {
      return null;
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

  /// GET /api/periodic-reports/courses/{courseId}/submissions/active
  Future<List<PeriodicReportResponse>> getActiveReports(int courseId) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/periodic-reports/courses/$courseId/submissions/active',
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
      throw _mapDio(e, 'Không thể tải báo cáo');
    }
  }

  /// POST /api/github/repositories — submit a new repo
  Future<void> submitRepo({
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
      final base = BaseResponse<dynamic>.fromJson(
        response.data as Map<String, dynamic>,
        null,
      );
      if (!base.isSuccess) {
        throw ServerException(message: base.message, code: base.code);
      }
    } on DioException catch (e) {
      throw _mapDio(e, 'Không thể nộp repository');
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

/// Detailed enrollment response from the API (includes student/course names).
class EnrollmentDetail {
  final int enrollmentId;
  final int studentId;
  final String studentCode;
  final String studentName;
  final int courseId;
  final String courseCode;
  final String courseName;
  final int? projectId;
  final String? projectCode;
  final String? projectName;
  final String? roleInProject;
  final int? groupNumber;
  final String? enrolledAt;
  final String? deletedAt;
  final String? removedFromProjectAt;

  const EnrollmentDetail({
    required this.enrollmentId,
    required this.studentId,
    required this.studentCode,
    required this.studentName,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    this.projectId,
    this.projectCode,
    this.projectName,
    this.roleInProject,
    this.groupNumber,
    this.enrolledAt,
    this.deletedAt,
    this.removedFromProjectAt,
  });

  factory EnrollmentDetail.fromJson(Map<String, dynamic> json) {
    return EnrollmentDetail(
      enrollmentId: json['enrollmentId'] as int? ?? 0,
      studentId: json['studentId'] as int? ?? 0,
      studentCode: json['studentCode'] as String? ?? '',
      studentName: json['studentName'] as String? ?? '',
      courseId: json['courseId'] as int? ?? 0,
      courseCode: json['courseCode'] as String? ?? '',
      courseName: json['courseName'] as String? ?? '',
      projectId: json['projectId'] as int?,
      projectCode: json['projectCode'] as String?,
      projectName: json['projectName'] as String?,
      roleInProject: json['roleInProject'] as String?,
      groupNumber: json['groupNumber'] as int?,
      enrolledAt: json['enrolledAt'] as String?,
      deletedAt: json['deletedAt'] as String?,
      removedFromProjectAt: json['removedFromProjectAt'] as String?,
    );
  }

  bool get hasProject => projectId != null && removedFromProjectAt == null;
}
