import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/poll_provider.dart';
import '../../../models/poll.dart';

class ManagePollsScreen extends StatelessWidget {
  const ManagePollsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Polls'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active Polls'),
              Tab(text: 'Create Poll'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPollsList(),
            _buildCreatePollForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildPollsList() {
    return Consumer<PollProvider>(
      builder: (context, provider, child) {
        final polls = provider.polls;

        if (polls.isEmpty) {
          return const Center(
            child: Text('No polls created yet'),
          );
        }

        return ListView.builder(
          itemCount: polls.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final poll = polls[index];
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(poll.title),
                    subtitle: Text(poll.description),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: poll.isActive
                          ? () => provider.closePoll(poll.id)
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Results:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ...poll.options.map((option) {
                          final percentage = poll.votedUsers.isEmpty
                              ? 0.0
                              : (option.votes.length / poll.votedUsers.length) *
                                  100;
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(option.text),
                                  ),
                                  Text('${percentage.toStringAsFixed(1)}%'),
                                  Text(' (${option.votes.length} votes)'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey[200],
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
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCreatePollForm() {
    return const CreatePollForm();
  }
}

class CreatePollForm extends StatefulWidget {
  const CreatePollForm({super.key});

  @override
  State<CreatePollForm> createState() => _CreatePollFormState();
}

class _CreatePollFormState extends State<CreatePollForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Poll Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ..._optionControllers.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: entry.value,
                            decoration: InputDecoration(
                              labelText: 'Option ${entry.key + 1}',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an option';
                              }
                              return null;
                            },
                          ),
                        ),
                        if (_optionControllers.length > 2)
                          IconButton(
                            icon: const Icon(Icons.remove_circle),
                            onPressed: () => _removeOption(entry.key),
                          ),
                      ],
                    ),
                  ),
                ),
            TextButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add),
              label: const Text('Add Option'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Expires on: '),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    '${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitPoll,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Create Poll'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  void _submitPoll() {
    if (_formKey.currentState!.validate()) {
      final poll = Poll(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        createdAt: DateTime.now(),
        expiresAt: _expiryDate,
        createdBy: 'Admin',
        options: _optionControllers
            .map(
              (controller) => PollOption(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                text: controller.text,
              ),
            )
            .toList(),
      );

      context.read<PollProvider>().addPoll(poll);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Poll created successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _titleController.clear();
      _descriptionController.clear();
      for (var controller in _optionControllers) {
        controller.clear();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
} 