import 'package:flutter/material.dart';

class FooterMenu extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  final List<FooterMenuItem> items;

  const FooterMenu({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      onTap: onTap,
      items: items
          .map(
            (it) =>
                BottomNavigationBarItem(icon: Icon(it.icon), label: it.label),
          )
          .toList(),
    );
  }
}

class FooterMenuItem {
  final IconData icon;
  final String label;
  const FooterMenuItem({required this.icon, required this.label});
}
