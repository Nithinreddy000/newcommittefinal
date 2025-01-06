import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/announcement_provider.dart';
import '../../../models/announcement.dart';

class SecurityAnnouncementsScreen extends StatelessWidget {
  const SecurityAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
      ),
      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, child) {
          final announcements = provider.announcements
              .where((a) => a.visibleTo.contains('security'))
              .toList();

          if (announcements.isEmpty) {
            return const Center(
              child: Text('No announcements available'),
            );
          }

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  leading: _getPriorityIcon(announcement.priority),
                  title: Text(announcement.title),
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
      case AnnouncementPriority.low:
        iconData = Icons.info_outline;
        color = Colors.blue;
        break;
      case AnnouncementPriority.normal:
        iconData = Icons.info;
        color = Colors.green;
        break;
      case AnnouncementPriority.high:
        iconData = Icons.warning;
        color = Colors.orange;
        break;
      case AnnouncementPriority.urgent:
        iconData = Icons.error;
        color = Colors.red;
        break;
    }

    return Icon(iconData, color: color);
  }
} 