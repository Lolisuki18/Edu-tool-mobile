import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:edutool/core/theme/app_colors.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:edutool/features/admin/presentation/bloc/admin_state.dart';
import 'package:edutool/shared/services/notification_service.dart';
import 'package:edutool/shared/widgets/notification_widgets.dart';

/// Admin shell with a Drawer for navigation.
/// Wraps a child content widget with AppBar + Drawer.
class AdminShell extends StatelessWidget {
  final Widget child;
  final String title;
  final int selectedIndex;

  const AdminShell({
    super.key,
    required this.child,
    this.title = 'Admin',
    this.selectedIndex = 0,
  });

  static const _drawerItems = <_DrawerItem>[
    _DrawerItem(icon: Icons.dashboard, label: 'Dashboard', route: '/admin'),
    _DrawerItem(icon: Icons.people, label: 'Users', route: '/admin/users'),
    _DrawerItem(
      icon: Icons.school,
      label: 'Students',
      route: '/admin/students',
    ),
    _DrawerItem(
      icon: Icons.person,
      label: 'Lecturers',
      route: '/admin/lecturers',
    ),
    _DrawerItem(
      icon: Icons.calendar_today,
      label: 'Semesters',
      route: '/admin/semesters',
    ),
    _DrawerItem(icon: Icons.book, label: 'Courses', route: '/admin/courses'),
    _DrawerItem(
      icon: Icons.how_to_reg,
      label: 'Enrollments',
      route: '/admin/enrollments',
    ),
    _DrawerItem(
      icon: Icons.folder,
      label: 'Projects',
      route: '/admin/projects',
    ),
    _DrawerItem(
      icon: Icons.insert_chart,
      label: 'Reports',
      route: '/admin/reports',
    ),
    _DrawerItem(
      icon: Icons.source,
      label: 'Repositories',
      route: '/admin/repositories',
    ),
    _DrawerItem(
      icon: Icons.history,
      label: 'Exported Reports',
      route: '/admin/exported-reports',
    ),
  ];


  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminBloc, AdminState>(
      listener: (context, state) {
        if (state is AdminActionSuccess) {
          NotificationService.instance.show(
            title: 'Admin',
            body: state.message,
            payload: 'admin_action',
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(title), actions: const [NotificationBell()]),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: AppColors.primary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.school_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'EduTool Admin',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              for (int i = 0; i < _drawerItems.length; i++)
                ListTile(
                  leading: Icon(
                    _drawerItems[i].icon,
                    color: i == selectedIndex
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  title: Text(
                    _drawerItems[i].label,
                    style: TextStyle(
                      fontWeight: i == selectedIndex
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: i == selectedIndex ? AppColors.primary : null,
                    ),
                  ),
                  selected: i == selectedIndex,
                  selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
                  onTap: () {
                    Navigator.pop(context); // close drawer
                    if (i != selectedIndex) {
                      context.go(_drawerItems[i].route);
                    }
                  },
                ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.person,
                  color: AppColors.textSecondary,
                ),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/admin/profile');
                },
              ),
            ],
          ),
        ),
        body: child,
      ),
    );
  }
}

class _DrawerItem {
  final IconData icon;
  final String label;
  final String route;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
