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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  // Để đổi môi trường, chỉ cần thay dòng const _useProduction = true/false:
  //   true  → production server
  //   false → localhost (web & desktop: 8080, Android emulator: 10.0.2.2:8080)
  const bool useProduction = true;

  final String baseUrl;
  if (useProduction) {
    baseUrl = 'https://edu-tool-be.onrender.com';
  } else if (kIsWeb) {
    baseUrl = 'http://localhost:8080'; // Chrome/web
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    baseUrl = 'http://10.0.2.2:8080'; // Android emulator
  } else {
    baseUrl = 'http://localhost:8080'; // Windows / iOS / macOS / Linux desktop
  }

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
