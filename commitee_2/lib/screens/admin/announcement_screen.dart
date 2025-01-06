import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/announcement_provider.dart';
import '../../models/announcement.dart';
import '../../services/auth_service.dart';
import '../../mixins/form_validation_mixin.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> with FormValidationMixin {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => _showAddAnnouncementDialog(context),
            child: const Text('Add New Announcement'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<AnnouncementProvider>(
              builder: (context, provider, child) {
                return ListView.builder(
                  itemCount: provider.announcements.length,
                  itemBuilder: (context, index) {
                    final announcement = provider.announcements[index];
                    return Card(
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
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => provider.removeAnnouncement(announcement.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAnnouncementDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    AnnouncementPriority selectedPriority = AnnouncementPriority.normal;
    final visibilityOptions = <String>['resident', 'security', 'admin'];
    final selectedVisibility = <String>[...visibilityOptions];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Announcement'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title*',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => validateRequired(value, 'Title'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: contentController,
                        decoration: const InputDecoration(
                          labelText: 'Content*',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => validateRequired(value, 'Content'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<AnnouncementPriority>(
                        decoration: const InputDecoration(
                          labelText: 'Priority*',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedPriority,
                        validator: (value) => value == null ? 'Please select priority' : null,
                        items: AnnouncementPriority.values.map((priority) => 
                          DropdownMenuItem(
                            value: priority,
                            child: Text(priority.toString().split('.').last),
                          ),
                        ).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedPriority = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Visible to:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...visibilityOptions.map((option) {
                        return CheckboxListTile(
                          title: Text(option.toUpperCase()),
                          value: selectedVisibility.contains(option),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value!) {
                                selectedVisibility.add(option);
                              } else {
                                selectedVisibility.remove(option);
                              }
                            });
                          },
                        );
                      }),
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
                      final currentUser = context.read<AuthService>().currentUser;
                      context.read<AnnouncementProvider>().addAnnouncement(
                        title: titleController.text.trim(),
                        content: contentController.text.trim(),
                        postedBy: currentUser?.name ?? 'Admin',
                        priority: selectedPriority,
                        visibleTo: selectedVisibility,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Announcement added successfully')),
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
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