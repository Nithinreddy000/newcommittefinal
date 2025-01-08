import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/announcement_provider.dart';
import '../../../models/announcement.dart';
import '../../../services/auth_service.dart';

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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditDialog(context, announcement),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteDialog(context, announcement),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditDialog(BuildContext context, [Announcement? announcement]) {
    final titleController = TextEditingController(text: announcement?.title ?? '');
    final contentController = TextEditingController(text: announcement?.content ?? '');
    AnnouncementPriority selectedPriority = announcement?.priority ?? AnnouncementPriority.normal;
    final visibleTo = {
      'resident': announcement?.visibleTo.contains('resident') ?? true,
      'security': announcement?.visibleTo.contains('security') ?? true,
      'admin': announcement?.visibleTo.contains('admin') ?? true,
    };
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(announcement == null ? 'Create Announcement' : 'Edit Announcement'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Content is required' : null,
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
                  const Text('Visible to:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  CheckboxListTile(
                    title: const Text('Admin'),
                    value: visibleTo['admin'],
                    onChanged: (value) {
                      setState(() => visibleTo['admin'] = value!);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final currentUser = context.read<AuthService>().currentUser!;
                  final visibleToList = visibleTo.entries
                      .where((e) => e.value)
                      .map((e) => e.key)
                      .toList();

                  if (announcement == null) {
                    // Create new announcement
                    final newAnnouncement = Announcement(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text,
                      content: contentController.text,
                      datePosted: DateTime.now(),
                      postedBy: currentUser.name,
                      priority: selectedPriority,
                      visibleTo: visibleToList,
                    );
                    context.read<AnnouncementProvider>().addAnnouncement(newAnnouncement);
                  } else {
                    // Update existing announcement
                    final updatedAnnouncement = Announcement(
                      id: announcement.id,
                      title: titleController.text,
                      content: contentController.text,
                      datePosted: announcement.datePosted,
                      postedBy: announcement.postedBy,
                      priority: selectedPriority,
                      visibleTo: visibleToList,
                      updatedAt: DateTime.now(),
                    );
                    context.read<AnnouncementProvider>().updateAnnouncement(updatedAnnouncement);
                  }
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        announcement == null
                            ? 'Announcement created successfully'
                            : 'Announcement updated successfully',
                      ),
                    ),
                  );
                }
              },
              child: Text(announcement == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Announcement announcement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: Text('Are you sure you want to delete "${announcement.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AnnouncementProvider>().removeAnnouncement(announcement.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Announcement deleted successfully')),
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