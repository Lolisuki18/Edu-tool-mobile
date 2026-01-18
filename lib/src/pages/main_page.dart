import 'package:flutter/material.dart';
import 'package:edutool/src/pages/home_page.dart';
import 'package:edutool/src/pages/profile_page.dart';
import 'package:edutool/src/pages/requirements_page.dart';
import 'package:edutool/src/pages/commits_page.dart';
import 'package:edutool/src/pages/reports_page.dart';
import 'package:edutool/src/widgets/footer_menu.dart';

class MainPage extends StatefulWidget {
  final String? role;
  const MainPage({this.role, super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late final List<MapEntry<String, Widget>> _allPages;
  late List<MapEntry<String, Widget>> _visiblePages;

  @override
  void initState() {
    super.initState();
    _allPages = [
      MapEntry('home', const HomePage()),
      MapEntry('requirements', const RequirementsPage()),
      MapEntry('commits', const CommitsPage()),
      MapEntry('reports', const ReportsPage()),
      MapEntry('profile', const ProfilePage()),
    ];
    _updateVisible();
  }

  void _updateVisible() {
    final role = widget.role ?? 'Member';
    final allowed = _allowedKeysForRole(role);
    _visiblePages = _allPages.where((e) => allowed.contains(e.key)).toList();
    if (_currentIndex >= _visiblePages.length) _currentIndex = 0;
  }

  List<String> _allowedKeysForRole(String role) {
    switch (role) {
      case 'Admin':
        return ['home', 'requirements', 'commits', 'reports', 'profile'];
      case 'Lecturer':
        return ['home', 'requirements', 'reports', 'profile'];
      case 'Team Leader':
        return ['home', 'requirements', 'commits', 'reports', 'profile'];
      case 'Member':
      default:
        return ['home', 'commits', 'profile'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.role == null ? 'EduTool' : 'EduTool - ${widget.role}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _visiblePages[_currentIndex].value,
      bottomNavigationBar: FooterMenu(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _visiblePages.map((e) {
          switch (e.key) {
            case 'home':
              return const FooterMenuItem(icon: Icons.home, label: 'Trang chủ');
            case 'requirements':
              return const FooterMenuItem(
                icon: Icons.description,
                label: 'Yêu cầu',
              );
            case 'commits':
              return const FooterMenuItem(icon: Icons.code, label: 'Commits');
            case 'reports':
              return const FooterMenuItem(
                icon: Icons.bar_chart,
                label: 'Báo cáo',
              );
            case 'profile':
            default:
              return const FooterMenuItem(icon: Icons.person, label: 'Cá nhân');
          }
        }).toList(),
      ),
    );
  }
}
