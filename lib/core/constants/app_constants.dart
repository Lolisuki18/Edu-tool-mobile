/// Application-wide constants.
abstract final class AppConstants {
  static const String appName = 'EduTool';

  /// Default page size for paginated API calls.
  static const int defaultPageSize = 10;

  /// Supabase Configuration
  static const String supabaseUrl = 'https://rpyvyzwucfwufkoxwlnv.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJweXZ5end1Y2Z3dWZrb3h3bG52Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI3OTY1NzAsImV4cCI6MjA4ODM3MjU3MH0.t8kEHwy1f3dbtzJndGgiiOsSsxhc2ADTsW_UZDUGP-8';

  /// OneSignal Configuration
  /// TODO: Thay thế bằng OneSignal App ID thực tế của bạn
  static const String oneSignalAppId = 'YOUR_ONESIGNAL_APP_ID_HERE';

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
