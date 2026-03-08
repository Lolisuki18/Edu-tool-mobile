import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:edutool/core/network/api_client.dart';
import 'package:edutool/core/network/session_manager.dart';
import 'package:edutool/features/auth/data/auth_repository_impl.dart';
import 'package:edutool/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:edutool/features/auth/presentation/screens/login_screen.dart';
import 'package:edutool/features/auth/presentation/screens/splash_screen.dart';
import 'package:edutool/features/student/presentation/screens/student_shell.dart';
import 'package:edutool/features/lecturer/presentation/screens/lecturer_shell.dart';
import 'package:edutool/features/project/data/project_repository_impl.dart';
import 'package:edutool/features/project/presentation/bloc/project_bloc.dart';
import 'package:edutool/features/project/presentation/screens/project_detail_screen.dart';
import 'package:edutool/features/report/data/report_repository_impl.dart';
import 'package:edutool/features/report/presentation/bloc/report_bloc.dart';
import 'package:edutool/features/report/presentation/screens/report_list_screen.dart';

/// Builds the application-level [GoRouter].
///
/// - `/splash` – initial route; checks token & redirects.
/// - `/login`  – wrapped in [BlocProvider] for [AuthBloc].
/// - `/student/dashboard` – student shell with bottom nav.
/// - `/lecturer/dashboard` – lecturer shell with bottom nav.
///
/// Listens to [SessionManager] so that a forced session-expiry
/// (e.g. refresh token failure) redirects to `/login` globally.
GoRouter buildRouter(ApiClient apiClient) {
  final navigatorKey = GlobalKey<NavigatorState>();

  // Listen for session-expired events and redirect to /login.
  // ignore: unused_local_variable
  final sessionSub = SessionManager.instance.onSessionEvent.listen((event) {
    if (event == SessionEvent.expired) {
      navigatorKey.currentContext?.go('/login');
    }
  });

  final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashScreen(apiClient: apiClient),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => BlocProvider(
          create: (_) =>
              AuthBloc(repository: AuthRepositoryImpl(apiClient: apiClient)),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/student/dashboard',
        builder: (context, state) => const StudentShell(),
      ),
      GoRoute(
        path: '/lecturer/dashboard',
        builder: (context, state) => const LecturerShell(),
      ),
      GoRoute(
        path: '/lecturer/project/:courseId',
        builder: (context, state) {
          final courseId = int.parse(state.pathParameters['courseId'] ?? '0');
          return BlocProvider(
            create: (_) => ProjectBloc(
              repository: ProjectRepositoryImpl(apiClient: apiClient),
            ),
            child: ProjectDetailScreen(courseId: courseId),
          );
        },
      ),
      GoRoute(
        path: '/student/reports/:courseId',
        builder: (context, state) {
          final courseId = int.parse(state.pathParameters['courseId'] ?? '0');
          return BlocProvider(
            create: (_) => ReportBloc(
              repository: ReportRepositoryImpl(apiClient: apiClient),
            ),
            child: ReportListScreen(courseId: courseId),
          );
        },
      ),
    ],
  );

  // Dispose the subscription when the router is disposed.
  router.dispose;

  return router;
}
