import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import 'package:edutool/core/theme/app_colors.dart';
import 'package:edutool/features/student/data/student_repository.dart';
import 'package:edutool/features/student/presentation/bloc/student_bloc.dart';
import 'package:edutool/features/student/presentation/bloc/student_event.dart';
import 'package:edutool/features/student/presentation/bloc/student_state.dart';
import 'package:edutool/shared/services/notification_service.dart';
import 'package:edutool/shared/widgets/notification_widgets.dart';
import 'package:edutool/features/project/data/models/group_detail_response.dart';
import 'package:edutool/shared/widgets/skeleton_loading.dart';

/// Student bottom-nav shell with 4 tabs: Home, Groups, Reports, Profile.
class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<StudentBloc>().add(const StudentLoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StudentBloc, StudentState>(
      listener: (context, state) {
        if (state is StudentActionSuccess) {
          NotificationService.instance.show(
            title: 'Student',
            body: state.message,
            payload: 'student_action',
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('EduTool'),
          actions: const [NotificationBell()],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _HomeTab(onTabChange: (i) => setState(() => _currentIndex = i)),
            const _CoursesTab(),
            const _GroupTab(),
            const _ProfileTab(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Tổng quan',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Môn học',
            ),
            NavigationDestination(
              icon: Icon(Icons.group_outlined),
              selectedIcon: Icon(Icons.group),
              label: 'Nhóm',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Cá nhân',
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HOME TAB — Dashboard with greeting + enrolled courses
// ═══════════════════════════════════════════════════════════════════════════════

class _HomeTab extends StatelessWidget {
  final ValueChanged<int> onTabChange;
  const _HomeTab({required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<StudentBloc, StudentState>(
      buildWhen: (p, c) =>
          c is StudentDashboardLoaded ||
          c is StudentLoading ||
          c is StudentFailure,
      builder: (context, state) {
        if (state is StudentLoading || state is StudentInitial) {
          return const DashboardSkeleton();
        }

        if (state is StudentFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: 12),
                Text(state.message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.read<StudentBloc>().add(
                    const StudentLoadDashboard(),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (state is StudentDashboardLoaded) {
          final u = state.user;
          final enrollments = state.enrollments;
          final assignedEnrollments = enrollments
              .where((e) => e.hasProject)
              .toList();

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<StudentBloc>().add(const StudentLoadDashboard());
                await context.read<StudentBloc>().stream.firstWhere(
                  (s) => s is! StudentLoading,
                );
              },
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    _getGreeting(u.fullName),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hôm nay bạn muốn kiểm tra gì?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Môn học',
                          value: '${enrollments.length}',
                          icon: Icons.menu_book_outlined,
                          color: AppColors.primary,
                          onTap: () => onTabChange(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Có project',
                          value: '${assignedEnrollments.length}',
                          icon: Icons.code_outlined,
                          color: AppColors.success,
                          onTap: () => onTabChange(2),
                        ),
                      ),
                    ],
                  ),
                  // Quick Actions
                  Text(
                    'Truy cập nhanh',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _QuickActionItem(
                          icon: Icons.qr_code_scanner,
                          label: 'Quét mã',
                          onTap: () {}, // TODO: Implement QR
                        ),
                        _QuickActionItem(
                          icon: Icons.calendar_month_outlined,
                          label: 'Lịch học',
                          onTap: () {}, 
                        ),
                        _QuickActionItem(
                          icon: Icons.notifications_none_outlined,
                          label: 'Thông báo',
                          onTap: () {}, // Handled by shell
                        ),
                        _QuickActionItem(
                          icon: Icons.help_outline,
                          label: 'Hỗ trợ',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (assignedEnrollments.isNotEmpty) ...[
                    Text(
                      'Project đang tham gia',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...assignedEnrollments.map(
                      (e) => _ProjectEnrollmentCard(enrollment: e),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Text(
                    'Môn học đang tham gia',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (enrollments.isEmpty)
                    const _EmptyMessage(message: 'Chưa đăng ký môn học nào')
                  else
                    ...enrollments.map((e) => _CourseCard(enrollment: e)),
                ],
              ),
            ),
          );
        }

        return const DashboardSkeleton();
      },
    );
  }

  String _getGreeting(String name) {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng, $name ☀️';
    if (hour < 18) return 'Chào buổi chiều, $name 🌤️';
    return 'Chào buổi tối, $name 🌙';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// COURSES TAB — List enrolled courses, tap to see reports
// ═══════════════════════════════════════════════════════════════════════════════

class _CoursesTab extends StatelessWidget {
  const _CoursesTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentBloc, StudentState>(
      buildWhen: (p, c) => c is StudentDashboardLoaded,
      builder: (context, state) {
        if (state is! StudentDashboardLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final enrollments = state.enrollments;
        if (enrollments.isEmpty) {
          return const Center(
            child: _EmptyMessage(message: 'Chưa có môn học nào'),
          );
        }
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  'Môn học của tôi',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: enrollments.length,
                  itemBuilder: (context, index) {
                    final e = enrollments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            e.courseCode.length >= 3
                                ? e.courseCode.substring(0, 3)
                                : e.courseCode,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        title: Text(
                          e.courseCode,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.courseName),
                            if (e.hasProject)
                              Text(
                                'Project: ${e.projectName ?? ''} (Nhóm ${e.groupNumber ?? ''})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.success,
                                ),
                              ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            context.push('/student/reports/${e.courseId}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP TAB — Select course → view group details
// ═══════════════════════════════════════════════════════════════════════════════

class _GroupTab extends StatefulWidget {
  const _GroupTab();

  @override
  State<_GroupTab> createState() => _GroupTabState();
}

class _GroupTabState extends State<_GroupTab> {
  int? _selectedCourseId;
  List<GroupDetailResponse>? _groups;
  bool _loading = false;
  String? _error;

  void _loadGroups(int courseId) async {
    setState(() {
      _selectedCourseId = courseId;
      _loading = true;
      _error = null;
      _groups = null;
    });
    try {
      final repo = context.read<StudentBloc>().repository;
      final groups = await repo.getGroupsByCourse(courseId);
      if (mounted) {
        setState(() {
          _groups = groups;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentBloc, StudentState>(
      buildWhen: (p, c) => c is StudentDashboardLoaded,
      builder: (context, state) {
        if (state is! StudentDashboardLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final enrollments = state.enrollments
            .where((e) => e.hasProject)
            .toList();
        if (enrollments.isEmpty) {
          return const Center(
            child: _EmptyMessage(message: 'Chưa tham gia project nào'),
          );
        }

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  'Nhóm của tôi',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              // Course selector
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: enrollments.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final e = enrollments[index];
                    final selected = _selectedCourseId == e.courseId;
                    return FilterChip(
                      label: Text(e.courseCode),
                      selected: selected,
                      onSelected: (_) => _loadGroups(e.courseId),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Group list
              Expanded(child: _buildGroupContent()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupContent() {
    if (_selectedCourseId == null) {
      return const Center(child: Text('Chọn một môn học để xem nhóm'));
    }
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!, textAlign: TextAlign.center));
    }
    if (_groups == null || _groups!.isEmpty) {
      return const Center(child: _EmptyMessage(message: 'Chưa có nhóm nào'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _groups!.length,
      itemBuilder: (context, index) {
        final g = _groups![index];
        return _GroupCard(group: g);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PROFILE TAB — User info + change password + logout
// ═══════════════════════════════════════════════════════════════════════════════

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  Future<void> _logout(BuildContext context) async {
    await const FlutterSecureStorage().deleteAll();
    if (context.mounted) context.go('/login');
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentCtrl,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                ),
                obscureText: true,
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: newCtrl,
                decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                obscureText: true,
                validator: (v) =>
                    v == null || v.length < 8 ? 'Tối thiểu 8 ký tự' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: confirmCtrl,
                decoration: const InputDecoration(
                  labelText: 'Xác nhận mật khẩu',
                ),
                obscureText: true,
                validator: (v) => v != newCtrl.text ? 'Không khớp' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              context.read<StudentBloc>().add(
                StudentChangePassword(
                  currentPassword: currentCtrl.text,
                  newPassword: newCtrl.text,
                  confirmPassword: confirmCtrl.text,
                ),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Đổi'),
          ),
        ],
      ),
    );
  }

  void _showUpdateGithubDialog(BuildContext context, String current) {
    final githubCtrl = TextEditingController(text: current == 'N/A' ? '' : current);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cập nhật GitHub'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: githubCtrl,
                decoration: const InputDecoration(
                  labelText: 'GitHub Username',
                  hintText: 'VD: student1git',
                  prefixIcon: Icon(Icons.code),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final student = (context.read<StudentBloc>().state as StudentDashboardLoaded).student;
              if (student == null) return;
              
              context.read<StudentBloc>().add(
                StudentUpdateGithubUsername(
                  studentId: student.studentId,
                  githubUsername: githubCtrl.text.trim(),
                ),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudentBloc, StudentState>(
      listener: (context, state) {
        if (state is StudentActionSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          // Reload dashboard after action
          context.read<StudentBloc>().add(const StudentLoadDashboard());
        }
        if (state is StudentFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      },
      buildWhen: (p, c) => c is StudentDashboardLoaded,
      builder: (context, state) {
        final user = state is StudentDashboardLoaded ? state.user : null;
        final student = state is StudentDashboardLoaded ? state.student : null;

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                user?.fullName ?? 'Sinh viên',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (user != null)
                Text(
                  user.email,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(height: 24),

              // Info cards
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _InfoTile(
                        icon: Icons.badge_outlined,
                        label: 'Username',
                        value: user?.username ?? '',
                      ),
                      const Divider(height: 24),
                      _InfoTile(
                        icon: Icons.school_outlined,
                        label: 'Mã SV',
                        value: student?.studentCode ?? 'N/A',
                      ),
                      const Divider(height: 24),
                      _InfoTile(
                        icon: Icons.code,
                        label: 'GitHub',
                        value: student?.githubUsername ?? 'N/A',
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _showUpdateGithubDialog(context, student?.githubUsername ?? 'N/A'),
                        ),
                      ),
                      const Divider(height: 24),
                      _InfoTile(
                        icon: Icons.circle,
                        label: 'Trạng thái',
                        value: user?.status ?? '',
                        valueColor: user?.status == 'ACTIVE'
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Đổi mật khẩu'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showChangePasswordDialog(context),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: Text(
                  'Đăng xuất',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.error),
                ),
                onTap: () => _logout(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Shared small widgets
// ═══════════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final EnrollmentDetail enrollment;
  const _CourseCard({required this.enrollment});

  @override
  Widget build(BuildContext context) {
    final e = enrollment;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: () => context.push('/student/reports/${e.courseId}'),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                e.courseCode.length >= 3
                    ? e.courseCode.substring(0, 3)
                    : e.courseCode,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              e.courseCode,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              e.courseName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textHint),
          ),
        ),
      ),
    );
  }
}

class _ProjectEnrollmentCard extends StatelessWidget {
  final EnrollmentDetail enrollment;
  const _ProjectEnrollmentCard({required this.enrollment});

  @override
  Widget build(BuildContext context) {
    final e = enrollment;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.code, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.projectName ?? 'Project',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (e.roleInProject != null)
                  Chip(
                    label: Text(
                      e.roleInProject!,
                      style: const TextStyle(fontSize: 11),
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${e.courseCode} • Nhóm ${e.groupNumber ?? 'N/A'}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupDetailResponse group;
  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    'G${group.groupNumber}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.projectName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        group.projectCode,
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text('${group.memberCount} SV'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (group.projectDescription != null &&
                group.projectDescription!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                group.projectDescription!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const Divider(height: 24),
            Text('Thành viên', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            ...group.members.map(
              (m) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      m.roleInProject?.toLowerCase() == 'leader'
                          ? Icons.star_rounded
                          : Icons.person_outline,
                      size: 18,
                      color: m.roleInProject?.toLowerCase() == 'leader'
                          ? AppColors.warning
                          : AppColors.textHint,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text('${m.fullName} (${m.studentCode})')),
                    if (m.githubUsername != null)
                      Text(
                        '@${m.githubUsername}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (group.repositories.isNotEmpty) ...[
              const Divider(height: 24),
              Text('Repositories', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              ...group.repositories.map(
                (r) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    r.isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: r.isSelected
                        ? AppColors.success
                        : AppColors.textHint,
                    size: 20,
                  ),
                  title: Text(r.repoName.isNotEmpty ? r.repoName : r.repoUrl),
                  subtitle: Text(
                    r.repoUrl,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: AppColors.textHint),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: AppColors.textSecondary)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w600, color: valueColor),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  final String message;
  const _EmptyMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
