import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edutool/core/theme/app_colors.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_event.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_state.dart';
import 'package:edutool/features/admin/presentation/widgets/admin_pagination_bar.dart';
import 'package:edutool/shared/models/models.dart';

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

  void _showCreateLecturerBottomSheet() {
    final staffCodeCtrl = TextEditingController();
    final userIdCtrl = TextEditingController();
    final userNameCtrl = TextEditingController(); // To display the selected user's name
    final formKey = GlobalKey<FormState>();
    User? selectedUser;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => BlocProvider(
        create: (_) => AdminBloc(repository: context.read<AdminBloc>().repository)
          ..add(const AdminLoadUsers(role: 'LECTURER', size: 100)),
        child: StatefulBuilder(
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
                      'Tạo Giảng Viên Mới',
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: staffCodeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Mã giảng viên (VD: NV012)',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<AdminBloc, AdminState>(
                      builder: (ctx, state) {
                        final isLoading = state is AdminLoading;
                        final users = state is AdminUsersLoaded ? state.data.content : <User>[];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isLoading)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: LinearProgressIndicator(),
                              ),
                            DropdownButtonFormField<User>(
                              value: selectedUser,
                              decoration: const InputDecoration(
                                labelText: 'Chọn Người dùng (User)',
                                prefixIcon: Icon(Icons.person_outline),
                                helperText: 'Chỉ hiển thị người dùng có vai trò LECTURER',
                              ),
                              items: users.map((u) {
                                return DropdownMenuItem<User>(
                                  value: u,
                                  child: Text('${u.fullName} (${u.username})'),
                                );
                              }).toList(),
                              onChanged: isLoading || users.isEmpty ? null : (u) {
                                setModalState(() {
                                  selectedUser = u;
                                  if (u != null) {
                                    userIdCtrl.text = u.userId;
                                    userNameCtrl.text = u.fullName;
                                  }
                                });
                              },
                              validator: (v) => v == null ? 'Vui lòng chọn một người dùng' : null,
                            ),
                            if (!isLoading && users.isEmpty && state is AdminUsersLoaded)
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Không tìm thấy người dùng có vai trò LECTURER nào.',
                                  style: TextStyle(color: AppColors.error, fontSize: 12),
                                ),
                              ),
                          ],
                        );
                      },
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
                              Navigator.pop(ctx);
                              context.read<AdminBloc>().add(
                                AdminCreateLecturer({
                                  'staffCode': staffCodeCtrl.text.trim(),
                                  'userId': int.tryParse(userIdCtrl.text.trim()),
                                }),
                              );
                            },
                            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                            child: const Text('Tạo Giảng Viên'),
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
      ),
    );
  }

  void _showLecturerDetailBottomSheet(dynamic l) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final user = l.user;
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Text(
                      l.staffCode.length >= 2 ? l.staffCode.substring(0, 2) : l.staffCode.isEmpty ? '?' : l.staffCode,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? l.staffCode,
                          style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          l.staffCode,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _DetailRow(icon: Icons.badge_outlined, label: 'Mã GV', value: l.staffCode),
              if (user != null) ...[
                const SizedBox(height: 12),
                _DetailRow(icon: Icons.person_outline, label: 'Username', value: user.username),
                const SizedBox(height: 12),
                _DetailRow(icon: Icons.email_outlined, label: 'Email', value: user.email),
                const SizedBox(height: 12),
                _DetailRow(icon: Icons.security, label: 'Role', value: user.role),
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.circle,
                  label: 'Trạng thái',
                  value: user.status,
                  valueColor: user.status == 'ACTIVE' ? AppColors.success : AppColors.error,
                  iconColor: user.status == 'ACTIVE' ? AppColors.success : AppColors.error,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Đóng'),
                ),
              ),
            ],
          ),
        );
      },
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
                  onPressed: _showCreateLecturerBottomSheet,
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo giảng viên mới'),
                ),
              ),
            ),
            Expanded(
              child: lecturers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_4_outlined, size: 64, color: AppColors.textHint),
                          const SizedBox(height: 16),
                          Text('Chưa có giảng viên nào', style: TextStyle(color: AppColors.textHint)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => context.read<AdminBloc>().add(AdminLoadLecturers(page: _page)),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: lecturers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final l = lecturers[index];
                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              onTap: () => _showLecturerDetailBottomSheet(l),
                              leading: CircleAvatar(
                              child: Text(
                                    l.staffCode.length >= 2
                                        ? l.staffCode.substring(0, 2)
                                        : l.staffCode.isEmpty ? '?' : l.staffCode,
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
            ),
            AdminPaginationBar(
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Color? iconColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor ?? AppColors.textSecondary),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
