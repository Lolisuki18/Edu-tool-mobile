import 'package:flutter/material.dart';
import 'package:edutool/src/services/mock_data.dart';
import 'package:edutool/src/models/models.dart';

class ReportsPage extends StatefulWidget {
  final String role;
  const ReportsPage({this.role = 'Member', super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<ReportPeriod> _periods = [];

  @override
  void initState() {
    super.initState();
    _periods = MockDataService.getReportPeriodsForCourse('c1');
  }

  bool get _canCreate => widget.role == 'Lecturer' || widget.role == 'Admin';

  void _createPeriod() async {
    final now = DateTime.now();
    final rp = MockDataService.createReportPeriod(
      'c1',
      'Auto ${_periods.length + 1}',
      now.subtract(const Duration(days: 7)),
      now,
    );
    setState(() => _periods.add(rp));
  }

  Map<String, int> _aggregateCommitsForPeriod(ReportPeriod p) {
    // simple aggregation: count commits per project using repo mapping
    final counts = <String, int>{};
    for (final repo in MockDataService.repos) {
      final project = MockDataService.projects.firstWhere(
        (pr) => pr.id == repo.projectId,
        orElse: () => MockDataService.projects.first,
      );
      final commits = MockDataService.getCommitsForRepo(repo.id)
          .where(
            (c) => c.timestamp.isAfter(p.start) && c.timestamp.isBefore(p.end),
          )
          .toList();
      counts[project.name] = (counts[project.name] ?? 0) + commits.length;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _periods.length,
        itemBuilder: (ctx, i) {
          final p = _periods[i];
          final agg = _aggregateCommitsForPeriod(p);
          return Card(
            child: ExpansionTile(
              title: Text(
                '${p.name} (${p.start.toLocal().toShortDateString()} - ${p.end.toLocal().toShortDateString()})',
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Group commit summary',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...agg.entries.map(
                        (e) => Text('${e.key}: ${e.value} commits'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _canCreate
          ? FloatingActionButton.extended(
              onPressed: _createPeriod,
              icon: const Icon(Icons.add),
              label: const Text('Create Report Period'),
            )
          : null,
    );
  }
}

extension _DateHelpers on DateTime {
  String toShortDateString() =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}
