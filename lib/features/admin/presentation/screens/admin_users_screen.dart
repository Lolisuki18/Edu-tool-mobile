import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edutool/core/theme/app_colors.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_event.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_state.dart';
import 'package:edutool/features/admin/presentation/widgets/admin_pagination_bar.dart';

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

  void _showCreateUserBottomSheet() {
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final fullNameCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedRole = 'STUDENT';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Tạo Người Dùng Mới',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: usernameCtrl,
                    decoration: const InputDecoration(labelText: 'Tên đăng nhập (Username)'),
                    validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordCtrl,
                    decoration: const InputDecoration(labelText: 'Mật khẩu (Password)'),
                    obscureText: true,
                    validator: (v) => v == null || v.length < 8 ? 'Tối thiểu 8 ký tự' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: fullNameCtrl,
                    decoration: const InputDecoration(labelText: 'Họ và tên'),
                    validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(labelText: 'Vai trò (Role)'),
                    items: const [
                      DropdownMenuItem(value: 'STUDENT', child: Text('Học viên (STUDENT)')),
                      DropdownMenuItem(value: 'LECTURER', child: Text('Giảng viên (LECTURER)')),
                      DropdownMenuItem(value: 'ADMIN', child: Text('Quản trị viên (ADMIN)')),
                    ],
                    onChanged: (v) => setModalState(() => selectedRole = v ?? 'STUDENT'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
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
                          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Tạo User'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showUpdateUserBottomSheet(dynamic user) {
    final emailCtrl = TextEditingController(text: user.email);
    final fullNameCtrl = TextEditingController(text: user.fullName);
    final formKey = GlobalKey<FormState>();
    String selectedRole = user.role;
    String selectedStatus = user.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Cập nhật: ${user.fullName}',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: fullNameCtrl,
                    decoration: const InputDecoration(labelText: 'Họ tên'),
                    validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(labelText: 'Vai trò (Role)'),
                    items: const [
                      DropdownMenuItem(value: 'STUDENT', child: Text('Học viên (STUDENT)')),
                      DropdownMenuItem(value: 'LECTURER', child: Text('Giảng viên (LECTURER)')),
                      DropdownMenuItem(value: 'ADMIN', child: Text('Quản trị viên (ADMIN)')),
                    ],
                    onChanged: (v) => setModalState(() => selectedRole = v ?? selectedRole),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(labelText: 'Trạng thái (Status)'),
                    items: const [
                      DropdownMenuItem(value: 'ACTIVE', child: Text('Đang hoạt động (ACTIVE)')),
                      DropdownMenuItem(value: 'INACTIVE', child: Text('Không hoạt động (INACTIVE)')),
                      DropdownMenuItem(value: 'SUSPENDED', child: Text('Tạm khóa (SUSPENDED)')),
                    ],
                    onChanged: (v) => setModalState(() => selectedStatus = v ?? selectedStatus),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) return;
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
                          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Lưu Cập Nhật'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
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
              onPressed: _showCreateUserBottomSheet,
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: AppColors.textHint),
                      const SizedBox(height: 16),
                      Text('Không tìm thấy người dùng nào', style: TextStyle(color: AppColors.textHint)),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => context.read<AdminBloc>().add(AdminLoadUsers(page: _page, search: _searchCtrl.text.trim())),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: users.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final u = users[index];
                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              onTap: () => _showUpdateUserBottomSheet(u),
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
                  ),
                  AdminPaginationBar(
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

