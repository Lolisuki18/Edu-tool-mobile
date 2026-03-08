import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import 'package:edutool/core/theme/app_colors.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_event.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_state.dart';
import 'package:edutool/shared/models/course.dart';
import 'package:edutool/shared/models/enrollment.dart';

/// Admin dashboard content — shows counts for each entity.
class AdminDashboardContent extends StatelessWidget {
  const AdminDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      buildWhen: (p, c) =>
          c is AdminDashboardLoaded || c is AdminLoading || c is AdminFailure,
      builder: (context, state) {
        if (state is AdminLoading || state is AdminInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminFailure) {
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
                Text(state.message),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () =>
                      context.read<AdminBloc>().add(const AdminLoadDashboard()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }
        if (state is! AdminDashboardLoaded) return const SizedBox.shrink();

        final u = state.user;
        final c = state.counts;

        return RefreshIndicator(
          onRefresh: () async {
            context.read<AdminBloc>().add(const AdminLoadDashboard());
            await context.read<AdminBloc>().stream.firstWhere(
              (s) => s is! AdminLoading,
            );
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Xin chào, ${u.fullName} 👋',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Tổng quan hệ thống',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _buildGrid(context, c),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context, Map<String, int> counts) {
    final items = [
      _CountItem(
        icon: Icons.people,
        label: 'Users',
        count: counts['users'] ?? 0,
        color: AppColors.primary,
        route: '/admin/users',
      ),
      _CountItem(
        icon: Icons.school,
        label: 'Students',
        count: counts['students'] ?? 0,
        color: Colors.teal,
        route: '/admin/students',
      ),
      _CountItem(
        icon: Icons.person,
        label: 'Lecturers',
        count: counts['lecturers'] ?? 0,
        color: Colors.deepPurple,
        route: '/admin/lecturers',
      ),
      _CountItem(
        icon: Icons.calendar_today,
        label: 'Semesters',
        count: counts['semesters'] ?? 0,
        color: Colors.orange,
        route: '/admin/semesters',
      ),
      _CountItem(
        icon: Icons.book,
        label: 'Courses',
        count: counts['courses'] ?? 0,
        color: AppColors.success,
        route: '/admin/courses',
      ),
      _CountItem(
        icon: Icons.folder,
        label: 'Projects',
        count: counts['projects'] ?? 0,
        color: AppColors.warning,
        route: '/admin/projects',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.go(item.route),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, color: item.color, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    '${item.count}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CountItem {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final String route;
  const _CountItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.route,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// Admin Users Screen
// ═══════════════════════════════════════════════════════════════════════════════

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _searchCtrl = TextEditingController();
  int _page = 0;

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(AdminLoadUsers(page: _page));
  }

  void _search() {
    _page = 0;
    context.read<AdminBloc>().add(
      AdminLoadUsers(page: 0, search: _searchCtrl.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Tìm kiếm...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _search,
                icon: const Icon(Icons.search),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocConsumer<AdminBloc, AdminState>(
            listener: (context, state) {
              if (state is AdminActionSuccess) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                context.read<AdminBloc>().add(
                  AdminLoadUsers(page: _page, search: _searchCtrl.text.trim()),
                );
              }
              if (state is AdminFailure) {
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
            buildWhen: (p, c) =>
                c is AdminUsersLoaded || c is AdminLoading || c is AdminFailure,
            builder: (context, state) {
              if (state is AdminLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AdminFailure) {
                return Center(child: Text('Lỗi: ${state.message}'));
              }
              if (state is! AdminUsersLoaded) return const SizedBox.shrink();
              final users = state.data.content;
              if (users.isEmpty) {
                return const Center(child: Text('Không có dữ liệu'));
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: users.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final u = users[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                u.fullName.isNotEmpty
                                    ? u.fullName[0].toUpperCase()
                                    : '?',
                              ),
                            ),
                            title: Text(
                              u.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text('${u.username} • ${u.email}'),
                            trailing: Chip(
                              label: Text(u.role),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  _PaginationBar(
                    currentPage: state.data.page.pageNumber,
                    totalPages: state.data.page.totalPages,
                    onPageChanged: (p) {
                      _page = p;
                      context.read<AdminBloc>().add(
                        AdminLoadUsers(
                          page: p,
                          search: _searchCtrl.text.trim(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Admin Students Screen
// ═══════════════════════════════════════════════════════════════════════════════

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  int _page = 0;

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(AdminLoadStudents(page: _page));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      buildWhen: (p, c) =>
          c is AdminStudentsLoaded || c is AdminLoading || c is AdminFailure,
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminFailure) {
          return Center(child: Text('Lỗi: ${state.message}'));
        }
        if (state is! AdminStudentsLoaded) return const SizedBox.shrink();
        final students = state.data.content;
        if (students.isEmpty) {
          return const Center(child: Text('Không có dữ liệu'));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: students.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final s = students[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          s.studentCode.isNotEmpty
                              ? s.studentCode.substring(0, 2)
                              : '?',
                        ),
                      ),
                      title: Text(
                        s.user?.fullName ?? s.studentCode,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('${s.studentCode} • @${s.githubUsername}'),
                    ),
                  );
                },
              ),
            ),
            _PaginationBar(
              currentPage: state.data.page.pageNumber,
              totalPages: state.data.page.totalPages,
              onPageChanged: (p) {
                _page = p;
                context.read<AdminBloc>().add(AdminLoadStudents(page: p));
              },
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Admin Lecturers Screen
// ═══════════════════════════════════════════════════════════════════════════════

class AdminLecturersScreen extends StatefulWidget {
  const AdminLecturersScreen({super.key});

  @override
  State<AdminLecturersScreen> createState() => _AdminLecturersScreenState();
}

class _AdminLecturersScreenState extends State<AdminLecturersScreen> {
  int _page = 0;

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(AdminLoadLecturers(page: _page));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      buildWhen: (p, c) =>
          c is AdminLecturersLoaded || c is AdminLoading || c is AdminFailure,
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminFailure) {
          return Center(child: Text('Lỗi: ${state.message}'));
        }
        if (state is! AdminLecturersLoaded) return const SizedBox.shrink();
        final lecturers = state.data.content;
        if (lecturers.isEmpty) {
          return const Center(child: Text('Không có dữ liệu'));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: lecturers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final l = lecturers[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          l.staffCode.isNotEmpty
                              ? l.staffCode.substring(0, 2)
                              : '?',
                        ),
                      ),
                      title: Text(
                        l.user?.fullName ?? l.staffCode,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(l.staffCode),
                    ),
                  );
                },
              ),
            ),
            _PaginationBar(
              currentPage: state.data.page.pageNumber,
              totalPages: state.data.page.totalPages,
              onPageChanged: (p) {
                _page = p;
                context.read<AdminBloc>().add(AdminLoadLecturers(page: p));
              },
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Admin Semesters Screen
// ═══════════════════════════════════════════════════════════════════════════════

class AdminSemestersScreen extends StatelessWidget {
  const AdminSemestersScreen({super.key});

  void _showCreateDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo học kỳ'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Tên học kỳ'),
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: startCtrl,
                decoration: const InputDecoration(
                  labelText: 'Bắt đầu (yyyy-MM-dd)',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: endCtrl,
                decoration: const InputDecoration(
                  labelText: 'Kết thúc (yyyy-MM-dd)',
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
              context.read<AdminBloc>().add(
                AdminCreateSemester({
                  'name': nameCtrl.text.trim(),
                  'startDate': startCtrl.text.trim(),
                  'endDate': endCtrl.text.trim(),
                }),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Load on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AdminBloc>().state;
      if (state is! AdminSemestersLoaded) {
        context.read<AdminBloc>().add(const AdminLoadSemesters());
      }
    });

    return BlocConsumer<AdminBloc, AdminState>(
      listener: (context, state) {
        if (state is AdminActionSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          context.read<AdminBloc>().add(const AdminLoadSemesters());
        }
      },
      buildWhen: (p, c) =>
          c is AdminSemestersLoaded || c is AdminLoading || c is AdminFailure,
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminFailure) {
          return Center(child: Text('Lỗi: ${state.message}'));
        }
        if (state is! AdminSemestersLoaded) return const SizedBox.shrink();
        final semesters = state.semesters;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showCreateDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo học kỳ mới'),
                ),
              ),
            ),
            Expanded(
              child: semesters.isEmpty
                  ? const Center(child: Text('Không có dữ liệu'))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: semesters.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final s = semesters[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              s.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text('${s.startDate} → ${s.endDate}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (s.isActive)
                                  const Chip(
                                    label: Text('Active'),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () => context
                                      .read<AdminBloc>()
                                      .add(AdminDeleteSemester(s.semesterId)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Admin Courses Screen
// ═══════════════════════════════════════════════════════════════════════════════

class AdminCoursesScreen extends StatelessWidget {
  const AdminCoursesScreen({super.key});

  void _showCreateDialog(BuildContext context) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo Môn học'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: 'Mã môn'),
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Tên môn'),
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
              context.read<AdminBloc>().add(
                AdminCreateCourse({
                  'courseCode': codeCtrl.text.trim(),
                  'courseName': nameCtrl.text.trim(),
                }),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AdminBloc>().state;
      if (state is! AdminCoursesLoaded) {
        context.read<AdminBloc>().add(const AdminLoadCourses());
      }
    });

    return BlocConsumer<AdminBloc, AdminState>(
      listener: (context, state) {
        if (state is AdminActionSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          context.read<AdminBloc>().add(const AdminLoadCourses());
        }
      },
      buildWhen: (p, c) =>
          c is AdminCoursesLoaded || c is AdminLoading || c is AdminFailure,
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminFailure) {
          return Center(child: Text('Lỗi: ${state.message}'));
        }
        if (state is! AdminCoursesLoaded) return const SizedBox.shrink();
        final courses = state.courses;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showCreateDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo môn học mới'),
                ),
              ),
            ),
            Expanded(
              child: courses.isEmpty
                  ? const Center(child: Text('Không có dữ liệu'))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: courses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final c = courses[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              c.courseCode,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.courseName),
                                if (c.lecturer != null)
                                  Text(
                                    'GV: ${c.lecturer!.user?.fullName ?? c.lecturer!.staffCode}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                if (c.semester != null)
                                  Text(
                                    'HK: ${c.semester!.name}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              onPressed: () => context.read<AdminBloc>().add(
                                AdminDeleteCourse(c.courseId),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Admin Projects Screen
// ═══════════════════════════════════════════════════════════════════════════════

class AdminProjectsScreen extends StatefulWidget {
  const AdminProjectsScreen({super.key});

  @override
  State<AdminProjectsScreen> createState() => _AdminProjectsScreenState();
}

class _AdminProjectsScreenState extends State<AdminProjectsScreen> {
  int _page = 0;

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(AdminLoadProjects(page: _page));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminBloc, AdminState>(
      listener: (context, state) {
        if (state is AdminActionSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          context.read<AdminBloc>().add(AdminLoadProjects(page: _page));
        }
      },
      buildWhen: (p, c) =>
          c is AdminProjectsLoaded || c is AdminLoading || c is AdminFailure,
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminFailure) {
          return Center(child: Text('Lỗi: ${state.message}'));
        }
        if (state is! AdminProjectsLoaded) return const SizedBox.shrink();
        final projects = state.data.content;
        if (projects.isEmpty) {
          return const Center(child: Text('Không có dữ liệu'));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: projects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final p = projects[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        p.projectCode,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.projectName),
                          if (p.technologies != null)
                            Text(
                              'Tech: ${p.technologies}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textHint,
                              ),
                            ),
                        ],
                      ),
                      trailing: Chip(
                        label: Text('${p.memberCount} SV'),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  );
                },
              ),
            ),
            _PaginationBar(
              currentPage: state.data.page.pageNumber,
              totalPages: state.data.page.totalPages,
              onPageChanged: (p) {
                _page = p;
                context.read<AdminBloc>().add(AdminLoadProjects(page: p));
              },
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Admin Enrollments Screen
// ═══════════════════════════════════════════════════════════════════════════════

class AdminEnrollmentsScreen extends StatefulWidget {
  const AdminEnrollmentsScreen({super.key});

  @override
  State<AdminEnrollmentsScreen> createState() => _AdminEnrollmentsScreenState();
}

class _AdminEnrollmentsScreenState extends State<AdminEnrollmentsScreen> {
  List<Course>? _courses;
  int? _selectedCourseId;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await context.read<AdminBloc>().repository.getCourses();
      if (!mounted) return;
      setState(() {
        _courses = courses;
        _loadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = e.toString());
    }
  }

  void _onCourseChanged(int? courseId) {
    if (courseId == null) return;
    setState(() => _selectedCourseId = courseId);
    context.read<AdminBloc>().add(AdminLoadEnrollments(courseId: courseId));
  }

  void _showEditEnrollmentDialog(BuildContext ctx, Enrollment e) {
    final projectIdCtrl = TextEditingController(text: e.projectId ?? '');
    final roleCtrl = TextEditingController(text: e.roleInProject);
    final groupCtrl = TextEditingController(
      text: e.groupNumber > 0 ? e.groupNumber.toString() : '',
    );

    showDialog(
      context: ctx,
      builder: (dlgCtx) => AlertDialog(
        title: Text('Cập nhật Enrollment #${e.enrollmentId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: projectIdCtrl,
              decoration: const InputDecoration(
                labelText: 'Project ID',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: roleCtrl,
              decoration: const InputDecoration(
                labelText: 'Role (leader, member...)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: groupCtrl,
              decoration: const InputDecoration(
                labelText: 'Group Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final body = <String, dynamic>{};
              if (projectIdCtrl.text.isNotEmpty) {
                body['projectId'] = int.tryParse(projectIdCtrl.text);
              }
              if (roleCtrl.text.isNotEmpty) {
                body['roleInProject'] = roleCtrl.text;
              }
              if (groupCtrl.text.isNotEmpty) {
                body['groupNumber'] = int.tryParse(groupCtrl.text);
              }
              Navigator.pop(dlgCtx);
              ctx.read<AdminBloc>().add(
                AdminUpdateEnrollment(id: e.enrollmentId, body: body),
              );
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError != null) {
      return Center(child: Text('Lỗi tải môn học: $_loadError'));
    }
    if (_courses == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_courses!.isEmpty) {
      return const Center(child: Text('Chưa có môn học nào'));
    }

    return Column(
      children: [
        // ── Course selector ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: DropdownButtonFormField<int>(
            initialValue: _selectedCourseId,
            decoration: const InputDecoration(
              labelText: 'Chọn môn học',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: _courses!.map((c) {
              final id = int.tryParse(c.courseId) ?? 0;
              return DropdownMenuItem(
                value: id,
                child: Text(
                  '${c.courseCode} – ${c.courseName}',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: _onCourseChanged,
          ),
        ),

        // ── Enrollment list ────────────────────────────────────
        Expanded(
          child: _selectedCourseId == null
              ? const Center(
                  child: Text('Vui lòng chọn môn học để xem danh sách'),
                )
              : BlocConsumer<AdminBloc, AdminState>(
                  listener: (context, state) {
                    if (state is AdminActionSuccess) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      context.read<AdminBloc>().add(
                        AdminLoadEnrollments(courseId: _selectedCourseId!),
                      );
                    }
                  },
                  buildWhen: (p, c) =>
                      c is AdminEnrollmentsLoaded ||
                      c is AdminLoading ||
                      c is AdminFailure,
                  builder: (context, state) {
                    if (state is AdminLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is AdminFailure) {
                      return Center(child: Text('Lỗi: ${state.message}'));
                    }
                    if (state is! AdminEnrollmentsLoaded) {
                      return const SizedBox.shrink();
                    }
                    final enrollments = state.enrollments;
                    if (enrollments.isEmpty) {
                      return const Center(
                        child: Text('Không có enrollment nào'),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: enrollments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final e = enrollments[index];
                        return Card(
                          child: ListTile(
                            onTap: () => _showEditEnrollmentDialog(context, e),
                            title: Text(
                              e.studentName ??
                                  e.studentCode ??
                                  'Student #${e.studentId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Mã SV: ${e.studentCode ?? e.studentId}'
                              '${e.groupNumber > 0 ? ' • Nhóm ${e.groupNumber}' : ''}'
                              '${e.roleInProject.isNotEmpty ? ' • ${e.roleInProject}' : ''}',
                            ),
                            trailing: e.isAssigned
                                ? Chip(
                                    label: Text(e.projectCode ?? 'Assigned'),
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: AppColors.success
                                        .withValues(alpha: 0.15),
                                  )
                                : const Chip(
                                    label: Text('Unassigned'),
                                    visualDensity: VisualDensity.compact,
                                  ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Admin Profile Screen
// ═══════════════════════════════════════════════════════════════════════════════

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

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
                decoration: const InputDecoration(labelText: 'Xác nhận'),
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
              context.read<AdminBloc>().add(
                AdminChangePassword(
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminBloc, AdminState>(
      listener: (context, state) {
        if (state is AdminActionSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
        if (state is AdminFailure) {
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
      buildWhen: (p, c) => c is AdminDashboardLoaded,
      builder: (context, state) {
        final user = state is AdminDashboardLoaded ? state.user : null;

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: Icon(
                  Icons.admin_panel_settings,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.fullName ?? 'Admin',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (user != null)
                Text(
                  user.email,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              const SizedBox(height: 24),
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
// Pagination Bar
// ═══════════════════════════════════════════════════════════════════════════════

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final void Function(int) onPageChanged;
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: currentPage > 0
                ? () => onPageChanged(currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('${currentPage + 1} / $totalPages'),
          IconButton(
            onPressed: currentPage < totalPages - 1
                ? () => onPageChanged(currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
