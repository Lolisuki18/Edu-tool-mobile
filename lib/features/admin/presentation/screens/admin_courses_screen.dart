import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edutool/core/theme/app_colors.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_event.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_state.dart';
import 'package:edutool/shared/models/course.dart';
import 'package:edutool/shared/models/semester.dart';
import 'package:edutool/shared/models/lecturer.dart';

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

  void _showCreateBottomSheet() {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    int? selectedSemId;
    int? selectedLecId;

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
                    'Thêm Môn học Mới',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: codeCtrl,
                    decoration: const InputDecoration(labelText: 'Mã môn (Ví dụ: SWE201)'),
                    validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Tên môn học'),
                    validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedSemId,
                    decoration: const InputDecoration(labelText: 'Học kỳ'),
                    items: (_semesters ?? []).map((s) {
                      final id = int.tryParse(s.semesterId) ?? 0;
                      return DropdownMenuItem(value: id, child: Text(s.name));
                    }).toList(),
                    onChanged: (v) => setModalState(() => selectedSemId = v),
                    validator: (v) => v == null ? 'Vui lòng chọn học kỳ' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedLecId,
                    decoration: const InputDecoration(labelText: 'Giảng viên phụ trách'),
                    items: (_lecturers ?? []).map((l) {
                      final id = int.tryParse(l.lecturerId) ?? 0;
                      return DropdownMenuItem(
                        value: id,
                        child: Text(l.user?.fullName ?? l.staffCode, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (v) => setModalState(() => selectedLecId = v),
                    validator: (v) => v == null ? 'Vui lòng chọn giảng viên' : null,
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
                              AdminCreateCourse({
                                'courseCode': codeCtrl.text.trim(),
                                'courseName': nameCtrl.text.trim(),
                                'status': true,
                                'semesterId': selectedSemId,
                                'lecturerId': selectedLecId,
                              }),
                            );
                          },
                          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Tạo Môn Học'),
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

  void _showUpdateBottomSheet(Course c) {
    final codeCtrl = TextEditingController(text: c.courseCode);
    final nameCtrl = TextEditingController(text: c.courseName);
    final formKey = GlobalKey<FormState>();
    bool isActive = c.status == 'true' || c.status == '1';
    int? selectedSemId = int.tryParse(c.semester?.semesterId ?? '');
    int? selectedLecId = int.tryParse(c.lecturer?.lecturerId ?? '');

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
                    'Cập nhật Môn học',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: codeCtrl,
                    decoration: const InputDecoration(labelText: 'Mã môn'),
                    validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Tên môn học'),
                    validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedSemId,
                    decoration: const InputDecoration(labelText: 'Học kỳ'),
                    items: (_semesters ?? []).map((s) {
                      final id = int.tryParse(s.semesterId) ?? 0;
                      return DropdownMenuItem(value: id, child: Text(s.name));
                    }).toList(),
                    onChanged: (v) => setModalState(() => selectedSemId = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedLecId,
                    decoration: const InputDecoration(labelText: 'Giảng viên phụ trách'),
                    items: (_lecturers ?? []).map((l) {
                      final id = int.tryParse(l.lecturerId) ?? 0;
                      return DropdownMenuItem(
                        value: id,
                        child: Text(l.user?.fullName ?? l.staffCode, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (v) => setModalState(() => selectedLecId = v),
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
                              AdminUpdateCourse(
                                id: c.courseId,
                                body: {
                                  'courseCode': codeCtrl.text.trim(),
                                  'courseName': nameCtrl.text.trim(),
                                  'status': isActive,
                                  if (selectedSemId != null) 'semesterId': selectedSemId,
                                  if (selectedLecId != null) 'lecturerId': selectedLecId,
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
                  onPressed: _showCreateBottomSheet,
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo môn học mới'),
                ),
              ),
            ),
            Expanded(
              child: courses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.library_books_outlined, size: 64, color: AppColors.textHint),
                          const SizedBox(height: 16),
                          Text('Chưa có môn học nào', style: TextStyle(color: AppColors.textHint)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => context.read<AdminBloc>().add(const AdminLoadCourses()),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: courses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final c = courses[index];
                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              onTap: () => _showUpdateBottomSheet(c),
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
            ),
          ],
        );
      },
    );
  }
}

