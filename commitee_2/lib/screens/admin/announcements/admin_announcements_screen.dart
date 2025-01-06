import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/announcement_provider.dart';
import '../../../models/announcement.dart';

class AdminAnnouncementsScreen extends StatelessWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Announcements'),
      ),
      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, child) {
          if (provider.announcements.isEmpty) {
            return const Center(
              child: Text('No announcements yet'),
            );
          }

          return ListView.builder(
            itemCount: provider.announcements.length,
            itemBuilder: (context, index) {
              final announcement = provider.announcements[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: _getPriorityIcon(announcement.priority),
                  title: Text(announcement.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(announcement.content),
                      const SizedBox(height: 4),
                      Text(
                        'Posted on ${announcement.datePosted.toString().split(' ')[0]}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Visible to: ${announcement.visibleTo.join(', ')}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Announcement'),
                          content: const Text('Are you sure you want to delete this announcement?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                provider.removeAnnouncement(announcement.id);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Announcement deleted'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ManageAnnouncementsScreen(),
          ),
        ),
        child: const Icon(Icons.add),
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