import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import '../../models/visitor_pass.dart';
import '../../providers/visitor_pass_provider.dart';
import '../../providers/poll_provider.dart';
import '../../providers/facility_provider.dart';
import '../../providers/announcement_provider.dart';
import '../../services/auth_service.dart';
import '../../models/poll.dart';
import '../../models/announcement.dart';
import 'visitor/generate_pass_screen.dart';
import 'facilities/facilities_screen.dart';
import '../auth/login_screen.dart';
import '../../screens/common/polls/poll_screen.dart';
import '../../providers/security_provider.dart';
import '../../models/security_staff.dart';
import 'polls/resident_polls_screen.dart';
import 'visitors/resident_visitor_log_screen.dart';
import '../common/profile_screen.dart'; // Fixed import path for ProfileScreen

class ResidentDashboard extends StatefulWidget {
  const ResidentDashboard({super.key});

  @override
  State<ResidentDashboard> createState() => _ResidentDashboardState();
}

class _ResidentDashboardState extends State<ResidentDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resident Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              final authService = context.read<AuthService>();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Provider.value(
                    value: authService.currentUser,
                    child: const ProfileScreen(),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthService>().logout();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.poll),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ResidentPollsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildAnnouncementsTab(context),
          _buildFacilitiesTab(context),
          _buildVisitorsTab(context),
          _buildPollsTab(context),
          _buildSecurityStaffTab(context),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.notifications),
            selectedIcon: Icon(Icons.notifications),
            label: 'Announcements',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment_outlined),
            selectedIcon: Icon(Icons.apartment),
            label: 'Facilities',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Visitors',
          ),
          NavigationDestination(
            icon: Icon(Icons.poll_outlined),
            selectedIcon: Icon(Icons.poll),
            label: 'Polls',
          ),
          NavigationDestination(
            icon: Icon(Icons.security_outlined),
            selectedIcon: Icon(Icons.security),
            label: 'Security Staff',
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsTab(BuildContext context) {
    return Consumer<AnnouncementProvider>(
      builder: (context, provider, child) {
        final announcements = provider.announcements
            .where((a) => a.visibleTo.contains('resident'))
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
              margin: const EdgeInsets.all(8),
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
    );
  }

  Widget _buildFacilitiesTab(BuildContext context) {
    return const FacilitiesScreen();
  }

  Widget _buildVisitorsTab(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GeneratePassScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Generate Pass'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ResidentVisitorLogScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('View Logs'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<VisitorPassProvider>(
            builder: (context, provider, child) {
              final passes = provider.passes;

              if (passes.isEmpty) {
                return const Center(
                  child: Text('No active visitor passes'),
                );
              }

              return ListView.builder(
                itemCount: passes.length,
                itemBuilder: (context, index) {
                  final pass = passes[index];
                  return Card(
                    margin: const EdgeInsets.all(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Visitor: ${pass.visitorName}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => GeneratePassScreen(
                                            pass: pass,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Pass'),
                                          content: const Text('Are you sure you want to delete this visitor pass?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                context.read<VisitorPassProvider>().deletePass(pass.id);
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Visitor pass deleted')),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Purpose: ${pass.purpose}'),
                          Text('Status: ${pass.status}'),
                          Text('Visit Date: ${pass.visitDate.toString().split(' ')[0]}'),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
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

  void _showPassDetailsDialog(BuildContext context, VisitorPass pass) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          pass.visitorName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('Purpose: ${pass.purpose}'),
                  Text('Status: ${pass.status}'),
                  Text('Visit Date: ${pass.visitDate.toString().split(' ')[0]}'),
                  Text('Contact: ${pass.contactNumber}'),
                  Text('Flat Number: ${pass.flatNumber}'),
                  const SizedBox(height: 24),
                  Center(
                    child: QrImageView(
                      data: jsonEncode(pass.toQRData()),
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecurityStaffTab(BuildContext context) {
    return Consumer<SecurityProvider>(
      builder: (context, provider, child) {
        final activeStaff = provider.activeStaff;

        if (activeStaff.isEmpty) {
          return const Center(child: Text('No active security staff available.'));
        }

        return ListView.builder(
          itemCount: activeStaff.length,
          itemBuilder: (context, index) {
            final staff = activeStaff[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(staff.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Location: ${staff.location}'),
                    Text('Contact: ${staff.contactNumber}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () {
                    _confirmCall(context, staff.contactNumber);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmCall(BuildContext context, String contactNumber) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Call'),
          content: Text('Do you want to call $contactNumber?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement the call functionality here
                // For example, using url_launcher package
                Navigator.pop(context);
              },
              child: const Text('Call'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPollsTab(BuildContext context) {
    return Consumer2<PollProvider, AuthService>(
      builder: (context, pollProvider, authService, child) {
        final userId = authService.currentUser!.id;
        final polls = pollProvider.polls;

        return Stack(
          children: [
            if (polls.isEmpty)
              const Center(
                child: Text('No polls available'),
              )
            else
              ListView.builder(
                itemCount: polls.length,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Added bottom padding for FAB
                itemBuilder: (context, index) {
                  final poll = polls[index];
                  final hasVoted = poll.votedUsers.contains(userId);
                  final isCreator = poll.createdBy == userId;

                  return Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(poll.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(poll.description),
                              const SizedBox(height: 4),
                              Text(
                                'Created on ${_formatDate(poll.createdAt)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'Expires on ${_formatDate(poll.expiresAt)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: isCreator
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _showEditPollDialog(context, poll),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                      onPressed: () => _showDeletePollDialog(context, poll.id),
                                    ),
                                  ],
                                )
                              : null,
                          isThreeLine: true,
                        ),
                        if (hasVoted || !poll.isActive) ...[
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hasVoted ? 'Your Vote Results:' : 'Results:',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                ...poll.options.map((option) {
                                  final percentage = poll.votedUsers.isEmpty
                                      ? 0.0
                                      : (option.votes.length / poll.votedUsers.length) * 100;
                                  final userVoted = option.votes.contains(userId);
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          if (userVoted)
                                            const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 20,
                                            ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(option.text),
                                          ),
                                          Text('${percentage.toStringAsFixed(1)}%'),
                                          Text(' (${option.votes.length})'),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      LinearProgressIndicator(
                                        value: percentage / 100,
                                        backgroundColor: Colors.grey[200],
                                        color: userVoted ? Colors.green : null,
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  );
                                }),
                                Text(
                                  'Total votes: ${poll.votedUsers.length}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Cast your vote:'),
                                const SizedBox(height: 8),
                                ...poll.options.map((option) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: ElevatedButton(
                                        onPressed: () => _castVote(context, poll.id, option.id, userId),
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size(double.infinity, 48),
                                        ),
                                        child: Text(option.text),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: () => _showCreatePollDialog(context),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCreatePollDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final optionsControllers = [
      TextEditingController(),
      TextEditingController(),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Poll'),
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
                  validator: (value) => value?.isEmpty ?? true ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description*',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) => value?.isEmpty ?? true ? 'Description is required' : null,
                ),
                const SizedBox(height: 16),
                const Text('Options:'),
                const SizedBox(height: 8),
                ...optionsControllers.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: entry.value,
                              decoration: InputDecoration(
                                labelText: 'Option ${entry.key + 1}*',
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) => value?.isEmpty ?? true ? 'Option cannot be empty' : null,
                            ),
                          ),
                          if (optionsControllers.length > 2)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: Colors.red,
                              onPressed: () {
                                setState(() {
                                  optionsControllers.removeAt(entry.key);
                                });
                              },
                            ),
                        ],
                      ),
                    )),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      optionsControllers.add(TextEditingController());
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Option'),
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
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  final userId = context.read<AuthService>().currentUser!.id;
                  await context.read<PollProvider>().createPoll(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    options: optionsControllers
                        .map((c) => c.text.trim())
                        .where((text) => text.isNotEmpty)
                        .toList(),
                    createdBy: userId,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Poll created successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create poll: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditPollDialog(BuildContext context, Poll poll) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: poll.title);
    final descriptionController = TextEditingController(text: poll.description);
    final optionsControllers = poll.options.map((option) => TextEditingController(text: option.text)).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Poll'),
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
                  validator: (value) => value?.isEmpty ?? true ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description*',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) => value?.isEmpty ?? true ? 'Description is required' : null,
                ),
                const SizedBox(height: 16),
                ...optionsControllers.map((controller) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextFormField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: 'Option',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Option cannot be empty' : null,
                      ),
                    )),
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
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  await context.read<PollProvider>().editPoll(
                    poll.id,
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    options: optionsControllers
                        .map((c) => c.text.trim())
                        .where((text) => text.isNotEmpty)
                        .toList(),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Poll updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update poll: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeletePollDialog(BuildContext context, String pollId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Poll'),
        content: const Text('Are you sure you want to delete this poll? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<PollProvider>().deletePoll(pollId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Poll deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete poll: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _castVote(BuildContext context, String pollId, String optionId, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Vote'),
        content: const Text('Are you sure you want to cast your vote? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final user = context.read<AuthService>().currentUser!;
                await context.read<PollProvider>().vote(pollId, optionId, user);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vote cast successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to cast vote: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildDashboardItem(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: onPressed,
    );
  }

  Widget _buildGridItem(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}