import 'package:flutter/material.dart';
import '../screens/common/notification_settings_screen.dart';

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.notifications),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NotificationSettingsScreen(),
          ),
        );
      },
    );
  }
} 