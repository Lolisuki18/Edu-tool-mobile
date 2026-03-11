import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edutool/core/theme/app_colors.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_event.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_state.dart';
import 'package:edutool/features/admin/presentation/widgets/admin_pagination_bar.dart';
import 'package:edutool/shared/models/project.dart';

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

  void _showCreateBottomSheet() {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final courseIdCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final techCtrl = TextEditingController();
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
                    'Tạo Đồ án Mới',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: codeCtrl,
                    decoration: const InputDecoration(labelText: 'Mã đồ án'),
                    validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Tên đồ án'),
                    validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: courseIdCtrl,
                    decoration: const InputDecoration(labelText: 'ID Khóa học (Course ID)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Mô tả chi tiết'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: techCtrl,
                    decoration: const InputDecoration(labelText: 'Công nghệ sử dụng (VD: Flutter, Node.js)'),
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
                              AdminCreateProject({
                                'projectCode': codeCtrl.text.trim(),
                                'projectName': nameCtrl.text.trim(),
                                'courseId': int.tryParse(courseIdCtrl.text.trim()),
                                if (descCtrl.text.trim().isNotEmpty) 'description': descCtrl.text.trim(),
                                if (techCtrl.text.trim().isNotEmpty) 'technologies': techCtrl.text.trim(),
                              }),
                            );
                          },
                          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Tạo Đồ Án'),
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

  void _showUpdateBottomSheet(Project p) {
    final nameCtrl = TextEditingController(text: p.projectName);
    final descCtrl = TextEditingController(text: p.description ?? '');
    final techCtrl = TextEditingController(text: p.technologies ?? '');
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
                    'Cập nhật Đồ án',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Tên đồ án'),
                    validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Mô tả chi tiết'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: techCtrl,
                    decoration: const InputDecoration(labelText: 'Công nghệ (VD: React, Python)'),
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
                              AdminUpdateProject(
                                id: p.projectId,
                                body: {
                                  'projectName': nameCtrl.text.trim(),
                                  if (descCtrl.text.trim().isNotEmpty) 'description': descCtrl.text.trim(),
                                  if (techCtrl.text.trim().isNotEmpty) 'technologies': techCtrl.text.trim(),
                                },
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Lưu Thay Đổi'),
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
                  onPressed: _showCreateBottomSheet,
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo đồ án mới'),
                ),
              ),
            ),
            Expanded(
              child: projects.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open_outlined, size: 64, color: AppColors.textHint),
                          const SizedBox(height: 16),
                          Text('Chưa có đồ án nào', style: TextStyle(color: AppColors.textHint)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => context.read<AdminBloc>().add(AdminLoadProjects(page: _page)),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: projects.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final p = projects[index];
                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              onTap: () => _showUpdateBottomSheet(p),
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
            ),
            AdminPaginationBar(
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

