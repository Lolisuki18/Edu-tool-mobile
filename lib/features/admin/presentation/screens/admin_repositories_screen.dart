import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edutool/core/theme/app_colors.dart';
import 'package:edutool/shared/models/course.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_repo_bloc.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_repo_event.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_repo_state.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
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
            value: _selectedCourseId,
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
                child: Text(
                  '${c.courseCode} – ${c.courseName}',
                  overflow: TextOverflow.ellipsis,
                ),
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
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                            const SizedBox(height: 12),
                            Text('Lỗi: ${state.message}', textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.read<AdminRepoBloc>().add(LoadGroupsByCourse(_selectedCourseId!)),
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (state is! AdminRepoGroupsLoaded) {
                      // Debug info during development
                      if (state is AdminRepoInitial) {
                        return const Center(child: Text('Đang đợi chọn môn học...'));
                      }
                      return Center(child: Text('Trạng thái không xác định: ${state.runtimeType}'));
                    }

                    final groups = state.groups;
                    if (groups.isEmpty) {
                      return const Center(
                        child: Text(
                          'Chưa có nhóm nào trong môn học này.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: groups.length,
                      itemBuilder: (ctx, index) {
                        final g = groups[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              title: Text(
                                'Nhóm ${g.groupNumber}  ·  ${g.projectCode}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    g.projectName,
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.people_outline, size: 14, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Text('${g.memberCount} SV', style: const TextStyle(fontSize: 12)),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.folder_outlined, size: 14, color: AppColors.success),
                                      const SizedBox(width: 4),
                                      Text('${g.repoCount} repos', style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                onPressed: () => _exportReport(g.projectId, g.projectName),
                                icon: const Icon(Icons.download, color: AppColors.primary),
                                tooltip: 'Xuất Báo Cáo',
                              ),
                              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              children: [
                                const Divider(height: 1),
                                const SizedBox(height: 12),
                                if (g.repositories.isEmpty)
                                  const Text('Không có repository nào.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))
                                else
                                  ...g.repositories.map((repo) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: InkWell(
                                          onTap: () => _launchUrl(repo.repoUrl),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.link, size: 16, color: Colors.blue),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      repo.repoName.isNotEmpty ? repo.repoName : repo.repoUrl.split('/').last,
                                                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      repo.repoUrl,
                                                      style: TextStyle(color: Colors.blue.shade700, fontSize: 11, decoration: TextDecoration.underline),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (repo.isSelected)
                                                const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                                            ],
                                          ),
                                        ),
                                      )),
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
