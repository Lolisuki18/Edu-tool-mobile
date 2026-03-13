import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:edutool/core/theme/app_colors.dart';
import 'package:edutool/shared/models/course.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_repo_bloc.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_repo_event.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_repo_state.dart';

class AdminExportedReportsScreen extends StatefulWidget {
  const AdminExportedReportsScreen({super.key});

  @override
  State<AdminExportedReportsScreen> createState() => _AdminExportedReportsScreenState();
}

class _AdminExportedReportsScreenState extends State<AdminExportedReportsScreen> {
  List<Course>? _courses;
  int? _selectedCourseId;
  int? _selectedProjectId;
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
    setState(() {
      _selectedCourseId = courseId;
      _selectedProjectId = null;
    });
    context.read<AdminRepoBloc>().add(LoadGroupsByCourse(courseId));
  }

  void _onProjectChanged(int? projectId) {
    if (projectId == null) return;
    setState(() {
      _selectedProjectId = projectId;
    });
    context.read<AdminRepoBloc>().add(LoadExportHistory(projectId));
  }

  Future<void> _openReportUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở đường dẫn này.')),
      );
    }
  }

  void _confirmDeleteReport(int projectId, int reportId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: const Text('Bạn có chắc chắn muốn xoá báo cáo này khỏi lịch sử không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminRepoBloc>().add(DeleteExportReport(projectId, reportId));
            },
            child: const Text('Xoá'),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Quản lý báo cáo',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
        ),
        
        // ── Selection Dropdowns ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                initialValue: _selectedCourseId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Chọn môn học',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.school),
                ),
                items: _courses!.map((c) {
                  final id = int.tryParse(c.courseId) ?? 0;
                  return DropdownMenuItem(
                    value: id,
                    child: Text('${c.courseCode} – ${c.courseName}', overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: _onCourseChanged,
              ),
              const SizedBox(height: 12),
              BlocBuilder<AdminRepoBloc, AdminRepoState>(
                buildWhen: (p, c) => c is AdminRepoGroupsLoaded || c is AdminRepoLoading,
                builder: (context, state) {
                  final isGroupsLoaded = state is AdminRepoGroupsLoaded;
                  final groups = isGroupsLoaded ? state.groups : [];

                  return DropdownButtonFormField<int>(
                    value: _selectedProjectId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Chọn nhóm / dự án',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.folder),
                    ),
                    // Only enable if groups are loaded
                    items: !isGroupsLoaded || groups.isEmpty
                        ? null
                        : groups.map<DropdownMenuItem<int>>((g) {
                            return DropdownMenuItem<int>(
                              value: g.projectId,
                              child: Text('${g.projectCode} – ${g.projectName}', overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                    onChanged: isGroupsLoaded && groups.isNotEmpty ? _onProjectChanged : null,
                    hint: Text(state is AdminRepoLoading ? 'Đang tải...' : 'Chọn dự án'),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Report History List ──────────────────────────────────────────────────
        Expanded(
          child: _selectedProjectId == null
              ? const Center(child: Text('Vui lòng chọn môn học và nhóm để xem báo cáo'))
              : BlocConsumer<AdminRepoBloc, AdminRepoState>(
                  listener: (context, state) {
                    if (state is AdminRepoActionSuccess) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ));
                      // Reload history after action success
                      context.read<AdminRepoBloc>().add(LoadExportHistory(_selectedProjectId!));
                    }
                    if (state is AdminRepoFailure) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                        ));
                    }
                  },
                  buildWhen: (p, c) => 
                    c is AdminRepoExportHistoryLoaded || c is AdminRepoLoading || c is AdminRepoFailure,
                  builder: (context, state) {
                    if (state is AdminRepoLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is AdminRepoFailure) {
                      return Center(child: Text('Lỗi: ${state.message}'));
                    }
                    if (state is! AdminRepoExportHistoryLoaded) {
                      return const SizedBox.shrink();
                    }

                    final reports = state.history;
                    if (reports.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.insert_chart_outlined, size: 64, color: AppColors.textHint),
                            const SizedBox(height: 16),
                            Text('Chưa có báo cáo nào được xuất cho nhóm này.', style: TextStyle(color: AppColors.textHint)),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: reports.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, index) {
                        final r = reports[index];
                        final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(r.createdAt).toLocal());
                        
                        return Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _openReportUrl(r.storageUrl),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.table_chart, color: AppColors.success),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Báo cáo Commit',
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Ngày xuất: $dateStr',
                                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                    onPressed: () => _confirmDeleteReport(r.projectId, r.commitReportId),
                                    tooltip: 'Xoá lịch sử',
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.download, color: AppColors.primary),
                                ],
                              ),
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
