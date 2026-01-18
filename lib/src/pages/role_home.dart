import 'package:flutter/material.dart';
import '../widgets/footer.dart';
import 'admin/dashboard_page.dart';
import 'admin/users_page.dart';
import 'admin/settings_page.dart';
import 'admin/logs_page.dart';

class RoleHome extends StatefulWidget {
  final Role role;
  const RoleHome({super.key, required this.role});

  @override
  State<RoleHome> createState() => _RoleHomeState();
}

class _RoleHomeState extends State<RoleHome> {
  int _currentIndex = 0;

  late final Map<Role, List<Widget>> pagesForRole;

  @override
  void initState() {
    super.initState();
    pagesForRole = {
      Role.lecturer: [
        _simplePage('Groups'),
        _simplePage('Requirements'),
        _simplePage('Reports'),
        _simplePage('Profile'),
      ],
      Role.teamLeader: [
        _simplePage('Dashboard'),
        _simplePage('Requirements'),
        _simplePage('Tasks'),
        _simplePage('Reports'),
        _simplePage('Profile'),
      ],
      Role.teamMember: [
        _simplePage('My Tasks'),
        _simplePage('Commits'),
        _simplePage('Progress'),
        _simplePage('Profile'),
      ],
      Role.admin: const [
        AdminDashboardPage(),
        AdminUsersPage(),
        AdminSettingsPage(),
        AdminLogsPage(),
      ],
    };
  }

  static Widget _simplePage(String title) =>
      Center(child: Text(title, style: const TextStyle(fontSize: 22)));

  @override
  Widget build(BuildContext context) {
    final role = widget.role;
    final pages = pagesForRole[role] ?? [_simplePage('No pages')];

    return Scaffold(
      appBar: AppBar(
        title: Text('Role: ${role.toString().split('.').last}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      drawer: role == Role.admin
          ? Drawer(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const DrawerHeader(
                      decoration: BoxDecoration(color: Colors.blue),
                      child: Text(
                        'Admin Menu',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.dashboard),
                      title: const Text('Dashboard'),
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() => _currentIndex = 0);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text('Users'),
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() => _currentIndex = 1);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Settings'),
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() => _currentIndex = 2);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('Logs'),
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() => _currentIndex = 3);
                      },
                    ),
                    const Spacer(),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: pages[_currentIndex % pages.length],
      bottomNavigationBar: role == Role.admin
          ? null
          : FooterNav(
              role: role,
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
    );
  }
}
