import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edutool/core/theme/app_colors.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_event.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_state.dart';
import 'package:edutool/features/admin/presentation/widgets/admin_pagination_bar.dart';

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
                    'Tạo Giảng Viên Mới',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: staffCodeCtrl,
                    decoration: const InputDecoration(labelText: 'Mã giảng viên (VD: NV012)'),
                    validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: userIdCtrl,
                    decoration: const InputDecoration(labelText: 'ID Người dùng (User ID)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
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

