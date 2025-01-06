import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/poll_provider.dart';
import '../../../models/poll.dart';
import '../../../services/auth_service.dart';

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
            onPressed: () {
              context.read<PollProvider>().vote(pollId, optionId, userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vote cast successfully'),
                  backgroundColor: Colors.green,
                ),
              );
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
} 