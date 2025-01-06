import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: const Text('Announcements'),
                subtitle: const Text('Receive notifications for new announcements'),
                value: provider.subscribedTopics.contains('announcements'),
                onChanged: (value) async {
                  if (value) {
                    await provider.subscribeToTopic('announcements');
                  } else {
                    await provider.unsubscribeFromTopic('announcements');
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Polls'),
                subtitle: const Text('Receive notifications for new polls'),
                value: provider.subscribedTopics.contains('polls'),
                onChanged: (value) async {
                  if (value) {
                    await provider.subscribeToTopic('polls');
                  } else {
                    await provider.unsubscribeFromTopic('polls');
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Visitors'),
                subtitle: const Text('Receive notifications when visitors arrive'),
                value: provider.subscribedTopics.contains('visitors'),
                onChanged: (value) async {
                  if (value) {
                    await provider.subscribeToTopic('visitors');
                  } else {
                    await provider.unsubscribeFromTopic('visitors');
                  }
                },
              ),
              // Add more notification settings as needed
            ],
          );
        },
      ),
    );
  }
} 