import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:edutool/core/network/api_client.dart';
import 'package:edutool/core/network/base_response.dart';
import 'package:edutool/core/theme/app_colors.dart';

/// Splash screen shown at app launch.
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
      // Minimum duration for the animation to play
      final animFuture = Future.delayed(const Duration(milliseconds: 2500));
      
      final token = await widget.apiClient.authInterceptor.getAccessToken();

      if (token == null || token.isEmpty) {
        await animFuture;
        _goLogin();
        return;
      }

      // Validate the token by fetching the current user profile.
      final response = await widget.apiClient.dio.get('/api/users/me');
      final base = BaseResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );

      await animFuture;

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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.card,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Use a network Lottie animation for an education theme
              Lottie.network(
                'https://lottie.host/7906d203-b0f3-4e89-9a28-66f80905186b/dYd5Z2C015.json', // Graduation/School animation
                width: 250,
                height: 250,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to Icon if network fails
                  return const Icon(
                    Icons.school_rounded,
                    size: 100,
                    color: AppColors.primary,
                  );
                },
              ),
              const SizedBox(height: 24),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ).createShader(bounds),
                child: Text(
                  'EduTool',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Empowering Education',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textHint,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 60),
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
