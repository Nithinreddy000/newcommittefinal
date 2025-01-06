import 'package:flutter/material.dart';

class ComplaintsScreen extends StatelessWidget {
  const ComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> complaints = [
      {
        'id': '1',
        'title': 'Water Leakage',
        'description': 'Water leakage in bathroom',
        'status': 'Pending',
        'date': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': '2',
        'title': 'Electricity Issue',
        'description': 'Frequent power fluctuations',
        'status': 'In Progress',
        'date': DateTime.now().subtract(const Duration(days: 5)),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints'),
      ),
      body: ListView.builder(
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          final complaint = complaints[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.report_problem, size: 32),
              title: Text(complaint['title'] as String),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(complaint['description'] as String),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${complaint['status']}\n'
                    'Date: ${(complaint['date'] as DateTime).toString().split(' ')[0]}',
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showComplaintDetails(context, complaint),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddComplaintDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showComplaintDetails(BuildContext context, Map<String, dynamic> complaint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(complaint['title'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${complaint['description']}'),
            const SizedBox(height: 8),
            Text('Status: ${complaint['status']}'),
            Text(
              'Date: ${(complaint['date'] as DateTime).toString().split(' ')[0]}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddComplaintDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Complaint'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement complaint submission
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Complaint submitted successfully!'),
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
} 