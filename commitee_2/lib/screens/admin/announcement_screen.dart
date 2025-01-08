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
            onPressed: () => _showAnnouncementDialog(context),
            child: const Text('Add New Announcement'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<AnnouncementProvider>(
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
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: _getPriorityIcon(announcement.priority),
                        title: Text(announcement.title),
                        subtitle: Text(
                          'Posted by ${announcement.postedBy} on ${_formatDate(announcement.datePosted)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(announcement.content),
                                const SizedBox(height: 8),
                                Text(
                                  'Visible to: ${announcement.visibleTo.map((e) => e.toUpperCase()).join(', ')}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (announcement.lastUpdated != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Last updated: ${_formatDate(announcement.lastUpdated!)}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Edit'),
                                      onPressed: () => _showAnnouncementDialog(
                                        context,
                                        announcement: announcement,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      icon: const Icon(Icons.delete),
                                      label: const Text('Delete'),
                                      onPressed: () => _showDeleteDialog(context, announcement),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
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

  void _showAnnouncementDialog(BuildContext context, {Announcement? announcement}) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: announcement?.title ?? '');
    final contentController = TextEditingController(text: announcement?.content ?? '');
    AnnouncementPriority selectedPriority = announcement?.priority ?? AnnouncementPriority.normal;
    final visibilityOptions = <String>['resident', 'security', 'admin'];
    final selectedVisibility = <String>[
      ...announcement?.visibleTo ?? visibilityOptions,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(announcement == null ? 'Add New Announcement' : 'Edit Announcement'),
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
                            child: Text(priority.toString().split('.').last.toUpperCase()),
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
                                if (selectedVisibility.length > 1) {
                                  selectedVisibility.remove(option);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('At least one visibility option must be selected'),
                                    ),
                                  );
                                }
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
                      
                      if (announcement == null) {
                        // Create new announcement
                        context.read<AnnouncementProvider>().addAnnouncement(
                          title: titleController.text.trim(),
                          content: contentController.text.trim(),
                          postedBy: currentUser?.name ?? 'Admin',
                          priority: selectedPriority,
                          visibleTo: selectedVisibility,
                        );
                      } else {
                        // Update existing announcement
                        final updatedAnnouncement = Announcement(
                          id: announcement.id,
                          title: titleController.text.trim(),
                          content: contentController.text.trim(),
                          datePosted: announcement.datePosted,
                          postedBy: announcement.postedBy,
                          priority: selectedPriority,
                          visibleTo: selectedVisibility,
                          lastUpdated: DateTime.now(),
                        );
                        context.read<AnnouncementProvider>().updateAnnouncement(updatedAnnouncement);
                      }

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            announcement == null
                                ? 'Announcement added successfully'
                                : 'Announcement updated successfully',
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(announcement == null ? 'Add' : 'Update'),
                ),
              ],
            );
          },
        );
      },
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

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
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

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(iconData, color: color),
    );
  }
}