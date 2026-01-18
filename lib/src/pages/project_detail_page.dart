import 'package:flutter/material.dart';
import 'package:edutool/src/models/models.dart';
import 'package:edutool/src/services/mock_data.dart';

class ProjectDetailPage extends StatelessWidget {
  final Project project;
  final String role;
  const ProjectDetailPage({
    required this.project,
    required this.role,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final repos = MockDataService.getReposForProject(project.id);
    return Scaffold(
      appBar: AppBar(title: Text(project.name)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Tech: ${project.tech.join(', ')}'),
            const SizedBox(height: 12),
            const Text(
              'Repositories',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: repos.length,
                itemBuilder: (ctx, i) {
                  final r = repos[i];
                  final commits = MockDataService.getCommitsForRepo(r.id);
                  return Card(
                    child: ExpansionTile(
                      title: Text(r.name),
                      subtitle: Text(r.url),
                      children: commits
                          .map(
                            (c) => ListTile(
                              title: Text(c.message),
                              subtitle: Text('${c.authorName} • ${c.sha}'),
                              trailing: Text(
                                '${c.timestamp.toLocal()}'.split(' ')[0],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
