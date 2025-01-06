import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/poll_provider.dart';
import '../../../services/auth_service.dart';
import '../../../models/user.dart';
import '../../../mixins/form_validation_mixin.dart';

class PollScreen extends StatelessWidget with FormValidationMixin {
  final bool canCreate;
  
  const PollScreen({
    super.key,
    this.canCreate = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthService>().currentUser!;
    
    return Consumer<PollProvider>(
      builder: (context, provider, _) {
        final polls = provider.polls;
        
        return Column(
          children: [
            if (canCreate) Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _showCreatePollDialog(context),
                child: const Text('Create New Poll'),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: polls.length,
                itemBuilder: (context, index) {
                  final poll = polls[index];
                  final hasVoted = provider.hasUserVoted(poll.id, currentUser.id);
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ExpansionTile(
                      title: Text(poll.title),
                      subtitle: Text(
                        'Created by: ${poll.createdBy} on ${_formatDate(poll.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Description: ${poll.description}'),
                              const SizedBox(height: 16),
                              if (!hasVoted && poll.isActive) ...[
                                const Text('Cast your vote:',
                                  style: TextStyle(fontWeight: FontWeight.bold)
                                ),
                                ...poll.options.map((option) => ListTile(
                                  leading: Radio<String>(
                                    value: option.id,
                                    groupValue: null,
                                    onChanged: (_) => _castVote(
                                      context,
                                      poll.id,
                                      option.id,
                                      context.read<AuthService>().currentUser!,
                                    ),
                                  ),
                                  title: Text(option.text),
                                )),
                              ],
                              const SizedBox(height: 16),
                              const Text('Results:',
                                style: TextStyle(fontWeight: FontWeight.bold)
                              ),
                              ...poll.options.map((option) {
                                final voteCount = option.votes.length;
                                final totalVotes = poll.options
                                    .fold(0, (sum, opt) => sum + opt.votes.length);
                                final percentage = totalVotes > 0
                                    ? (voteCount / totalVotes * 100).toStringAsFixed(1)
                                    : '0.0';
                                
                                return ListTile(
                                  title: Text(option.text),
                                  subtitle: LinearProgressIndicator(
                                    value: totalVotes > 0
                                        ? voteCount / totalVotes
                                        : 0,
                                  ),
                                  trailing: Text('$voteCount ($percentage%)'),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCreatePollDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final optionsControllers = [TextEditingController(), TextEditingController()];

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
                  validator: (value) => validateRequired(value, 'Title'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description*',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => validateRequired(value, 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ...optionsControllers.map((controller) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextFormField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Option*',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => validateRequired(value, 'Option'),
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
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                context.read<PollProvider>().createPoll(
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  createdBy: context.read<AuthService>().currentUser!.name,
                  optionTexts: optionsControllers
                      .map((c) => c.text.trim())
                      .where((text) => text.isNotEmpty)
                      .toList(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Poll created successfully')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _castVote(BuildContext context, String pollId, String optionId, User currentUser) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Vote'),
        content: const Text('Are you sure you want to cast your vote? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PollProvider>().vote(pollId, optionId, currentUser);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vote cast successfully')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
} 