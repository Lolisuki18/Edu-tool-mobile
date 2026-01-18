import 'package:flutter/material.dart';
import 'package:edutool/src/services/mock_data.dart';
import 'package:edutool/src/pages/course_detail_page.dart';

class HomePage extends StatelessWidget {
  final String role;
  final String userId;
  const HomePage({this.role = 'Member', this.userId = 'u3', super.key});

  @override
  Widget build(BuildContext context) {
    final courses = MockDataService.getCoursesForUser(userId);
    return Scaffold(
      body: ListView.builder(
        itemCount: courses.length,
        itemBuilder: (ctx, i) {
          final c = courses[i];
          return ListTile(
            title: Text(c.name),
            subtitle: Text(c.code),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CourseDetailPage(course: c, role: role),
              ),
            ),
          );
        },
      ),
    );
  }
}
