import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:edutool/core/network/api_client.dart';
import 'package:edutool/core/network/base_response.dart';
import 'package:edutool/core/theme/app_colors.dart';

/// Splash screen shown at app launch.
///
/// Checks for a stored access token:
/// - If present → calls `GET /api/users/me` to resolve the user's role
///   and redirects to the appropriate dashboard.
/// - If absent or on error → redirects to `/login`.
class SplashScreen extends StatefulWidget {
  final ApiClient apiClient;

  const SplashScreen({super.key, required this.apiClient});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final token = await widget.apiClient.authInterceptor.getAccessToken();

      if (token == null || token.isEmpty) {
        _goLogin();
        return;
      }

      // Validate the token by fetching the current user profile.
      final response = await widget.apiClient.dio.get('/api/users/me');
      final base = BaseResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );

      if (!base.isSuccess || base.data == null) {
        _goLogin();
        return;
      }

      final role = base.data!['role'] as String? ?? '';
      if (!mounted) return;

      switch (role) {
        case 'STUDENT':
          context.go('/student/dashboard');
        case 'LECTURER':
          context.go('/lecturer/dashboard');
        case 'ADMIN':
          context.go('/admin');
        default:
          _goLogin();
      }
    } catch (_) {
      _goLogin();
    }
  }

  void _goLogin() {
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_rounded, size: 72, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('EduTool', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 24),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
