import 'package:flutter/material.dart';

enum Role { admin, lecturer, teamLeader, teamMember }

class FooterNav extends StatelessWidget {
  final Role role;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FooterNav({
    super.key,
    required this.role,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (role == Role.admin) return const SizedBox.shrink();

    final List<BottomNavigationBarItem> items;
    switch (role) {
      case Role.lecturer:
        items = const [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Groups'),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Requirements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
        break;
      case Role.teamLeader:
        items = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Requirements',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Tasks'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
        break;
      case Role.teamMember:
        items = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'My Tasks',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.code), label: 'Commits'),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
        break;
      default:
        items = const [];
    }

    return BottomNavigationBar(
      items: items,
      currentIndex: items.isEmpty ? 0 : currentIndex.clamp(0, items.length - 1),
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
    );
  }
}
