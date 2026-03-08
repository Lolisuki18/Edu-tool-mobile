/// Application-wide constants.
abstract final class AppConstants {
  static const String appName = 'EduTool';

  /// Default page size for paginated API calls.
  static const int defaultPageSize = 10;

  /// Secure-storage keys.
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userRoleKey = 'user_role';
  static const String userDataKey = 'user_data';

  /// User roles.
  static const String roleAdmin = 'ADMIN';
  static const String roleLecturer = 'LECTURER';
  static const String roleStudent = 'STUDENT';

  /// User statuses.
  static const String statusActive = 'ACTIVE';
  static const String statusInactive = 'INACTIVE';
}
