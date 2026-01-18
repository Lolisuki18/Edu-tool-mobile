import 'package:flutter/material.dart';

class RequirementsPage extends StatefulWidget {
  final String role;
  const RequirementsPage({this.role = 'Member', super.key});

  @override
  State<RequirementsPage> createState() => _RequirementsPageState();
}

class _RequirementsPageState extends State<RequirementsPage> {
  List<Map<String, String>> _requirements = [];

  @override
  void initState() {
    super.initState();
    _requirements = List.generate(
      5,
      (i) => {
        'id': 'req${i + 1}',
        'title': 'Requirement ${i + 1}',
        'status': i % 2 == 0 ? 'Open' : 'Done',
        'owner': i % 3 == 0 ? 'Charlie' : 'Bob',
      },
    );
  }

  bool get _canAdd => widget.role == 'Admin' || widget.role == 'Team Leader';
  bool get _canExportSRS =>
      widget.role == 'Team Leader' ||
      widget.role == 'Member' ||
      widget.role == 'Admin';

  void _addRequirement() {
    setState(() {
      final id = 'req${_requirements.length + 1}';
      _requirements.add({
        'id': id,
        'title': 'Requirement ${_requirements.length + 1}',
        'status': 'Open',
        'owner': 'Unassigned',
      });
    });
  }

  void _exportSRS() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('SRS exported (mock)')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _requirements.length,
        itemBuilder: (ctx, i) {
          final r = _requirements[i];
          return Card(
            child: ListTile(
              title: Text(r['title']!),
              subtitle: Text('Owner: ${r['owner']} • Status: ${r['status']}'),
              trailing: PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'toggle') {
                    setState(() {
                      r['status'] = r['status'] == 'Open' ? 'Done' : 'Open';
                    });
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'toggle',
                    child: Text('Toggle status'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_canExportSRS)
            FloatingActionButton.extended(
              heroTag: 'export',
              icon: const Icon(Icons.file_upload),
              label: const Text('Export SRS'),
              onPressed: _exportSRS,
            ),
          if (_canAdd)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: FloatingActionButton(
                heroTag: 'add',
                onPressed: _addRequirement,
                child: const Icon(Icons.add),
              ),
            ),
        ],
      ),
    );
  }
}
