import 'package:flutter/material.dart';
import '../../../models/task.dart';

class ManageTasksScreen extends StatefulWidget {
  const ManageTasksScreen({super.key});

  @override
  State<ManageTasksScreen> createState() => _ManageTasksScreenState();
}

class _ManageTasksScreenState extends State<ManageTasksScreen> {
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Review Budget',
      description: 'Review and approve Q1 budget',
      assignedTo: 'John Doe',
      dueDate: DateTime.now().add(const Duration(days: 7)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tasks'),
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(task.title),
              subtitle: Text(
                'Assigned to: ${task.assignedTo}\n'
                'Due: ${task.dueDate.toString().split(' ')[0]}\n'
                'Status: ${task.isCompleted ? 'Completed' : 'Pending'}',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add task functionality
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 