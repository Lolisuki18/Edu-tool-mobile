import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:edutool/core/theme/app_colors.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_event.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_state.dart';

/// Admin dashboard content — shows counts for each entity.
class AdminDashboardContent extends StatelessWidget {
  const AdminDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      buildWhen: (p, c) =>
          c is AdminDashboardLoaded || c is AdminLoading || c is AdminFailure,
      builder: (context, state) {
        if (state is AdminLoading || state is AdminInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminFailure) {
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
                  onPressed: () =>
                      context.read<AdminBloc>().add(const AdminLoadDashboard()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }
        if (state is! AdminDashboardLoaded) return const SizedBox.shrink();

        final u = state.user;
        final c = state.counts;

        return RefreshIndicator(
          onRefresh: () async {
            context.read<AdminBloc>().add(const AdminLoadDashboard());
            await context.read<AdminBloc>().stream.firstWhere(
              (s) => s is! AdminLoading,
            );
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Xin chào, ${u.fullName} 👋',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Tổng quan hệ thống',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _buildGrid(context, c),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context, Map<String, int> counts) {
    final items = [
      _CountItem(
        icon: Icons.people,
        label: 'Users',
        count: counts['users'] ?? 0,
        color: AppColors.primary,
        route: '/admin/users',
      ),
      _CountItem(
        icon: Icons.school,
        label: 'Students',
        count: counts['students'] ?? 0,
        color: Colors.teal,
        route: '/admin/students',
      ),
      _CountItem(
        icon: Icons.person,
        label: 'Lecturers',
        count: counts['lecturers'] ?? 0,
        color: Colors.deepPurple,
        route: '/admin/lecturers',
      ),
      _CountItem(
        icon: Icons.calendar_today,
        label: 'Semesters',
        count: counts['semesters'] ?? 0,
        color: Colors.orange,
        route: '/admin/semesters',
      ),
      _CountItem(
        icon: Icons.book,
        label: 'Courses',
        count: counts['courses'] ?? 0,
        color: AppColors.success,
        route: '/admin/courses',
      ),
      _CountItem(
        icon: Icons.folder,
        label: 'Projects',
        count: counts['projects'] ?? 0,
        color: AppColors.warning,
        route: '/admin/projects',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.go(item.route),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    item.color.withValues(alpha: 0.15),
                    item.color.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: item.color.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item.icon, color: item.color, size: 24),
                  ),
                  const Spacer(),
                  Text(
                    '${item.count}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CountItem {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final String route;
  const _CountItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.route,
  });
}

