import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import 'package:edutool/core/theme/app_colors.dart';
import 'package:edutool/shared/models/models.dart';
import 'package:edutool/shared/services/notification_service.dart';
import 'package:edutool/shared/widgets/notification_widgets.dart';
import 'package:edutool/features/lecturer/presentation/bloc/lecturer_bloc.dart';
import 'package:edutool/features/lecturer/presentation/bloc/lecturer_event.dart';
import 'package:edutool/features/lecturer/presentation/bloc/lecturer_state.dart';
import 'package:edutool/features/project/data/models/group_detail_response.dart';
import 'package:edutool/features/project/data/models/project_response.dart';

/// Lecturer bottom-nav shell with 5 tabs.
class LecturerShell extends StatefulWidget {
  const LecturerShell({super.key});

  @override
  State<LecturerShell> createState() => _LecturerShellState();
}

class _LecturerShellState extends State<LecturerShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<LecturerBloc>().add(const LecturerLoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LecturerBloc, LecturerState>(
      listener: (context, state) {
        if (state is LecturerActionSuccess) {
          NotificationService.instance.show(
            title: 'Lecturer',
            body: state.message,
            payload: 'lecturer_action',
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('EduTool'),
          actions: const [NotificationBell()],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            _HomeTab(),
            _GroupsTab(),
            _ProjectsTab(),
            _ReportsTab(),
            _ProfileTab(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Tổng quan',
            ),
            NavigationDestination(
              icon: Icon(Icons.group_outlined),
              selectedIcon: Icon(Icons.group),
              label: 'Nhóm',
            ),
            NavigationDestination(
              icon: Icon(Icons.code_outlined),
              selectedIcon: Icon(Icons.code),
              label: 'Project',
            ),
            NavigationDestination(
              icon: Icon(Icons.assessment_outlined),
              selectedIcon: Icon(Icons.assessment),
              label: 'Báo cáo',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Cá nhân',
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HOME TAB
// ═══════════════════════════════════════════════════════════════════════════════

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<LecturerBloc, LecturerState>(
      buildWhen: (p, c) =>
          c is LecturerDashboardLoaded ||
          c is LecturerLoading ||
          c is LecturerFailure,
      builder: (context, state) {
        if (state is LecturerLoading || state is LecturerInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is LecturerFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: 12),
                Text(state.message),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.read<LecturerBloc>().add(
                    const LecturerLoadDashboard(),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }
        if (state is! LecturerDashboardLoaded) return const SizedBox.shrink();

        final u = state.user;
        final courses = state.courses;

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<LecturerBloc>().add(const LecturerLoadDashboard());
              await context.read<LecturerBloc>().stream.firstWhere(
                (s) => s is! LecturerLoading,
              );
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Xin chào, ${u.fullName} 👋',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tổng quan hoạt động của bạn',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Stats
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Lớp phụ trách',
                        value: '${courses.length}',
                        icon: Icons.class_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Đang hoạt động',
                        value:
                            '${courses.where((c) => c.status == 'true' || c.status == 'ACTIVE').length}',
                        icon: Icons.check_circle_outline,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Text('Môn học', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                if (courses.isEmpty)
                  const _EmptyMsg(message: 'Chưa có môn học nào')
                else
                  ...courses.map(
                    (c) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            c.courseCode.length >= 3
                                ? c.courseCode.substring(0, 3)
                                : c.courseCode,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        title: Text(
                          c.courseCode,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(c.courseName),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            context.push('/lecturer/project/${c.courseId}'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GROUPS TAB — select course → view groups
// ═══════════════════════════════════════════════════════════════════════════════

class _GroupsTab extends StatefulWidget {
  const _GroupsTab();

  @override
  State<_GroupsTab> createState() => _GroupsTabState();
}

class _GroupsTabState extends State<_GroupsTab> {
  int? _selectedCourseId;
  List<GroupDetailResponse>? _groups;
  bool _loading = false;
  String? _error;

  void _loadGroups(int courseId) async {
    setState(() {
      _selectedCourseId = courseId;
      _loading = true;
      _error = null;
      _groups = null;
    });
    try {
      final groups = await context
          .read<LecturerBloc>()
          .repository
          .getGroupsByCourse(courseId);
      if (mounted) {
        setState(() {
          _groups = groups;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LecturerBloc, LecturerState>(
      buildWhen: (p, c) => c is LecturerDashboardLoaded,
      builder: (context, state) {
        if (state is! LecturerDashboardLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final courses = state.courses;
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  'Nhóm sinh viên',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: courses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final c = courses[index];
                    return FilterChip(
                      label: Text(c.courseCode),
                      selected: _selectedCourseId?.toString() == c.courseId,
                      onSelected: (_) =>
                          _loadGroups(int.tryParse(c.courseId) ?? 0),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildContent()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_selectedCourseId == null) {
      return const Center(child: Text('Chọn một môn học'));
    }
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    if (_groups == null || _groups!.isEmpty) {
      return const Center(child: _EmptyMsg(message: 'Chưa có nhóm'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _groups!.length,
      itemBuilder: (context, index) => _GroupCard(
        group: _groups![index],
        onSelectRepo: (repoId) => context.read<LecturerBloc>().add(
          LecturerSelectRepo(repoId: repoId),
        ),
        onDeleteRepo: (repoId) => context.read<LecturerBloc>().add(
          LecturerDeleteRepo(repoId: repoId),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PROJECTS TAB — select course → view/create projects
// ═══════════════════════════════════════════════════════════════════════════════

class _ProjectsTab extends StatefulWidget {
  const _ProjectsTab();

  @override
  State<_ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends State<_ProjectsTab> {
  int? _selectedCourseId;
  List<ProjectResponse>? _projects;
  bool _loading = false;
  String? _error;

  void _loadProjects(int courseId) async {
    setState(() {
      _selectedCourseId = courseId;
      _loading = true;
      _error = null;
      _projects = null;
    });
    try {
      final projects = await context
          .read<LecturerBloc>()
          .repository
          .getProjectsByCourse(courseId);
      if (mounted) {
        setState(() {
          _projects = projects;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  void _showCreateProjectDialog(int courseId) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final techCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo Project mới'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(labelText: 'Mã Project'),
                  validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên Project'),
                  validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: techCtrl,
                  decoration: const InputDecoration(labelText: 'Công nghệ'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              context.read<LecturerBloc>().add(
                LecturerCreateProject(
                  projectCode: codeCtrl.text.trim(),
                  projectName: nameCtrl.text.trim(),
                  courseId: courseId,
                  description: descCtrl.text.trim().isNotEmpty
                      ? descCtrl.text.trim()
                      : null,
                  technologies: techCtrl.text.trim().isNotEmpty
                      ? techCtrl.text.trim()
                      : null,
                ),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LecturerBloc, LecturerState>(
      listener: (context, state) {
        if (state is LecturerActionSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          if (_selectedCourseId != null) _loadProjects(_selectedCourseId!);
        }
        if (state is LecturerFailure) {
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
      buildWhen: (p, c) => c is LecturerDashboardLoaded,
      builder: (context, state) {
        if (state is! LecturerDashboardLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final courses = state.courses;
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  'Quản lý Project',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: courses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final c = courses[index];
                    return FilterChip(
                      label: Text(c.courseCode),
                      selected: _selectedCourseId?.toString() == c.courseId,
                      onSelected: (_) =>
                          _loadProjects(int.tryParse(c.courseId) ?? 0),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildContent()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_selectedCourseId == null) {
      return const Center(child: Text('Chọn một môn học'));
    }
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));

    return Column(
      children: [
        if (_selectedCourseId != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showCreateProjectDialog(_selectedCourseId!),
                icon: const Icon(Icons.add),
                label: const Text('Tạo Project mới'),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: (_projects == null || _projects!.isEmpty)
              ? const Center(child: _EmptyMsg(message: 'Chưa có project'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _projects!.length,
                  itemBuilder: (context, index) {
                    final p = _projects![index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          p.projectName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.projectCode),
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
                        trailing: Chip(
                          label: Text('${p.memberCount} SV'),
                          visualDensity: VisualDensity.compact,
                        ),
                        onTap: () =>
                            context.push('/lecturer/project/${p.courseId}'),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// REPORTS TAB — Commit reports
// ═══════════════════════════════════════════════════════════════════════════════

class _ReportsTab extends StatefulWidget {
  const _ReportsTab();

  @override
  State<_ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<_ReportsTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TabBar(
              controller: _tabCtrl,
              tabs: const [
                Tab(text: 'Commit Report'),
                Tab(text: 'Báo cáo định kỳ'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: const [
                _CommitReportSection(),
                _PeriodicReportSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Commit Report Section (was the old _ReportsTab body) ────────────────────

class _CommitReportSection extends StatefulWidget {
  const _CommitReportSection();

  @override
  State<_CommitReportSection> createState() => _CommitReportSectionState();
}

class _CommitReportSectionState extends State<_CommitReportSection> {
  int? _selectedProjectId;
  String? _since;
  String? _until;
  Map<String, dynamic>? _reportData;
  bool _loading = false;
  String? _error;
  List<ProjectResponse> _allProjects = [];
  bool _projectsLoading = false;

  void _loadAllProjects() async {
    setState(() => _projectsLoading = true);
    try {
      final bloc = context.read<LecturerBloc>();
      final dashboard = bloc.state;
      if (dashboard is! LecturerDashboardLoaded) return;
      List<ProjectResponse> all = [];
      for (final c in dashboard.courses) {
        final projects = await bloc.repository.getProjectsByCourse(
          int.tryParse(c.courseId) ?? 0,
        );
        all.addAll(projects);
      }
      if (mounted) {
        setState(() {
          _allProjects = all;
          _projectsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _projectsLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<LecturerBloc>().state;
      if (state is LecturerDashboardLoaded) {
        _loadAllProjects();
      } else {
        context
            .read<LecturerBloc>()
            .stream
            .firstWhere((s) => s is LecturerDashboardLoaded)
            .then((_) {
              if (mounted) _loadAllProjects();
            });
      }
    });
  }

  void _generateReport() async {
    if (_selectedProjectId == null) return;
    setState(() {
      _loading = true;
      _error = null;
      _reportData = null;
    });
    try {
      final data = await context
          .read<LecturerBloc>()
          .repository
          .getCommitReport(
            projectId: _selectedProjectId!,
            since: _since,
            until: _until,
          );
      if (mounted) {
        setState(() {
          _reportData = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _pickDate(bool isSince) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final formatted =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        if (isSince) {
          _since = formatted;
        } else {
          _until = formatted;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Báo cáo Commit',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),

        // Project selector
        if (_projectsLoading)
          const Center(child: CircularProgressIndicator())
        else
          DropdownButtonFormField<int>(
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Chọn Project',
              border: OutlineInputBorder(),
            ),
            initialValue: _selectedProjectId,
            items: _allProjects
                .map(
                  (p) => DropdownMenuItem(
                    value: p.projectId,
                    child: Text('${p.projectCode} – ${p.projectName}'),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedProjectId = v),
          ),
        const SizedBox(height: 12),

        // Date range
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickDate(true),
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(_since ?? 'Từ ngày'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickDate(false),
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(_until ?? 'Đến ngày'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        FilledButton.icon(
          onPressed: _selectedProjectId != null ? _generateReport : null,
          icon: const Icon(Icons.assessment),
          label: const Text('Xuất báo cáo'),
        ),
        const SizedBox(height: 16),

        if (_loading) const Center(child: CircularProgressIndicator()),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: AppColors.error)),
        if (_reportData != null) _buildReportView(),
      ],
    );
  }

  Widget _buildReportView() {
    final summary = (_reportData!['summary'] as List<dynamic>?) ?? [];
    if (summary.isEmpty) {
      return const _EmptyMsg(message: 'Không có dữ liệu commit');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tổng kết Commit', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...summary.map((item) {
          final m = item as Map<String, dynamic>;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          m['fullName'] as String? ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Chip(
                        label: Text(m['role'] as String? ?? ''),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  Text(
                    '${m['studentCode']} • @${m['githubUsername'] ?? ''}',
                    style: TextStyle(fontSize: 12, color: AppColors.textHint),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MetricChip(
                        label: 'Commits',
                        value: '${m['totalCommits'] ?? 0}',
                        color: AppColors.primary,
                      ),
                      _MetricChip(
                        label: 'Additions',
                        value: '+${m['totalAdditions'] ?? 0}',
                        color: AppColors.success,
                      ),
                      _MetricChip(
                        label: 'Deletions',
                        value: '-${m['totalDeletions'] ?? 0}',
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ── Periodic Report Section ─────────────────────────────────────────────────

class _PeriodicReportSection extends StatefulWidget {
  const _PeriodicReportSection();

  @override
  State<_PeriodicReportSection> createState() => _PeriodicReportSectionState();
}

class _PeriodicReportSectionState extends State<_PeriodicReportSection> {
  List<Course>? _courses;
  int? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<LecturerBloc>().state;
      if (state is LecturerDashboardLoaded) {
        setState(() => _courses = state.courses);
      } else {
        context
            .read<LecturerBloc>()
            .stream
            .firstWhere((s) => s is LecturerDashboardLoaded)
            .then((s) {
              if (mounted) {
                setState(
                  () => _courses = (s as LecturerDashboardLoaded).courses,
                );
              }
            });
      }
    });
  }

  void _onCourseChanged(int? id) {
    if (id == null) return;
    setState(() => _selectedCourseId = id);
    context.read<LecturerBloc>().add(LecturerLoadPeriodicReports(courseId: id));
  }

  void _showCreateDialog() {
    if (_selectedCourseId == null) return;
    final descCtrl = TextEditingController();
    DateTime? fromDate, toDate, submitStart, submitEnd;

    Future<DateTime?> pick(DateTime? initial) => showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}T00:00:00';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Tạo báo cáo định kỳ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    final d = await pick(fromDate);
                    if (d != null) setDialogState(() => fromDate = d);
                  },
                  child: Text(
                    fromDate != null
                        ? 'Từ: ${fromDate!.toIso8601String().substring(0, 10)}'
                        : 'Chọn ngày bắt đầu báo cáo',
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () async {
                    final d = await pick(toDate);
                    if (d != null) setDialogState(() => toDate = d);
                  },
                  child: Text(
                    toDate != null
                        ? 'Đến: ${toDate!.toIso8601String().substring(0, 10)}'
                        : 'Chọn ngày kết thúc báo cáo',
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () async {
                    final d = await pick(submitStart);
                    if (d != null) setDialogState(() => submitStart = d);
                  },
                  child: Text(
                    submitStart != null
                        ? 'Mở nộp: ${submitStart!.toIso8601String().substring(0, 10)}'
                        : 'Chọn ngày bắt đầu nộp',
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () async {
                    final d = await pick(submitEnd);
                    if (d != null) setDialogState(() => submitEnd = d);
                  },
                  child: Text(
                    submitEnd != null
                        ? 'Hạn nộp: ${submitEnd!.toIso8601String().substring(0, 10)}'
                        : 'Chọn hạn nộp',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả (tuỳ chọn)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                if (fromDate == null ||
                    toDate == null ||
                    submitStart == null ||
                    submitEnd == null) {
                  return;
                }
                Navigator.pop(ctx);
                context.read<LecturerBloc>().add(
                  LecturerCreatePeriodicReport(
                    courseId: _selectedCourseId!,
                    reportFromDate: fmt(fromDate!),
                    reportToDate: fmt(toDate!),
                    submitStartAt: fmt(submitStart!),
                    submitEndAt: fmt(submitEnd!),
                    description: descCtrl.text.isNotEmpty
                        ? descCtrl.text
                        : null,
                  ),
                );
              },
              child: const Text('Tạo'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_courses == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Course selector
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
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
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _selectedCourseId != null ? _showCreateDialog : null,
                icon: const Icon(Icons.add),
                tooltip: 'Tạo báo cáo',
              ),
            ],
          ),
        ),

        // Report list
        Expanded(
          child: _selectedCourseId == null
              ? const Center(child: Text('Chọn môn học để xem'))
              : BlocConsumer<LecturerBloc, LecturerState>(
                  listener: (context, state) {
                    if (state is LecturerActionSuccess) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                    }
                  },
                  buildWhen: (p, c) =>
                      c is LecturerPeriodicReportsLoaded ||
                      c is LecturerLoading ||
                      c is LecturerFailure,
                  builder: (context, state) {
                    if (state is LecturerLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is LecturerFailure) {
                      return Center(child: Text('Lỗi: ${state.message}'));
                    }
                    if (state is! LecturerPeriodicReportsLoaded) {
                      return const SizedBox.shrink();
                    }
                    if (state.reports.isEmpty) {
                      return const Center(
                        child: Text('Chưa có báo cáo định kỳ'),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.reports.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final r = state.reports[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              r.description ?? 'Báo cáo #${r.reportId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Từ ${r.reportFromDate.substring(0, 10)} '
                              'đến ${r.reportToDate.substring(0, 10)}\n'
                              'Nộp: ${r.submitStartAt.substring(0, 10)} '
                              '→ ${r.submitEndAt.substring(0, 10)}',
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Chip(
                                  label: Text(r.status),
                                  visualDensity: VisualDensity.compact,
                                  backgroundColor: r.status == 'ACTIVE'
                                      ? AppColors.success.withValues(
                                          alpha: 0.15,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    context.read<LecturerBloc>().add(
                                      LecturerDeletePeriodicReport(
                                        reportId: r.reportId,
                                        courseId: _selectedCourseId!,
                                      ),
                                    );
                                  },
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

// ═══════════════════════════════════════════════════════════════════════════════
// PROFILE TAB
// ═══════════════════════════════════════════════════════════════════════════════

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  Future<void> _logout(BuildContext context) async {
    await const FlutterSecureStorage().deleteAll();
    if (context.mounted) context.go('/login');
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentCtrl,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                ),
                obscureText: true,
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: newCtrl,
                decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                obscureText: true,
                validator: (v) =>
                    v == null || v.length < 8 ? 'Tối thiểu 8 ký tự' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: confirmCtrl,
                decoration: const InputDecoration(labelText: 'Xác nhận'),
                obscureText: true,
                validator: (v) => v != newCtrl.text ? 'Không khớp' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              context.read<LecturerBloc>().add(
                LecturerChangePassword(
                  currentPassword: currentCtrl.text,
                  newPassword: newCtrl.text,
                  confirmPassword: confirmCtrl.text,
                ),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Đổi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LecturerBloc, LecturerState>(
      listener: (context, state) {
        if (state is LecturerActionSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
        if (state is LecturerFailure) {
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
      buildWhen: (p, c) => c is LecturerDashboardLoaded,
      builder: (context, state) {
        final user = state is LecturerDashboardLoaded ? state.user : null;

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                user?.fullName ?? 'Giảng viên',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (user != null)
                Text(
                  user.email,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _InfoTile(
                        icon: Icons.badge_outlined,
                        label: 'Username',
                        value: user?.username ?? '',
                      ),
                      const Divider(height: 24),
                      _InfoTile(
                        icon: Icons.circle,
                        label: 'Trạng thái',
                        value: user?.status ?? '',
                        valueColor: user?.status == 'ACTIVE'
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Đổi mật khẩu'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showChangePasswordDialog(context),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: Text(
                  'Đăng xuất',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.error),
                ),
                onTap: () => _logout(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Shared small widgets
// ═══════════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupDetailResponse group;
  final void Function(int repoId) onSelectRepo;
  final void Function(int repoId) onDeleteRepo;
  const _GroupCard({
    required this.group,
    required this.onSelectRepo,
    required this.onDeleteRepo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    'G${group.groupNumber}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.projectName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        group.projectCode,
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text('${group.memberCount} SV'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Text('Thành viên', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            ...group.members.map(
              (m) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      m.roleInProject?.toLowerCase() == 'leader'
                          ? Icons.star_rounded
                          : Icons.person_outline,
                      size: 18,
                      color: m.roleInProject?.toLowerCase() == 'leader'
                          ? AppColors.warning
                          : AppColors.textHint,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text('${m.fullName} (${m.studentCode})')),
                    if (m.githubUsername != null)
                      Text(
                        '@${m.githubUsername}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (group.repositories.isNotEmpty) ...[
              const Divider(height: 24),
              Text('Repositories', style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              ...group.repositories.map(
                (r) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    r.isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: r.isSelected
                        ? AppColors.success
                        : AppColors.textHint,
                    size: 20,
                  ),
                  title: Text(r.repoName.isNotEmpty ? r.repoName : r.repoUrl),
                  subtitle: Text(
                    r.repoUrl,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: AppColors.textHint),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) {
                      if (action == 'select') onSelectRepo(r.repoId);
                      if (action == 'delete') onDeleteRepo(r.repoId);
                    },
                    itemBuilder: (_) => [
                      if (!r.isSelected)
                        const PopupMenuItem(
                          value: 'select',
                          child: Text('Chọn để track'),
                        ),
                      const PopupMenuItem(value: 'delete', child: Text('Xóa')),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: AppColors.textSecondary)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w600, color: valueColor),
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: color,
            fontSize: 16,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textHint)),
      ],
    );
  }
}

class _EmptyMsg extends StatelessWidget {
  final String message;
  const _EmptyMsg({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
