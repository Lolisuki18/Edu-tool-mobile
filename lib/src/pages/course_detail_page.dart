import 'package:flutter/material.dart';
import 'package:edutool/src/services/mock_data.dart';
import 'package:edutool/src/models/models.dart';
import 'package:edutool/src/pages/project_detail_page.dart';

class CourseDetailPage extends StatelessWidget {
  final Course course;
  final String role;
  const CourseDetailPage({required this.course, required this.role, super.key});

  @override
  Widget build(BuildContext context) {
    final projects = MockDataService.getProjectsForCourse(course.id);
    return Scaffold(
      appBar: AppBar(title: Text('${course.name} (${course.code})')),
      body: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (ctx, i) {
          final p = projects[i];
          return ListTile(
            title: Text(p.name),
            subtitle: Text(p.description),
            trailing: Text(p.tech.join(', ')),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProjectDetailPage(project: p, role: role),
              ),
            ),
          );
        },
      ),
    );
  }
}
