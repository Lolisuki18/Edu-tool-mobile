import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application-wide constants.
abstract final class AppConstants {
  static const String appName = 'EduTool';

  /// Default page size for paginated API calls.
  static const int defaultPageSize = 10;

  /// Supabase Configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// OneSignal Configuration
  static String get oneSignalAppId => dotenv.env['ONESIGNAL_APP_ID'] ?? '';

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
