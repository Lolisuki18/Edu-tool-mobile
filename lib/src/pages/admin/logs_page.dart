import 'package:flutter/material.dart';

class AdminLogsPage extends StatelessWidget {
  const AdminLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Logs',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text('Recent activity and system logs appear here.'),
        ],
      ),
    );
  }
}
