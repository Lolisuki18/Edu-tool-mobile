import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edutool/core/theme/app_colors.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_event.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_state.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Admin Semesters Screen
// ═══════════════════════════════════════════════════════════════════════════════

class AdminSemestersScreen extends StatelessWidget {
  const AdminSemestersScreen({super.key});

  void _showCreateBottomSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();
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
                    'Tạo Học Kỳ Mới',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Tên học kỳ (VD: FA24)'),
                    validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: startCtrl,
                    decoration: const InputDecoration(labelText: 'Ngày bắt đầu (yyyy-MM-dd)'),
                    validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: endCtrl,
                    decoration: const InputDecoration(labelText: 'Ngày kết thúc (yyyy-MM-dd)'),
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
                              AdminCreateSemester({
                                'semesterName': nameCtrl.text.trim(),
                                'startDate': startCtrl.text.trim(),
                                'endDate': endCtrl.text.trim(),
                                'status': true,
                              }),
                            );
                          },
                          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Tạo Học Kỳ'),
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

  void _showUpdateBottomSheet(BuildContext context, dynamic s) {
    final nameCtrl = TextEditingController(text: s.name);
    final startCtrl = TextEditingController(text: s.startDate);
    final endCtrl = TextEditingController(text: s.endDate);
    final formKey = GlobalKey<FormState>();
    bool isActive = s.isActive;

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
                    'Cập nhật Học kỳ: ${s.name}',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Tên học kỳ (VD: FA24)'),
                    validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: startCtrl,
                    decoration: const InputDecoration(labelText: 'Ngày bắt đầu (yyyy-MM-dd)'),
                    validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: endCtrl,
                    decoration: const InputDecoration(labelText: 'Ngày kết thúc (yyyy-MM-dd)'),
                    validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Trạng thái hoạt động (Active)'),
                    value: isActive,
                    onChanged: (v) => setModalState(() => isActive = v),
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.success,
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
                  onPressed: () => _showCreateBottomSheet(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo học kỳ mới'),
                ),
              ),
            ),
            Expanded(
              child: semesters.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_outlined, size: 64, color: AppColors.textHint),
                          const SizedBox(height: 16),
                          Text('Chưa có học kỳ nào', style: TextStyle(color: AppColors.textHint)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => context.read<AdminBloc>().add(const AdminLoadSemesters()),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: semesters.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final s = semesters[index];
                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              onTap: () => _showUpdateBottomSheet(context, s),
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
            ),
          ],
        );
      },
    );
  }
}

