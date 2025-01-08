import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/poll_provider.dart';
import '../../../services/auth_service.dart';
import '../../../models/user.dart';
import '../../../models/poll.dart';
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
                  
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(poll.title),
                          subtitle: Text(poll.description),
                          trailing: poll.createdBy == currentUser.id ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditPollDialog(context, poll),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Poll'),
                                      content: const Text('Are you sure you want to delete this poll?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            context.read<PollProvider>().deletePoll(poll.id);
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Poll deleted successfully')),
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
                          ) : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...poll.options.map((option) {
                                final hasVoted = provider.hasUserVoted(poll.id, currentUser.id);
                                final voteCount = option.votes.length;
                                final totalVotes = poll.options.fold<int>(
                                  0,
                                  (sum, o) => sum + o.votes.length,
                                );
                                final percentage = totalVotes > 0
                                    ? (voteCount / totalVotes * 100).toStringAsFixed(1)
                                    : '0.0';

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: InkWell(
                                    onTap: hasVoted
                                        ? null
                                        : () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Confirm Vote'),
                                                content: Text('Do you want to vote for "${option.text}"?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text('No'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      provider.vote(poll.id, option.id, currentUser);
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Yes'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: hasVoted && option.votes.contains(currentUser.id)
                                              ? Colors.blue
                                              : Colors.grey,
                                          width: hasVoted && option.votes.contains(currentUser.id)
                                              ? 2
                                              : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              option.text,
                                              style: TextStyle(
                                                fontWeight: hasVoted && option.votes.contains(currentUser.id)
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          Text('$voteCount votes ($percentage%)'),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              if (provider.hasUserVoted(poll.id, currentUser.id))
                                const Padding(
                                  padding: EdgeInsets.only(top: 16.0),
                                  child: Text(
                                    'You have already voted in this poll',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
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
            onPressed: () async {
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
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditPollDialog(BuildContext context, Poll poll) {
    final formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController(text: poll.title);
    final _descriptionController = TextEditingController(text: poll.description);
    final _options = poll.options.map((option) => TextEditingController(text: option.text)).toList();

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
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title*',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => validateRequired(value, 'Title'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description*',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => validateRequired(value, 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ..._options.map((controller) => Padding(
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
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                await context.read<PollProvider>().editPoll(
                  poll.id,
                  title: _titleController.text.trim(),
                  description: _descriptionController.text.trim(),
                  options: _options
                      .map((controller) => controller.text.trim())
                      .where((text) => text.isNotEmpty)
                      .toList(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Poll edited successfully')),
                );
              }
            },
            child: const Text('Save'),
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