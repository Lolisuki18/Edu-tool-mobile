import 'package:dio/dio.dart';

import 'package:edutool/core/constants/api_endpoints.dart';
import 'package:edutool/core/errors/server_exception.dart';
import 'package:edutool/core/network/api_client.dart';
import 'package:edutool/core/network/base_response.dart';
import 'package:edutool/shared/models/models.dart';

/// Repository handling all Admin CRUD API calls.
class AdminRepository {
  final ApiClient _apiClient;

  AdminRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // ═══════════════════════════════════════════════════════════════════
  // Users
  // ═══════════════════════════════════════════════════════════════════

  Future<User> getMe() async {
    final data = await _getOne(ApiEndpoints.me);
    return User.fromJson(data);
  }

  Future<PaginatedData<User>> getUsers({
    int page = 0,
    int size = 10,
    String? search,
  }) async {
    return _getPaginated(
      ApiEndpoints.users,
      page: page,
      size: size,
      search: search,
      fromJson: User.fromJson,
    );
  }

  Future<User> getUserById(String id) async {
    final data = await _getOne(ApiEndpoints.userById(id));
    return User.fromJson(data);
  }

  Future<User> createUser(Map<String, dynamic> body) async {
    final data = await _post(ApiEndpoints.users, body);
    return User.fromJson(data);
  }

  Future<User> updateUser(String id, Map<String, dynamic> body) async {
    final data = await _put(ApiEndpoints.userById(id), body);
    return User.fromJson(data);
  }

  Future<void> deleteUser(String id) async => _delete(ApiEndpoints.userById(id));

  // ═══════════════════════════════════════════════════════════════════
  // Students
  // ═══════════════════════════════════════════════════════════════════

  Future<PaginatedData<Student>> getStudents({
    int page = 0,
    int size = 10,
    String? search,
  }) async {
    return _getPaginated(
      ApiEndpoints.students,
      page: page,
      size: size,
      search: search,
      fromJson: Student.fromJson,
    );
  }

  Future<Student> getStudentById(String id) async {
    final data = await _getOne(ApiEndpoints.studentById(id));
    return Student.fromJson(data);
  }

  Future<Student> createStudent(Map<String, dynamic> body) async {
    final data = await _post(ApiEndpoints.students, body);
    return Student.fromJson(data);
  }

  Future<Student> updateStudent(String id, Map<String, dynamic> body) async {
    final data = await _put(ApiEndpoints.studentById(id), body);
    return Student.fromJson(data);
  }

  Future<void> deleteStudent(String id) async =>
      _delete(ApiEndpoints.studentById(id));

  // ═══════════════════════════════════════════════════════════════════
  // Lecturers
  // ═══════════════════════════════════════════════════════════════════

  Future<PaginatedData<Lecturer>> getLecturers({
    int page = 0,
    int size = 10,
    String? search,
  }) async {
    return _getPaginated(
      ApiEndpoints.lecturers,
      page: page,
      size: size,
      search: search,
      fromJson: Lecturer.fromJson,
    );
  }

  Future<Lecturer> createLecturer(Map<String, dynamic> body) async {
    final data = await _post(ApiEndpoints.lecturers, body);
    return Lecturer.fromJson(data);
  }

  Future<Lecturer> updateLecturer(String id, Map<String, dynamic> body) async {
    final data = await _put(ApiEndpoints.lecturerById(id), body);
    return Lecturer.fromJson(data);
  }

  Future<void> deleteLecturer(String id) async =>
      _delete(ApiEndpoints.lecturerById(id));

  // ═══════════════════════════════════════════════════════════════════
  // Semesters
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Semester>> getSemesters() async {
    final list = await _getList(ApiEndpoints.semesters);
    return list.map((e) => Semester.fromJson(e)).toList();
  }

  Future<Semester> createSemester(Map<String, dynamic> body) async {
    final data = await _post(ApiEndpoints.semesters, body);
    return Semester.fromJson(data);
  }

  Future<Semester> updateSemester(String id, Map<String, dynamic> body) async {
    final data = await _put(ApiEndpoints.semesterById(id), body);
    return Semester.fromJson(data);
  }

  Future<void> deleteSemester(String id) async =>
      _delete(ApiEndpoints.semesterById(id));

  // ═══════════════════════════════════════════════════════════════════
  // Courses
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Course>> getCourses() async {
    final list = await _getList(ApiEndpoints.courses);
    return list.map((e) => Course.fromJson(e)).toList();
  }

  Future<Course> createCourse(Map<String, dynamic> body) async {
    final data = await _post(ApiEndpoints.courses, body);
    return Course.fromJson(data);
  }

  Future<Course> updateCourse(String id, Map<String, dynamic> body) async {
    final data = await _put(ApiEndpoints.courseById(id), body);
    return Course.fromJson(data);
  }

  Future<void> deleteCourse(String id) async =>
      _delete(ApiEndpoints.courseById(id));

  // ═══════════════════════════════════════════════════════════════════
  // Enrollments
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Enrollment>> getEnrollments({required int courseId}) async {
    final list = await _getList(
      ApiEndpoints.enrollments,
      queryParameters: {'courseId': courseId},
    );
    return list.map((e) => Enrollment.fromJson(e)).toList();
  }

  Future<Enrollment> createEnrollment(Map<String, dynamic> body) async {
    final data = await _post(ApiEndpoints.enrollments, body);
    return Enrollment.fromJson(data);
  }

  Future<Enrollment> updateEnrollment(
    String id,
    Map<String, dynamic> body,
  ) async {
    final data = await _put(ApiEndpoints.enrollmentById(id), body);
    return Enrollment.fromJson(data);
  }

  Future<void> deleteEnrollment(String id) async =>
      _delete(ApiEndpoints.enrollmentById(id));

  // ═══════════════════════════════════════════════════════════════════
  // Projects
  // ═══════════════════════════════════════════════════════════════════

  Future<PaginatedData<Project>> getProjects({
    int page = 0,
    int size = 10,
    int? courseId,
  }) async {
    final qp = <String, dynamic>{'page': page, 'size': size};
    if (courseId != null) qp['courseId'] = courseId;
    return _getPaginated(
      ApiEndpoints.projects,
      page: page,
      size: size,
      extra: qp,
      fromJson: Project.fromJson,
    );
  }

  Future<Project> createProject(Map<String, dynamic> body) async {
    final data = await _post(ApiEndpoints.projects, body);
    return Project.fromJson(data);
  }

  Future<Project> updateProject(String id, Map<String, dynamic> body) async {
    final data = await _put(ApiEndpoints.projectById(id), body);
    return Project.fromJson(data);
  }

  Future<void> deleteProject(String id) async =>
      _delete(ApiEndpoints.projectById(id));

  // ═══════════════════════════════════════════════════════════════════
  // Change password
  // ═══════════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════════
  // Dashboard summary
  // ═══════════════════════════════════════════════════════════════════

  Future<Map<String, int>> getDashboardCounts() async {
    final results = await Future.wait([
      _getCountOrList(ApiEndpoints.users, paginated: true),
      _getCountOrList(ApiEndpoints.students, paginated: true),
      _getCountOrList(ApiEndpoints.lecturers, paginated: true),
      _getCountOrList(ApiEndpoints.courses, paginated: false),
      _getCountOrList(ApiEndpoints.semesters, paginated: false),
      _getCountOrList(ApiEndpoints.projects, paginated: true),
    ]);
    return {
      'users': results[0],
      'students': results[1],
      'lecturers': results[2],
      'courses': results[3],
      'semesters': results[4],
      'projects': results[5],
    };
  }

  // ═══════════════════════════════════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> _getOne(String path) async {
    try {
      final response = await _apiClient.dio.get(path);
      final base = BaseResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );
      if (!base.isSuccess || base.data == null) {
        throw ServerException(message: base.message, code: base.code);
      }
      return base.data!;
    } on DioException catch (e) {
      throw _mapDio(e, 'Request failed');
    }
  }

  Future<List<Map<String, dynamic>>> _getList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        path,
        queryParameters: queryParameters,
      );

      final raw = response.data;

      // Raw JSON array response
      if (raw is List) {
        return raw.map((e) => e as Map<String, dynamic>).toList();
      }

      // BaseResponse wrapper
      final base = BaseResponse<dynamic>.fromJson(
        raw as Map<String, dynamic>,
        (json) => json,
      );
      if (!base.isSuccess) {
        throw ServerException(message: base.message, code: base.code);
      }

      final data = base.data;
      if (data is List) {
        return data.map((e) => e as Map<String, dynamic>).toList();
      }

      return [];
    } on DioException catch (e) {
      throw _mapDio(e, 'Request failed');
    }
  }

  Future<PaginatedData<T>> _getPaginated<T>(
    String path, {
    required int page,
    required int size,
    String? search,
    Map<String, dynamic>? extra,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final qp = extra ?? <String, dynamic>{};
      qp['page'] = page;
      qp['size'] = size;
      if (search != null && search.isNotEmpty) qp['search'] = search;

      final response = await _apiClient.dio.get(path, queryParameters: qp);
      final raw = response.data as Map<String, dynamic>;

      // Support flat Spring Page format
      if (raw.containsKey('content')) {
        return PaginatedData<T>.fromJson(
          raw,
          (o) => fromJson(o as Map<String, dynamic>),
        );
      }

      // BaseResponse wrapper format
      final base = BaseResponse<dynamic>.fromJson(raw, (json) => json);
      if (!base.isSuccess) {
        throw ServerException(message: base.message, code: base.code);
      }

      final data = base.data;
      if (data is List) {
        final items = data
            .map((e) => fromJson(e as Map<String, dynamic>))
            .toList();
        return PaginatedData<T>(
          content: items,
          page: PageInfo(
            pageNumber: 0,
            totalPages: 1,
            totalElements: items.length,
          ),
        );
      }
      if (data is Map<String, dynamic> && data.containsKey('content')) {
        return PaginatedData<T>.fromJson(
          data,
          (o) => fromJson(o as Map<String, dynamic>),
        );
      }

      return PaginatedData<T>(
        content: const [],
        page: const PageInfo(pageNumber: 0, totalPages: 1, totalElements: 0),
      );
    } on DioException catch (e) {
      throw _mapDio(e, 'Request failed');
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _apiClient.dio.post(path, data: body);
      final base = BaseResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );
      if (!base.isSuccess || base.data == null) {
        throw ServerException(message: base.message, code: base.code);
      }
      return base.data!;
    } on DioException catch (e) {
      throw _mapDio(e, 'Request failed');
    }
  }

  Future<Map<String, dynamic>> _put(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _apiClient.dio.put(path, data: body);
      final base = BaseResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );
      if (!base.isSuccess || base.data == null) {
        throw ServerException(message: base.message, code: base.code);
      }
      return base.data!;
    } on DioException catch (e) {
      throw _mapDio(e, 'Request failed');
    }
  }

  Future<void> _delete(String path) async {
    try {
      final response = await _apiClient.dio.delete(path);
      final base = BaseResponse<dynamic>.fromJson(
        response.data as Map<String, dynamic>,
        null,
      );
      if (!base.isSuccess) {
        throw ServerException(message: base.message, code: base.code);
      }
    } on DioException catch (e) {
      throw _mapDio(e, 'Request failed');
    }
  }

  Future<int> _getCountOrList(String path, {required bool paginated}) async {
    try {
      final response = await _apiClient.dio.get(
        path,
        queryParameters: paginated ? {'page': 0, 'size': 1} : null,
      );
      final raw = response.data as Map<String, dynamic>;
      if (raw.containsKey('totalElements')) {
        return raw['totalElements'] as int? ?? 0;
      }
      if (raw.containsKey('data')) {
        final data = raw['data'];
        if (data is Map && data.containsKey('totalElements')) {
          return data['totalElements'] as int? ?? 0;
        }
        if (data is List) return data.length;
      }
      if (raw.containsKey('content')) {
        return raw['totalElements'] as int? ?? (raw['content'] as List).length;
      }
      return 0;
    } catch (_) {
      return 0;
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
