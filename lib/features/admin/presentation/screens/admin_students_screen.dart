import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edutool/core/theme/app_colors.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_event.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_state.dart';
import 'package:edutool/features/admin/presentation/widgets/admin_pagination_bar.dart';

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

  void _showCreateStudentBottomSheet() {
    final studentCodeCtrl = TextEditingController();
    final userIdCtrl = TextEditingController();
    final githubCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

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
                    'Thêm Sinh Viên Mới',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: studentCodeCtrl,
                    decoration: const InputDecoration(labelText: 'Mã sinh viên (SĐT hoặc MSSV)'),
                    validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: userIdCtrl,
                    decoration: const InputDecoration(labelText: 'ID Người dùng (User ID)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: githubCtrl,
                    decoration: const InputDecoration(labelText: 'Tên GitHub (GitHub Username)'),
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
                              AdminCreateStudent({
                                'studentCode': studentCodeCtrl.text.trim(),
                                'userId': int.tryParse(userIdCtrl.text.trim()),
                                'githubUsername': githubCtrl.text.trim(),
                              }),
                            );
                            Navigator.pop(ctx);
                          },
                          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Thêm Sinh Viên'),
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
                  onPressed: _showCreateStudentBottomSheet,
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo sinh viên mới'),
                ),
              ),
            ),
            Expanded(
              child: students.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school_outlined, size: 64, color: AppColors.textHint),
                          const SizedBox(height: 16),
                          Text('Chưa có sinh viên nào', style: TextStyle(color: AppColors.textHint)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => context.read<AdminBloc>().add(AdminLoadStudents(page: _page)),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: students.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final s = students[index];
                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            ),
            AdminPaginationBar(
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

