import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/poll.dart';
import '../../../providers/poll_provider.dart';
import '../../../services/auth_service.dart';

class ManagePollsScreen extends StatelessWidget {
  const ManagePollsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PollProvider>(
      builder: (context, provider, _) {
        final polls = provider.polls;
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () => _showPollDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Create New Poll'),
              ),
            ),
            Expanded(
              child: polls.isEmpty
                  ? const Center(
                      child: Text('No polls created yet'),
                    )
                  : ListView.builder(
                      itemCount: polls.length,
                      itemBuilder: (context, index) {
                        final poll = polls[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ExpansionTile(
                            title: Text(poll.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Created on: ${_formatDateTime(poll.createdAt)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (poll.lastUpdated != null)
                                  Text(
                                    'Last updated: ${_formatDateTime(poll.lastUpdated!)}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                Text(
                                  'Status: ${poll.isActive ? 'Active' : 'Closed'}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: poll.isActive ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showPollDialog(
                                    context,
                                    poll: poll,
                                  ),
                                  tooltip: 'Edit Poll',
                                ),
                                IconButton(
                                  icon: Icon(
                                    poll.isActive
                                        ? Icons.pause_circle_outline
                                        : Icons.play_circle_outline,
                                  ),
                                  onPressed: () {
                                    provider.togglePollStatus(poll.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          poll.isActive
                                              ? 'Poll closed successfully'
                                              : 'Poll activated successfully',
                                        ),
                                      ),
                                    );
                                  },
                                  tooltip: poll.isActive ? 'Close Poll' : 'Activate Poll',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _showDeleteDialog(context, poll),
                                  tooltip: 'Delete Poll',
                                  color: Colors.red,
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      poll.description,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Options:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    ...poll.options.map((option) {
                                      final totalVotes = poll.options
                                          .map((o) => o.votes.length)
                                          .fold(0, (a, b) => a + b);
                                      final percentage = totalVotes > 0
                                          ? (option.votes.length / totalVotes * 100).toStringAsFixed(1)
                                          : '0.0';

                                      return ListTile(
                                        title: Text(option.text),
                                        trailing: Text(
                                          '${option.votes.length} votes ($percentage%)',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
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

  void _showPollDialog(BuildContext context, {Poll? poll}) {
    final titleController = TextEditingController(text: poll?.title ?? '');
    final descriptionController = TextEditingController(text: poll?.description ?? '');
    final optionsControllers = List.generate(
      (poll?.options.length ?? 0) > 0 ? poll!.options.length : 2,
      (index) => TextEditingController(
        text: (poll?.options.length ?? 0) > index ? poll!.options[index].text : '',
      ),
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(poll == null ? 'Create Poll' : 'Edit Poll'),
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
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Description is required' : null,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Options:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...optionsControllers.asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller,
                                decoration: InputDecoration(
                                  labelText: 'Option ${index + 1}',
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (value) => value?.isEmpty ?? true
                                    ? 'Option ${index + 1} is required'
                                    : null,
                              ),
                            ),
                            if (optionsControllers.length > 2)
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    optionsControllers.removeAt(index);
                                  });
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
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
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final currentUser = context.read<AuthService>().currentUser!;
                  final options = optionsControllers.map((controller) {
                    return PollOption(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      text: controller.text,
                    );
                  }).toList();

                  if (poll == null) {
                    // Create new poll
                    final newPoll = Poll(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text,
                      description: descriptionController.text,
                      createdBy: currentUser.id,
                      createdAt: DateTime.now(),
                      options: options,
                      isActive: true,
                    );
                    context.read<PollProvider>().addPoll(newPoll);
                  } else {
                    // Update existing poll
                    final updatedPoll = poll.copyWith(
                      title: titleController.text,
                      description: descriptionController.text,
                      options: options,
                      lastUpdated: DateTime.now(),
                    );
                    context.read<PollProvider>().updatePoll(updatedPoll);
                  }
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        poll == null
                            ? 'Poll created successfully'
                            : 'Poll updated successfully',
                      ),
                    ),
                  );
                }
              },
              child: Text(poll == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Poll poll) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Poll'),
        content: Text('Are you sure you want to delete this poll?\n\nTitle: ${poll.title}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PollProvider>().removePoll(poll.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Poll deleted successfully')),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}