import 'package:flutter/material.dart';

import 'package:edutool/core/theme/app_colors.dart';

/// Lecturer bottom-nav shell with 3 tabs: Dashboard, Manage, Profile.
class LecturerShell extends StatefulWidget {
  const LecturerShell({super.key});

  @override
  State<LecturerShell> createState() => _LecturerShellState();
}

class _LecturerShellState extends State<LecturerShell> {
  int _currentIndex = 0;

  static const _tabs = <Widget>[
    LecturerDashboardScreen(),
    _PlaceholderTab(title: 'Quản lý', icon: Icons.settings_outlined),
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
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Quản lý',
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
// Lecturer Dashboard – static placeholder
// ─────────────────────────────────────────────────────────────────────────────

class LecturerDashboardScreen extends StatelessWidget {
  const LecturerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Greeting ───────────────────────────────────────────
          Text('Xin chào, Giảng viên 👋', style: theme.textTheme.displayLarge),
          const SizedBox(height: 4),
          Text(
            'Tổng quan hoạt động của bạn',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // ── Statistics row ─────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Lớp phụ trách',
                  value: '4',
                  icon: Icons.class_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Sinh viên',
                  value: '156',
                  icon: Icons.people_outline,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Bài đánh giá',
                  value: '12',
                  icon: Icons.assignment_outlined,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Chưa chấm',
                  value: '8',
                  icon: Icons.pending_actions_outlined,
                  color: AppColors.error,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Recent submissions placeholder ─────────────────────
          Text('Bài nộp gần đây', style: theme.textTheme.displaySmall),
          const SizedBox(height: 12),
          _SubmissionCard(
            studentName: 'Nguyễn Văn A',
            courseName: 'SWD392 – Báo cáo tuần 3',
            time: '2 giờ trước',
          ),
          _SubmissionCard(
            studentName: 'Trần Thị B',
            courseName: 'PRJ301 – Source code Sprint 2',
            time: '5 giờ trước',
          ),
        ],
      ),
    );
  }
}

// ── Small reusable cards (placeholder only) ──────────────────────────────────

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
              ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  final String studentName;
  final String courseName;
  final String time;

  const _SubmissionCard({
    required this.studentName,
    required this.courseName,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: const Icon(
            Icons.assignment_turned_in,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(studentName, style: Theme.of(context).textTheme.bodyLarge),
        subtitle: Text(
          courseName,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        trailing: Text(time, style: Theme.of(context).textTheme.labelSmall),
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
