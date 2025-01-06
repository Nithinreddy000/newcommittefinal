import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/announcement_provider.dart';
import '../../../models/announcement.dart';

class ManageAnnouncementsScreen extends StatelessWidget {
  const ManageAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Announcements'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'View All'),
              Tab(text: 'Create New'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAnnouncementsList(),
            _buildAddAnnouncementForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    return Consumer<AnnouncementProvider>(
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
                subtitle: Text(announcement.content),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => provider.removeAnnouncement(announcement.id),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAddAnnouncementForm() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    AnnouncementPriority selectedPriority = AnnouncementPriority.normal;
    final visibleTo = {'resident': true, 'security': true, 'admin': true};

    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('New Announcement'),
        content: SingleChildScrollView(
          child: Column(
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
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AnnouncementPriority>(
                value: selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: AnnouncementPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedPriority = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text('Visible to:'),
              CheckboxListTile(
                title: const Text('Residents'),
                value: visibleTo['resident'],
                onChanged: (value) {
                  setState(() => visibleTo['resident'] = value!);
                },
              ),
              CheckboxListTile(
                title: const Text('Security'),
                value: visibleTo['security'],
                onChanged: (value) {
                  setState(() => visibleTo['security'] = value!);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && 
                  contentController.text.isNotEmpty) {
                final announcement = Announcement(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  content: contentController.text,
                  datePosted: DateTime.now(),
                  postedBy: 'Admin',
                  priority: selectedPriority,
                  visibleTo: visibleTo.entries
                      .where((e) => e.value)
                      .map((e) => e.key)
                      .toList(),
                );

                context.read<AnnouncementProvider>().addAnnouncement(announcement);
                Navigator.pop(context);
              }
            },
            child: const Text('Post'),
          ),
        ],
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