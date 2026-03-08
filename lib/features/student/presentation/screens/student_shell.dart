import 'package:flutter/material.dart';

import 'package:edutool/core/theme/app_colors.dart';

/// Student bottom-nav shell with 3 tabs: Dashboard, Courses, Profile.
class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _currentIndex = 0;

  static const _tabs = <Widget>[
    StudentDashboardScreen(),
    _PlaceholderTab(title: 'Môn học', icon: Icons.menu_book_rounded),
    _PlaceholderTab(title: 'Cá nhân', icon: Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Môn học',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Student Dashboard – static placeholder
// ─────────────────────────────────────────────────────────────────────────────

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Greeting ───────────────────────────────────────────
          Text('Xin chào, Sinh viên 👋', style: theme.textTheme.displayLarge),
          const SizedBox(height: 4),
          Text('Hôm nay bạn có gì cần làm?', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),

          // ── Upcoming deadlines placeholder ─────────────────────
          Text('Deadline sắp tới', style: theme.textTheme.displaySmall),
          const SizedBox(height: 12),
          _DeadlineCard(
            title: 'Báo cáo tuần 3 – SWD392',
            subtitle: 'Hạn nộp: 15/03/2026',
            color: AppColors.warning,
          ),
          _DeadlineCard(
            title: 'Nộp link GitHub – PRJ301',
            subtitle: 'Hạn nộp: 12/03/2026',
            color: AppColors.error,
          ),

          const SizedBox(height: 24),

          // ── Enrolled courses placeholder ────────────────────────
          Text('Môn học đang tham gia', style: theme.textTheme.displaySmall),
          const SizedBox(height: 12),
          _CourseCard(code: 'SWD392', name: 'SW Architecture & Design'),
          _CourseCard(code: 'PRJ301', name: 'Java Web Application'),
        ],
      ),
    );
  }
}

// ── Small reusable cards (placeholder only) ──────────────────────────────────

class _DeadlineCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _DeadlineCard({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.access_time_rounded, color: color, size: 20),
        ),
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final String code;
  final String name;

  const _CourseCard({required this.code, required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            code.substring(0, 3),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          code,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(name, style: Theme.of(context).textTheme.bodyMedium),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      ),
    );
  }
}

// ── Generic placeholder tab ──────────────────────────────────────────────────

class _PlaceholderTab extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderTab({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 4),
          Text(
            'Sẽ được xây dựng ở bước tiếp theo',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
