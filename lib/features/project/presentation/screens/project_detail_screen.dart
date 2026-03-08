import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:edutool/core/theme/app_colors.dart';
import 'package:edutool/features/project/data/models/group_detail_response.dart';
import 'package:edutool/features/project/presentation/bloc/project_bloc.dart';
import 'package:edutool/features/project/presentation/bloc/project_event.dart';
import 'package:edutool/features/project/presentation/bloc/project_state.dart';

/// Screen showing group details (members + repositories) for a single course.
///
/// Expects `courseId` from the route [GoRouterState.uri] query parameter.
/// Wrapped in a [BlocProvider] for [ProjectBloc] at the router level.
class ProjectDetailScreen extends StatefulWidget {
  final int courseId;

  const ProjectDetailScreen({super.key, required this.courseId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProjectBloc>().add(
      ProjectLoadGroups(courseId: widget.courseId),
    );
  }

  // ── Submit repo dialog ─────────────────────────────────────────────────────

  void _showSubmitRepoDialog(int projectId) {
    final urlCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nộp GitHub Repository'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: urlCtrl,
            decoration: const InputDecoration(
              labelText: 'URL Repository',
              hintText: 'https://github.com/org/repo',
            ),
            keyboardType: TextInputType.url,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Vui lòng nhập URL';
              final uri = Uri.tryParse(v.trim());
              if (uri == null || !uri.host.contains('github.com')) {
                return 'URL GitHub không hợp lệ';
              }
              return null;
            },
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
              context.read<ProjectBloc>().add(
                ProjectSubmitRepo(
                  projectId: projectId,
                  repoUrl: urlCtrl.text.trim(),
                ),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Nộp'),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Project')),
      body: BlocConsumer<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectActionSuccess) {
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
          if (state is ProjectFailure) {
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
        builder: (context, state) {
          if (state is ProjectLoading || state is ProjectInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProjectGroupsLoaded) {
            if (state.groups.isEmpty) {
              return const Center(child: Text('Chưa có nhóm nào'));
            }
            return _GroupList(
              groups: state.groups,
              onSubmitRepo: _showSubmitRepoDialog,
              onSelectRepo: (repoId) {
                context.read<ProjectBloc>().add(
                  ProjectSelectRepo(repoId: repoId),
                );
              },
              onExportReport: (projectId) {
                context.read<ProjectBloc>().add(
                  ProjectExportReport(projectId: projectId),
                );
              },
            );
          }

          // Failure or transient state — show a retry option.
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
                Text(
                  state is ProjectFailure ? state.message : 'Đã xảy ra lỗi',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.read<ProjectBloc>().add(
                    ProjectLoadGroups(courseId: widget.courseId),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Private widgets
// ═══════════════════════════════════════════════════════════════════════════════

class _GroupList extends StatelessWidget {
  final List<GroupDetailResponse> groups;
  final void Function(int projectId) onSubmitRepo;
  final void Function(int repoId) onSelectRepo;
  final void Function(int projectId) onExportReport;

  const _GroupList({
    required this.groups,
    required this.onSubmitRepo,
    required this.onSelectRepo,
    required this.onExportReport,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final g = groups[index];
        return _GroupCard(
          group: g,
          onSubmitRepo: () => onSubmitRepo(g.projectId),
          onSelectRepo: onSelectRepo,
          onExportReport: () => onExportReport(g.projectId),
        );
      },
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupDetailResponse group;
  final VoidCallback onSubmitRepo;
  final void Function(int repoId) onSelectRepo;
  final VoidCallback onExportReport;

  const _GroupCard({
    required this.group,
    required this.onSubmitRepo,
    required this.onSelectRepo,
    required this.onExportReport,
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
            // ── Header ─────────────────────────────────────────────
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
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
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

            if (group.projectDescription != null &&
                group.projectDescription!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                group.projectDescription!,
                style: theme.textTheme.bodyMedium,
              ),
            ],

            if (group.projectTechnologies != null &&
                group.projectTechnologies!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Tech: ${group.projectTechnologies}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],

            const Divider(height: 24),

            // ── Members ────────────────────────────────────────────
            Text('Thành viên', style: theme.textTheme.displaySmall),
            const SizedBox(height: 8),
            ...group.members.map((m) => _MemberTile(member: m)),

            const Divider(height: 24),

            // ── Repositories ───────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Repositories',
                    style: theme.textTheme.displaySmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Nộp repository mới',
                  onPressed: onSubmitRepo,
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (group.repositories.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Chưa có repository nào'),
              )
            else
              ...group.repositories.map(
                (r) =>
                    _RepoTile(repo: r, onSelect: () => onSelectRepo(r.repoId)),
              ),

            const SizedBox(height: 8),

            // ── Export report button ──────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onExportReport,
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text('Export Báo cáo Commit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final GroupMember member;

  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final isLeader = member.roleInProject?.toLowerCase() == 'leader';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isLeader ? Icons.star_rounded : Icons.person_outline,
            size: 18,
            color: isLeader ? AppColors.warning : AppColors.textHint,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${member.fullName} (${member.studentCode})',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (member.githubUsername != null)
            Text(
              '@${member.githubUsername}',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.textHint),
            ),
        ],
      ),
    );
  }
}

class _RepoTile extends StatelessWidget {
  final GroupRepo repo;
  final VoidCallback onSelect;

  const _RepoTile({required this.repo, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        repo.isSelected
            ? Icons.radio_button_checked
            : Icons.radio_button_unchecked,
        color: repo.isSelected ? AppColors.primary : AppColors.textHint,
        size: 20,
      ),
      title: Text(
        repo.repoName.isNotEmpty ? repo.repoName : repo.repoUrl,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: Text(
        repo.repoUrl,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: AppColors.textHint),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: repo.isSelected
          ? Chip(
              label: const Text('Tracking'),
              backgroundColor: AppColors.success.withValues(alpha: 0.1),
              labelStyle: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.success),
              visualDensity: VisualDensity.compact,
              side: BorderSide.none,
            )
          : TextButton(onPressed: onSelect, child: const Text('Chọn')),
    );
  }
}
