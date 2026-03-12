import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edutool/core/theme/app_colors.dart';
import 'package:edutool/shared/models/course.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_repo_bloc.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_repo_event.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_repo_state.dart';

class AdminRepositoriesScreen extends StatefulWidget {
  const AdminRepositoriesScreen({super.key});

  @override
  State<AdminRepositoriesScreen> createState() => _AdminRepositoriesScreenState();
}

class _AdminRepositoriesScreenState extends State<AdminRepositoriesScreen> {
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
    context.read<AdminRepoBloc>().add(LoadGroupsByCourse(courseId));
  }

  void _exportReport(int projectId, String projectName) {
    final datePrefix = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD
    context.read<AdminRepoBloc>().add(
      ExportCommitReport(
        projectId: projectId,
        projectName: projectName,
        datePrefix: datePrefix,
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
            'Quản lý Repository',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonFormField<int>(
            initialValue: _selectedCourseId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Chọn môn học',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: _courses!.map((c) {
              final id = int.tryParse(c.courseId) ?? 0;
              return DropdownMenuItem(
                value: id,
                child: Text('${c.courseCode} – ${c.courseName}'),
              );
            }).toList(),
            onChanged: _onCourseChanged,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _selectedCourseId == null
              ? const Center(child: Text('Vui lòng chọn môn học để xem danh sách Repository'))
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
                    c is AdminRepoGroupsLoaded || c is AdminRepoLoading || c is AdminRepoFailure,
                  builder: (context, state) {
                    if (state is AdminRepoLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is AdminRepoFailure) {
                      return Center(child: Text('Lỗi: ${state.message}'));
                    }
                    if (state is! AdminRepoGroupsLoaded) {
                      return const SizedBox.shrink();
                    }

                    final groups = state.groups;
                    if (groups.isEmpty) {
                      return const Center(child: Text('Chưa có nhóm nào trong môn học này.'));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: groups.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, index) {
                        final g = groups[index];
                        return Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nhóm ${g.groupNumber}  ·  ${g.projectCode} – ${g.projectName}',
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Chip(
                                            label: Text('${g.memberCount} thành viên', style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                            visualDensity: VisualDensity.compact,
                                            avatar: const Icon(Icons.people, size: 16, color: AppColors.primary),
                                          ),
                                          const SizedBox(width: 8),
                                          Chip(
                                            label: Text('${g.repoCount} repos', style: const TextStyle(fontSize: 12, color: AppColors.success)),
                                            backgroundColor: AppColors.success.withValues(alpha: 0.1),
                                            visualDensity: VisualDensity.compact,
                                            avatar: const Icon(Icons.folder, size: 16, color: AppColors.success),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () => _exportReport(g.projectId, g.projectName),
                                  icon: const Icon(Icons.download, size: 18),
                                  label: const Text('Xuất Báo Cáo'),
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
