import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;

import 'package:edutool/core/network/api_client.dart';
import 'package:edutool/core/router/app_router.dart';
import 'package:edutool/core/theme/app_theme.dart';
import 'package:edutool/shared/services/notification_service.dart';
import 'package:edutool/core/constants/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await NotificationService.instance.init();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Initialize OneSignal Push Notifications
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(AppConstants.oneSignalAppId);
  // Request permission for push notifications
  OneSignal.Notifications.requestPermission(true);

  // ── Base URL ─────────────────────────────────────────────────────────────
  // Lấy baseUrl thiết lập từ file .env.
  // Nếu trong file .env không khai báo biến API_BASE_URL,
  // thì mặc định sẽ chạy hàm fallback lấy Localhost tùy theo nền tảng.
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? _getFallbackBaseUrl();

  final apiClient = ApiClient(baseUrl: baseUrl);
  final router = buildRouter(apiClient);

  runApp(EduToolApp(router: router));
}

class EduToolApp extends StatelessWidget {
  final dynamic router;

  const EduToolApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'EduTool',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}

/// Fallback URL sử dụng cho môi trường Develop Localhost
/// khi bị thiếu thiết lập API_BASE_URL trong tệp .env
String _getFallbackBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:8080';
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8080';
  }
  return 'http://localhost:8080';
}
