import 'package:flutter/material.dart';
import '../../../models/meeting.dart';

class ManageMeetingsScreen extends StatefulWidget {
  const ManageMeetingsScreen({super.key});

  @override
  State<ManageMeetingsScreen> createState() => _ManageMeetingsScreenState();
}

class _ManageMeetingsScreenState extends State<ManageMeetingsScreen> {
  final List<Meeting> _meetings = [
    Meeting(
      id: '1',
      title: 'Monthly Review',
      date: DateTime.now(),
      agenda: 'Discuss project progress',
      attendees: ['John Doe', 'Jane Smith'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Meetings'),
      ),
      body: ListView.builder(
        itemCount: _meetings.length,
        itemBuilder: (context, index) {
          final meeting = _meetings[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(meeting.title),
              subtitle: Text(
                'Date: ${meeting.date.toString().split(' ')[0]}\n'
                'Agenda: ${meeting.agenda}\n'
                'Attendees: ${meeting.attendees.join(', ')}',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add meeting functionality
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 