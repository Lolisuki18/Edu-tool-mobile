import 'package:flutter/material.dart';
import 'package:edutool/src/pages/home_page.dart';
import 'package:edutool/src/pages/requirements_page.dart';
import 'package:edutool/src/pages/commits_page.dart';
import 'package:edutool/src/pages/reports_page.dart';
import 'package:edutool/src/pages/profile_page.dart';
import 'package:edutool/src/widgets/footer_menu.dart';
import 'package:edutool/src/auth/permissions.dart';

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
    final role = widget.role ?? 'Member';
    final userId = _userIdForRole(role);
    _allPages = [
      MapEntry('home', HomePage(role: role, userId: userId)),
      MapEntry('requirements', RequirementsPage(role: role)),
      MapEntry('commits', const CommitsPage()),
      MapEntry('reports', ReportsPage(role: role)),
      MapEntry('profile', const ProfilePage()),
    ];
    _updateVisible();
  }

  String _userIdForRole(String role) {
    switch (role) {
      case 'Lecturer':
        return 'u1';
      case 'Team Leader':
        return 'u2';
      case 'Admin':
        return 'u1';
      case 'Member':
      default:
        return 'u3';
    }
  }

  void _updateVisible() {
    final role = widget.role ?? 'Member';
    const keyPerm = {
      'home': 'home:view',
      'requirements': 'requirements:view',
      'commits': 'commits:view',
      'reports': 'reports:view',
      'profile': 'profile:view',
    };
    _visiblePages = _allPages.where((e) {
      final perm = keyPerm[e.key] ?? 'home:view';
      return RolePermissions.isAllowed(role, perm);
    }).toList();
    if (_currentIndex >= _visiblePages.length) _currentIndex = 0;
  }

  // previous helper removed; visibility now controlled by RolePermissions

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
