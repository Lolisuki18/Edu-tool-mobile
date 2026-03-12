/// Centralised API endpoint constants.
abstract final class ApiEndpoints {
  // ── Auth ──────────────────────────────────────────────
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String logout = '/api/auth/logout';
  static const String refresh = '/api/auth/refresh';
  static const String verify = '/api/auth/verify';
  static const String me = '/api/users/me';

  // ── Users ─────────────────────────────────────────────
  static const String users = '/api/users';
  static String userById(String id) => '/api/users/$id';
  static const String usersExport = '/api/users/export';
  static const String usersImport = '/api/users/import';

  // ── Students ──────────────────────────────────────────
  static const String students = '/api/students';
  static String studentById(String id) => '/api/students/$id';

  // ── Lecturers ─────────────────────────────────────────
  static const String lecturers = '/api/lecturers';
  static String lecturerById(String id) => '/api/lecturers/$id';

  // ── Semesters ─────────────────────────────────────────
  static const String semesters = '/api/semesters';
  static String semesterById(String id) => '/api/semesters/$id';

  // ── Courses ───────────────────────────────────────────
  static const String courses = '/api/courses';
  static String courseById(String id) => '/api/courses/$id';
  static String courseByCode(String code) => '/api/courses/code/$code';

  // ── Enrollments ───────────────────────────────────────
  static const String enrollments = '/api/enrollments';
  static String enrollmentById(String id) => '/api/enrollments/$id';
  static String enrollmentProject(String id) => '/api/enrollments/$id/project';

  // ── Projects ──────────────────────────────────────────
  static const String projects = '/api/projects';
  static String projectById(String id) => '/api/projects/$id';

  // ── GitHub Repositories ───────────────────────────────
  static const String repositories = '/api/github/repositories';
  static String repositoryById(String id) => '/api/github/repositories/$id';
  static String repositorySelect(String id) =>
      '/api/github/repositories/$id/select';
  static String repositoriesByCourse(String courseId) =>
      '/api/github/repositories/course/$courseId/groups';

  // ── Commit Reports ────────────────────────────────────
  static String reportJson(String projectId) =>
      '/api/github/repositories/project/$projectId/report/json';
  static String reportCsv(String projectId) =>
      '/api/github/repositories/project/$projectId/report/csv';
  static String reportStorageUrl(String projectId) =>
      '/api/github/repositories/project/$projectId/report/storage-url';
  static String reportStorageUrlById(String projectId, String reportId) =>
      '/api/github/repositories/project/$projectId/report/storage-url/$reportId';

  // ── Periodic Reports ──────────────────────────────────
  static const String periodicReports = '/api/periodic-reports';
  static String periodicReportsByCourse(String courseId) =>
      '/api/periodic-reports/courses/$courseId';
  static String periodicReportsByCourseActive(String courseId) =>
      '/api/periodic-reports/courses/$courseId/submissions/active';
  static String periodicReportById(String id) => '/api/periodic-reports/$id';

  // ── Admin/User Actions ────────────────────────────────
  static const String changePassword = '/api/users/me/password';
}
