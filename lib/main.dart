import 'package:flutter/material.dart';
import 'package:edutool/src/pages/login_page.dart';
import 'package:edutool/src/pages/main_page.dart';
import 'package:edutool/src/pages/role_home.dart';
import 'package:edutool/src/widgets/footer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (ctx) => const LoginPage(),
        '/main': (ctx) => const MainPage(),
      },
      // Temporarily set RoleHome as home for quick role-footer testing.
      home: const RoleHome(role: Role.teamMember),
    );
  }
}
