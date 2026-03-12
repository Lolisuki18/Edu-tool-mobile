import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edutool/core/theme/app_colors.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_event.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_state.dart';
import 'package:edutool/shared/models/enrollment.dart';
import 'package:edutool/shared/models/course.dart';
import 'package:edutool/shared/models/student.dart';
import 'package:edutool/shared/models/project.dart';

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
  List<Student>? _students;
  List<Project>? _courseProjects;
  int? _selectedCourseId;
  String? _loadError;
  bool _isLoadingStudents = false;
  bool _isLoadingProjects = false;

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _loadStudents();
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

  Future<void> _loadStudents() async {
    setState(() => _isLoadingStudents = true);
    try {
      // Fetch a large page of students to select from
      final paginated = await context.read<AdminBloc>().repository.getStudents(
        page: 0,
        size: 100,
      );
      if (!mounted) return;
      setState(() {
        _students = paginated.content;
        _isLoadingStudents = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingStudents = false);
    }
  }

  void _onCourseChanged(int? courseId) {
    if (courseId == null) return;
    setState(() {
      _selectedCourseId = courseId;
      _courseProjects = null;
    });
    context.read<AdminBloc>().add(AdminLoadEnrollments(courseId: courseId));
    _loadProjects(courseId);
  }

  Future<void> _loadProjects(int courseId) async {
    setState(() => _isLoadingProjects = true);
    try {
      final paginated = await context.read<AdminBloc>().repository.getProjects(
        courseId: courseId,
        size: 100,
      );
      if (!mounted) return;
      setState(() {
        _courseProjects = paginated.content;
        _isLoadingProjects = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingProjects = false);
    }
  }

  void _showCreateEnrollmentBottomSheet() {
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn môn học trước'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    int? tempStudentId;
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
                    'Thêm Học Viên (Enrollment)',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingStudents)
                    const Center(child: CircularProgressIndicator())
                  else if (_students == null || _students!.isEmpty)
                    const Text('Không có dữ liệu sinh viên', textAlign: TextAlign.center)
                  else
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Chọn Sinh viên',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: _students!.map((s) {
                        final id = int.tryParse(s.studentId) ?? 0;
                        final name = s.user?.fullName ?? 'N/A';
                        return DropdownMenuItem(
                          value: id,
                          child: Text(
                            '${s.studentCode} - $name',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setModalState(() => tempStudentId = val),
                      validator: (v) => v == null ? 'Vui lòng chọn sinh viên' : null,
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
                              AdminCreateEnrollment({
                                'studentId': tempStudentId,
                                'courseId': _selectedCourseId,
                              }),
                            );
                          },
                          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Thêm Học Viên'),
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

  void _showEditEnrollmentBottomSheet(BuildContext ctx, Enrollment e) {
    int? tempProjectId = int.tryParse(e.projectId ?? '');
    String tempRole = e.roleInProject;
    final groupCtrl = TextEditingController(
      text: e.groupNumber > 0 ? e.groupNumber.toString() : '',
    );
    final formKey = GlobalKey<FormState>();

    const roles = ['LEADER', 'MEMBER'];

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (dlgCtx) => StatefulBuilder(
        builder: (dlgCtx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(dlgCtx).viewInsets.bottom,
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
                    'Cập nhật Enrollment #${e.enrollmentId}',
                    style: Theme.of(dlgCtx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingProjects)
                    const Center(child: CircularProgressIndicator())
                  else if (_courseProjects == null || _courseProjects!.isEmpty)
                    const Text('Không có project trong môn này', textAlign: TextAlign.center)
                  else
                    DropdownButtonFormField<int>(
                      value: tempProjectId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Chọn Project',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.assignment),
                      ),
                      items: _courseProjects!.map((p) {
                        return DropdownMenuItem(
                          value: int.tryParse(p.projectId),
                          child: Text(
                            '${p.projectCode} - ${p.projectName}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setModalState(() => tempProjectId = val),
                    ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: roles.contains(tempRole.toUpperCase()) ? tempRole.toUpperCase() : null,
                    decoration: const InputDecoration(
                      labelText: 'Vai trò',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                    items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (val) => setModalState(() => tempRole = val ?? ''),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: groupCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Số nhóm (Group Number)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dlgCtx),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final body = <String, dynamic>{};
                            body['projectId'] = tempProjectId;
                            body['roleInProject'] = tempRole;
                            if (groupCtrl.text.isNotEmpty) {
                              body['groupNumber'] = int.tryParse(groupCtrl.text);
                            }
                            Navigator.pop(dlgCtx);
                            ctx.read<AdminBloc>().add(
                              AdminUpdateEnrollment(id: e.enrollmentId, body: body),
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

        // ── Add enrollment button ──────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showCreateEnrollmentBottomSheet,
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
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_ind_outlined, size: 64, color: AppColors.textHint),
                            const SizedBox(height: 16),
                            Text('Chưa có học viên nào trong môn này', style: TextStyle(color: AppColors.textHint)),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async => context.read<AdminBloc>().add(AdminLoadEnrollments(courseId: _selectedCourseId!)),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: enrollments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final e = enrollments[index];
                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              onTap: () => _showEditEnrollmentBottomSheet(context, e),
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
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

