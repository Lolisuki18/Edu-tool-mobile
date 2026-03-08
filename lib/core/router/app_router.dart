import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:edutool/core/network/api_client.dart';
import 'package:edutool/core/network/session_manager.dart';
import 'package:edutool/features/auth/data/auth_repository_impl.dart';
import 'package:edutool/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:edutool/features/auth/presentation/screens/login_screen.dart';
import 'package:edutool/features/auth/presentation/screens/register_screen.dart';
import 'package:edutool/features/auth/presentation/screens/splash_screen.dart';
import 'package:edutool/features/student/data/student_repository.dart';
import 'package:edutool/features/student/presentation/bloc/student_bloc.dart';
import 'package:edutool/features/student/presentation/screens/student_shell.dart';
import 'package:edutool/features/lecturer/data/lecturer_repository.dart';
import 'package:edutool/features/lecturer/presentation/bloc/lecturer_bloc.dart';
import 'package:edutool/features/lecturer/presentation/screens/lecturer_shell.dart';
import 'package:edutool/features/admin/data/admin_repository.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_event.dart';
import 'package:edutool/features/admin/presentation/screens/admin_shell.dart';
import 'package:edutool/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:edutool/features/project/data/project_repository_impl.dart';
import 'package:edutool/features/project/presentation/bloc/project_bloc.dart';
import 'package:edutool/features/project/presentation/screens/project_detail_screen.dart';
import 'package:edutool/features/report/data/report_repository_impl.dart';
import 'package:edutool/features/report/presentation/bloc/report_bloc.dart';
import 'package:edutool/features/report/presentation/screens/report_list_screen.dart';

/// Builds the application-level [GoRouter].
GoRouter buildRouter(ApiClient apiClient) {
  final navigatorKey = GlobalKey<NavigatorState>();

  // Listen for session-expired events and redirect to /login.
  // ignore: unused_local_variable
  final sessionSub = SessionManager.instance.onSessionEvent.listen((event) {
    if (event == SessionEvent.expired) {
      navigatorKey.currentContext?.go('/login');
    }
  });

  AuthBloc createAuthBloc() =>
      AuthBloc(repository: AuthRepositoryImpl(apiClient: apiClient));

  final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    routes: [
      // ── Auth ─────────────────────────────────────
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashScreen(apiClient: apiClient),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => BlocProvider(
          create: (_) => createAuthBloc(),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => BlocProvider(
          create: (_) => createAuthBloc(),
          child: const RegisterScreen(),
        ),
      ),

      // ── Student ──────────────────────────────────
      GoRoute(
        path: '/student/dashboard',
        builder: (context, state) => BlocProvider(
          create: (_) =>
              StudentBloc(repository: StudentRepository(apiClient: apiClient)),
          child: const StudentShell(),
        ),
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

      // ── Lecturer ─────────────────────────────────
      GoRoute(
        path: '/lecturer/dashboard',
        builder: (context, state) => BlocProvider(
          create: (_) => LecturerBloc(
            repository: LecturerRepository(apiClient: apiClient),
          ),
          child: const LecturerShell(),
        ),
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

      // ── Admin ────────────────────────────────────
      GoRoute(
        path: '/admin',
        builder: (context, state) => BlocProvider(
          create: (_) =>
              AdminBloc(repository: AdminRepository(apiClient: apiClient))
                ..add(const AdminLoadDashboard()),
          child: const AdminShell(
            title: 'Dashboard',
            selectedIndex: 0,
            child: AdminDashboardContent(),
          ),
        ),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => BlocProvider(
          create: (_) =>
              AdminBloc(repository: AdminRepository(apiClient: apiClient)),
          child: const AdminShell(
            title: 'Users',
            selectedIndex: 1,
            child: AdminUsersScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/admin/students',
        builder: (context, state) => BlocProvider(
          create: (_) =>
              AdminBloc(repository: AdminRepository(apiClient: apiClient)),
          child: const AdminShell(
            title: 'Students',
            selectedIndex: 2,
            child: AdminStudentsScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/admin/lecturers',
        builder: (context, state) => BlocProvider(
          create: (_) =>
              AdminBloc(repository: AdminRepository(apiClient: apiClient)),
          child: const AdminShell(
            title: 'Lecturers',
            selectedIndex: 3,
            child: AdminLecturersScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/admin/semesters',
        builder: (context, state) => BlocProvider(
          create: (_) =>
              AdminBloc(repository: AdminRepository(apiClient: apiClient)),
          child: const AdminShell(
            title: 'Semesters',
            selectedIndex: 4,
            child: AdminSemestersScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/admin/courses',
        builder: (context, state) => BlocProvider(
          create: (_) =>
              AdminBloc(repository: AdminRepository(apiClient: apiClient)),
          child: const AdminShell(
            title: 'Courses',
            selectedIndex: 5,
            child: AdminCoursesScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/admin/enrollments',
        builder: (context, state) => BlocProvider(
          create: (_) =>
              AdminBloc(repository: AdminRepository(apiClient: apiClient)),
          child: const AdminShell(
            title: 'Enrollments',
            selectedIndex: 6,
            child: AdminEnrollmentsScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/admin/projects',
        builder: (context, state) => BlocProvider(
          create: (_) =>
              AdminBloc(repository: AdminRepository(apiClient: apiClient)),
          child: const AdminShell(
            title: 'Projects',
            selectedIndex: 7,
            child: AdminProjectsScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/admin/profile',
        builder: (context, state) => BlocProvider(
          create: (_) =>
              AdminBloc(repository: AdminRepository(apiClient: apiClient))
                ..add(const AdminLoadDashboard()),
          child: const AdminShell(
            title: 'Profile',
            selectedIndex: -1,
            child: AdminProfileScreen(),
          ),
        ),
      ),
    ],
  );

  router.dispose;

  return router;
}
