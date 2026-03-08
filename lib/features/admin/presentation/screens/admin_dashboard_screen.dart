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
import 'package:edutool/shared/models/lecturer.dart';
import 'package:edutool/shared/models/project.dart';
import 'package:edutool/shared/models/semester.dart';

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

  void _showCreateUserDialog() {
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final fullNameCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedRole = 'STUDENT';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Tạo User'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: usernameCtrl,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Bắt buộc' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: passwordCtrl,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (v) =>
                        v == null || v.length < 8 ? 'Tối thiểu 8 ký tự' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Bắt buộc' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: fullNameCtrl,
                    decoration: const InputDecoration(labelText: 'Họ tên'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Bắt buộc' : null,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: const [
                      DropdownMenuItem(
                        value: 'STUDENT',
                        child: Text('STUDENT'),
                      ),
                      DropdownMenuItem(
                        value: 'LECTURER',
                        child: Text('LECTURER'),
                      ),
                      DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                    ],
                    onChanged: (v) =>
                        setDialogState(() => selectedRole = v ?? 'STUDENT'),
                  ),
                ],
              ),
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
                  AdminCreateUser({
                    'username': usernameCtrl.text.trim(),
                    'password': passwordCtrl.text,
                    'email': emailCtrl.text.trim(),
                    'fullName': fullNameCtrl.text.trim(),
                    'role': selectedRole,
                    'status': 'ACTIVE',
                  }),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Tạo'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateUserDialog(dynamic user) {
    final emailCtrl = TextEditingController(text: user.email);
    final fullNameCtrl = TextEditingController(text: user.fullName);
    final formKey = GlobalKey<FormState>();
    String selectedRole = user.role;
    String selectedStatus = user.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Cập nhật ${user.fullName}'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: fullNameCtrl,
                    decoration: const InputDecoration(labelText: 'Họ tên'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: const [
                      DropdownMenuItem(
                        value: 'STUDENT',
                        child: Text('STUDENT'),
                      ),
                      DropdownMenuItem(
                        value: 'LECTURER',
                        child: Text('LECTURER'),
                      ),
                      DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                    ],
                    onChanged: (v) =>
                        setDialogState(() => selectedRole = v ?? selectedRole),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'ACTIVE', child: Text('ACTIVE')),
                      DropdownMenuItem(
                        value: 'INACTIVE',
                        child: Text('INACTIVE'),
                      ),
                      DropdownMenuItem(
                        value: 'SUSPENDED',
                        child: Text('SUSPENDED'),
                      ),
                    ],
                    onChanged: (v) => setDialogState(
                      () => selectedStatus = v ?? selectedStatus,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                context.read<AdminBloc>().add(
                  AdminUpdateUser(
                    id: user.userId,
                    body: {
                      'email': emailCtrl.text.trim(),
                      'fullName': fullNameCtrl.text.trim(),
                      'role': selectedRole,
                      'status': selectedStatus,
                    },
                  ),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteUser(dynamic user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa user "${user.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<AdminBloc>().add(AdminDeleteUser(user.userId));
    }
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showCreateUserDialog,
              icon: const Icon(Icons.add),
              label: const Text('Tạo user mới'),
            ),
          ),
        ),
        const SizedBox(height: 8),
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
                            onTap: () => _showUpdateUserDialog(u),
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
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Chip(
                                  label: Text(u.role),
                                  visualDensity: VisualDensity.compact,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () => _confirmDeleteUser(u),
                                ),
                              ],
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

  void _showCreateStudentDialog() {
    final studentCodeCtrl = TextEditingController();
    final userIdCtrl = TextEditingController();
    final githubCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo Sinh viên'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: studentCodeCtrl,
                decoration: const InputDecoration(labelText: 'Mã sinh viên'),
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: userIdCtrl,
                decoration: const InputDecoration(labelText: 'User ID'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: githubCtrl,
                decoration: const InputDecoration(labelText: 'GitHub Username'),
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
                AdminCreateStudent({
                  'studentCode': studentCodeCtrl.text.trim(),
                  'userId': int.tryParse(userIdCtrl.text.trim()),
                  'githubUsername': githubCtrl.text.trim(),
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

  Future<void> _confirmDeleteStudent(dynamic s) async {
    final name = s.user?.fullName ?? s.studentCode;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa sinh viên "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<AdminBloc>().add(AdminDeleteStudent(s.studentId));
    }
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
          context.read<AdminBloc>().add(AdminLoadStudents(page: _page));
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

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showCreateStudentDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo sinh viên mới'),
                ),
              ),
            ),
            Expanded(
              child: students.isEmpty
                  ? const Center(child: Text('Không có dữ liệu'))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${s.studentCode} • @${s.githubUsername}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              onPressed: () => _confirmDeleteStudent(s),
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

  void _showCreateLecturerDialog() {
    final staffCodeCtrl = TextEditingController();
    final userIdCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo Giảng viên'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: staffCodeCtrl,
                decoration: const InputDecoration(labelText: 'Mã giảng viên'),
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: userIdCtrl,
                decoration: const InputDecoration(labelText: 'User ID'),
                keyboardType: TextInputType.number,
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
              showDialog(
                context: ctx,
                builder: (c2) => AlertDialog(
                  title: const Text('Xác nhận'),
                  content: const Text('Bạn có chắc muốn tạo giảng viên này?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c2),
                      child: const Text('Hủy'),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(c2);
                        Navigator.pop(ctx);
                        context.read<AdminBloc>().add(
                          AdminCreateLecturer({
                            'staffCode': staffCodeCtrl.text.trim(),
                            'userId': int.tryParse(userIdCtrl.text.trim()),
                          }),
                        );
                      },
                      child: const Text('Tạo'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteLecturer(dynamic l) async {
    final name = l.user?.fullName ?? l.staffCode;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa giảng viên "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<AdminBloc>().add(AdminDeleteLecturer(l.lecturerId));
    }
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
          context.read<AdminBloc>().add(AdminLoadLecturers(page: _page));
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

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showCreateLecturerDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo giảng viên mới'),
                ),
              ),
            ),
            Expanded(
              child: lecturers.isEmpty
                  ? const Center(child: Text('Không có dữ liệu'))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(l.staffCode),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              onPressed: () => _confirmDeleteLecturer(l),
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
              showDialog(
                context: ctx,
                builder: (c2) => AlertDialog(
                  title: const Text('Xác nhận'),
                  content: const Text('Bạn có chắc muốn tạo học kỳ này?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c2),
                      child: const Text('Hủy'),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(c2);
                        Navigator.pop(ctx);
                        context.read<AdminBloc>().add(
                          AdminCreateSemester({
                            'semesterName': nameCtrl.text.trim(),
                            'startDate': startCtrl.text.trim(),
                            'endDate': endCtrl.text.trim(),
                            'status': true,
                          }),
                        );
                      },
                      child: const Text('Tạo'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, dynamic s) {
    final nameCtrl = TextEditingController(text: s.name);
    final startCtrl = TextEditingController(text: s.startDate);
    final endCtrl = TextEditingController(text: s.endDate);
    final formKey = GlobalKey<FormState>();
    bool isActive = s.isActive;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Cập nhật học kỳ'),
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
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (v) => setDialogState(() => isActive = v),
                  contentPadding: EdgeInsets.zero,
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
                showDialog(
                  context: ctx,
                  builder: (c2) => AlertDialog(
                    title: const Text('Xác nhận'),
                    content: const Text(
                      'Bạn có chắc muốn cập nhật học kỳ này?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c2),
                        child: const Text('Hủy'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(c2);
                          Navigator.pop(ctx);
                          context.read<AdminBloc>().add(
                            AdminUpdateSemester(
                              id: s.semesterId,
                              body: {
                                'semesterName': nameCtrl.text.trim(),
                                'startDate': startCtrl.text.trim(),
                                'endDate': endCtrl.text.trim(),
                                'status': isActive,
                              },
                            ),
                          );
                        },
                        child: const Text('Lưu'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteSemester(BuildContext context, dynamic s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa học kỳ "${s.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AdminBloc>().add(AdminDeleteSemester(s.semesterId));
    }
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
                            onTap: () => _showUpdateDialog(context, s),
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
                                  onPressed: () =>
                                      _confirmDeleteSemester(context, s),
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

class AdminCoursesScreen extends StatefulWidget {
  const AdminCoursesScreen({super.key});

  @override
  State<AdminCoursesScreen> createState() => _AdminCoursesScreenState();
}

class _AdminCoursesScreenState extends State<AdminCoursesScreen> {
  List<Semester>? _semesters;
  List<Lecturer>? _lecturers;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
    final state = context.read<AdminBloc>().state;
    if (state is! AdminCoursesLoaded) {
      context.read<AdminBloc>().add(const AdminLoadCourses());
    }
  }

  Future<void> _loadDropdownData() async {
    try {
      final repo = context.read<AdminBloc>().repository;
      final semesters = await repo.getSemesters();
      final lecturerData = await repo.getLecturers(size: 100);
      if (!mounted) return;
      setState(() {
        _semesters = semesters;
        _lecturers = lecturerData.content;
      });
    } catch (_) {}
  }

  void _showCreateDialog() {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    int? selectedSemId;
    int? selectedLecId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Tạo Môn học'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: codeCtrl,
                    decoration: const InputDecoration(labelText: 'Mã môn'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Bắt buộc' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Tên môn'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Bắt buộc' : null,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedSemId,
                    decoration: const InputDecoration(labelText: 'Học kỳ'),
                    items: (_semesters ?? []).map((s) {
                      final id = int.tryParse(s.semesterId) ?? 0;
                      return DropdownMenuItem(value: id, child: Text(s.name));
                    }).toList(),
                    onChanged: (v) => setDialogState(() => selectedSemId = v),
                    validator: (v) => v == null ? 'Bắt buộc' : null,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedLecId,
                    decoration: const InputDecoration(labelText: 'Giảng viên'),
                    items: (_lecturers ?? []).map((l) {
                      final id = int.tryParse(l.lecturerId) ?? 0;
                      return DropdownMenuItem(
                        value: id,
                        child: Text(
                          l.user?.fullName ?? l.staffCode,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setDialogState(() => selectedLecId = v),
                    validator: (v) => v == null ? 'Bắt buộc' : null,
                  ),
                ],
              ),
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
                showDialog(
                  context: ctx,
                  builder: (c2) => AlertDialog(
                    title: const Text('Xác nhận'),
                    content: const Text('Bạn có chắc muốn tạo môn học này?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c2),
                        child: const Text('Hủy'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(c2);
                          Navigator.pop(ctx);
                          context.read<AdminBloc>().add(
                            AdminCreateCourse({
                              'courseCode': codeCtrl.text.trim(),
                              'courseName': nameCtrl.text.trim(),
                              'status': true,
                              'semesterId': selectedSemId,
                              'lecturerId': selectedLecId,
                            }),
                          );
                        },
                        child: const Text('Tạo'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Tạo'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateDialog(Course c) {
    final codeCtrl = TextEditingController(text: c.courseCode);
    final nameCtrl = TextEditingController(text: c.courseName);
    final formKey = GlobalKey<FormState>();
    bool isActive = c.status == 'true' || c.status == '1';
    int? selectedSemId = int.tryParse(c.semester?.semesterId ?? '');
    int? selectedLecId = int.tryParse(c.lecturer?.lecturerId ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Cập nhật Môn học'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: codeCtrl,
                    decoration: const InputDecoration(labelText: 'Mã môn'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Bắt buộc' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Tên môn'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Bắt buộc' : null,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedSemId,
                    decoration: const InputDecoration(labelText: 'Học kỳ'),
                    items: (_semesters ?? []).map((s) {
                      final id = int.tryParse(s.semesterId) ?? 0;
                      return DropdownMenuItem(value: id, child: Text(s.name));
                    }).toList(),
                    onChanged: (v) => setDialogState(() => selectedSemId = v),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedLecId,
                    decoration: const InputDecoration(labelText: 'Giảng viên'),
                    items: (_lecturers ?? []).map((l) {
                      final id = int.tryParse(l.lecturerId) ?? 0;
                      return DropdownMenuItem(
                        value: id,
                        child: Text(
                          l.user?.fullName ?? l.staffCode,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setDialogState(() => selectedLecId = v),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Active'),
                    value: isActive,
                    onChanged: (v) => setDialogState(() => isActive = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
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
                showDialog(
                  context: ctx,
                  builder: (c2) => AlertDialog(
                    title: const Text('Xác nhận'),
                    content: const Text(
                      'Bạn có chắc muốn cập nhật môn học này?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c2),
                        child: const Text('Hủy'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(c2);
                          Navigator.pop(ctx);
                          context.read<AdminBloc>().add(
                            AdminUpdateCourse(
                              id: c.courseId,
                              body: {
                                'courseCode': codeCtrl.text.trim(),
                                'courseName': nameCtrl.text.trim(),
                                'status': isActive,
                                if (selectedSemId != null)
                                  'semesterId': selectedSemId,
                                if (selectedLecId != null)
                                  'lecturerId': selectedLecId,
                              },
                            ),
                          );
                        },
                        child: const Text('Lưu'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteCourse(Course c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa môn "${c.courseName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<AdminBloc>().add(AdminDeleteCourse(c.courseId));
    }
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
          context.read<AdminBloc>().add(const AdminLoadCourses());
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
                  onPressed: _showCreateDialog,
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
                            onTap: () => _showUpdateDialog(c),
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
                              onPressed: () => _confirmDeleteCourse(c),
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

  void _showCreateDialog() {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final courseIdCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final techCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo Đồ án'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(labelText: 'Mã đồ án'),
                  validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên đồ án'),
                  validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: courseIdCtrl,
                  decoration: const InputDecoration(labelText: 'Course ID'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: techCtrl,
                  decoration: const InputDecoration(labelText: 'Công nghệ'),
                ),
              ],
            ),
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
              showDialog(
                context: ctx,
                builder: (c2) => AlertDialog(
                  title: const Text('Xác nhận'),
                  content: const Text('Bạn có chắc muốn tạo đồ án này?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c2),
                      child: const Text('Hủy'),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(c2);
                        Navigator.pop(ctx);
                        context.read<AdminBloc>().add(
                          AdminCreateProject({
                            'projectCode': codeCtrl.text.trim(),
                            'projectName': nameCtrl.text.trim(),
                            'courseId': int.tryParse(courseIdCtrl.text.trim()),
                            if (descCtrl.text.trim().isNotEmpty)
                              'description': descCtrl.text.trim(),
                            if (techCtrl.text.trim().isNotEmpty)
                              'technologies': techCtrl.text.trim(),
                          }),
                        );
                      },
                      child: const Text('Tạo'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(Project p) {
    final nameCtrl = TextEditingController(text: p.projectName);
    final descCtrl = TextEditingController(text: p.description ?? '');
    final techCtrl = TextEditingController(text: p.technologies ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cập nhật Đồ án'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên đồ án'),
                  validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: techCtrl,
                  decoration: const InputDecoration(labelText: 'Công nghệ'),
                ),
              ],
            ),
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
              showDialog(
                context: ctx,
                builder: (c2) => AlertDialog(
                  title: const Text('Xác nhận'),
                  content: const Text('Bạn có chắc muốn cập nhật đồ án này?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c2),
                      child: const Text('Hủy'),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(c2);
                        Navigator.pop(ctx);
                        context.read<AdminBloc>().add(
                          AdminUpdateProject(
                            id: p.projectId,
                            body: {
                              'projectName': nameCtrl.text.trim(),
                              if (descCtrl.text.trim().isNotEmpty)
                                'description': descCtrl.text.trim(),
                              if (techCtrl.text.trim().isNotEmpty)
                                'technologies': techCtrl.text.trim(),
                            },
                          ),
                        );
                      },
                      child: const Text('Lưu'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteProject(Project p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa đồ án "${p.projectName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<AdminBloc>().add(AdminDeleteProject(p.projectId));
    }
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

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showCreateDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo đồ án mới'),
                ),
              ),
            ),
            Expanded(
              child: projects.isEmpty
                  ? const Center(child: Text('Không có dữ liệu'))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: projects.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final p = projects[index];
                        return Card(
                          child: ListTile(
                            onTap: () => _showUpdateDialog(p),
                            title: Text(
                              p.projectCode,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
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
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Chip(
                                  label: Text('${p.memberCount} SV'),
                                  visualDensity: VisualDensity.compact,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () => _confirmDeleteProject(p),
                                ),
                              ],
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

  void _showCreateEnrollmentDialog() {
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn môn học trước'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final studentIdCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm Enrollment'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: studentIdCtrl,
            decoration: const InputDecoration(labelText: 'Student ID'),
            keyboardType: TextInputType.number,
            validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
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
              showDialog(
                context: ctx,
                builder: (c2) => AlertDialog(
                  title: const Text('Xác nhận'),
                  content: const Text('Bạn có chắc muốn thêm enrollment này?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c2),
                      child: const Text('Hủy'),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(c2);
                        Navigator.pop(ctx);
                        context.read<AdminBloc>().add(
                          AdminCreateEnrollment({
                            'studentId': int.tryParse(
                              studentIdCtrl.text.trim(),
                            ),
                            'courseId': _selectedCourseId,
                          }),
                        );
                      },
                      child: const Text('Thêm'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
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
              showDialog(
                context: dlgCtx,
                builder: (c2) => AlertDialog(
                  title: const Text('Xác nhận'),
                  content: const Text(
                    'Bạn có chắc muốn cập nhật enrollment này?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c2),
                      child: const Text('Hủy'),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(c2);
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
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteEnrollment(BuildContext ctx, Enrollment e) async {
    final name = e.studentName ?? e.studentCode ?? 'Student #${e.studentId}';
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa enrollment của "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true && ctx.mounted) {
      ctx.read<AdminBloc>().add(AdminDeleteEnrollment(e.enrollmentId));
    }
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: DropdownButtonFormField<int>(
            value: _selectedCourseId,
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

        // ── Add enrollment button ──────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showCreateEnrollmentDialog,
              icon: const Icon(Icons.add),
              label: const Text('Thêm enrollment'),
            ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (e.isAssigned)
                                  Chip(
                                    label: Text(e.projectCode ?? 'Assigned'),
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: AppColors.success
                                        .withValues(alpha: 0.15),
                                  )
                                else
                                  const Chip(
                                    label: Text('Unassigned'),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () =>
                                      _confirmDeleteEnrollment(context, e),
                                ),
                              ],
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
