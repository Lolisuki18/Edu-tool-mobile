import 'package:flutter/material.dart';

import 'package:edutool/core/network/api_client.dart';
import 'package:edutool/core/router/app_router.dart';
import 'package:edutool/core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient(baseUrl: 'http://10.0.2.2:8080');
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
