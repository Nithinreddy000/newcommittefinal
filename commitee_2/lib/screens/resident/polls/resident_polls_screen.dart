import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/poll_provider.dart';
import '../../../models/poll.dart';
import '../../../services/auth_service.dart';
import '../../../models/user.dart';

class ResidentPollsScreen extends StatelessWidget {
  const ResidentPollsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Community Polls'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active Polls'),
              Tab(text: 'Past Polls'),
            ],
          ),
        ),
        body: Consumer<PollProvider>(
          builder: (context, provider, child) {
            final userId = context.read<AuthService>().currentUser!.id;
            final activePolls = provider.activePolls;
            final pastPolls = provider.polls.where((p) => !p.isActive).toList();

            return TabBarView(
              children: [
                _buildPollsList(activePolls, userId, true),
                _buildPollsList(pastPolls, userId, false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPollsList(List<Poll> polls, String userId, bool isActive) {
    if (polls.isEmpty) {
      return Center(
        child: Text(
          isActive ? 'No active polls' : 'No past polls',
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: polls.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final poll = polls[index];
        final hasVoted = poll.votedUsers.contains(userId);

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
                      'Created by ${poll.createdBy} on ${_formatDate(poll.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Expires on ${_formatDate(poll.expiresAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                trailing: poll.createdBy == userId
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
              if (hasVoted || !isActive) ...[
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
            onPressed: () {
              context.read<PollProvider>().deletePoll(pollId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Poll deleted successfully'),
                  backgroundColor: Colors.red,
                ),
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
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}