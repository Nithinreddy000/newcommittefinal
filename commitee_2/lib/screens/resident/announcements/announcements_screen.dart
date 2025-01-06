import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/announcement.dart';
import '../../../providers/announcement_provider.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
      ),
      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, child) {
          final announcements = provider.announcements
              .where((a) => a.visibleTo.contains('resident'))
              .toList();

          if (announcements.isEmpty) {
            return const Center(
              child: Text('No announcements yet'),
            );
          }

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: _getPriorityIcon(announcement.priority),
                  title: Text(
                    announcement.title,
                    style: TextStyle(
                      fontWeight: announcement.priority == AnnouncementPriority.urgent 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(announcement.content),
                      const SizedBox(height: 4),
                      Text(
                        'Posted by ${announcement.postedBy} on ${announcement.datePosted.toString().split(' ')[0]}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(announcement.title),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(announcement.content),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getPriorityIcon(AnnouncementPriority priority) {
    IconData iconData;
    Color color;

    switch (priority) {
      case AnnouncementPriority.urgent:
        iconData = Icons.warning;
        color = Colors.red;
        break;
      case AnnouncementPriority.high:
        iconData = Icons.priority_high;
        color = Colors.orange;
        break;
      case AnnouncementPriority.normal:
        iconData = Icons.info;
        color = Colors.blue;
        break;
      case AnnouncementPriority.low:
        iconData = Icons.info_outline;
        color = Colors.grey;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(iconData, color: color),
    );
  }
} 