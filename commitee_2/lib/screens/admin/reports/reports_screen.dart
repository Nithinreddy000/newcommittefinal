import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReportCard('Member Statistics', Icons.people),
          _buildReportCard('Meeting Analytics', Icons.meeting_room),
          _buildReportCard('Task Completion', Icons.task),
          _buildReportCard('Financial Summary', Icons.monetization_on),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // TODO: Implement report details
        },
      ),
    );
  }
} 