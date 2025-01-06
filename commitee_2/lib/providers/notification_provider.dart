import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationProvider extends ChangeNotifier {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final List<String> _subscribedTopics = [];

  List<String> get subscribedTopics => _subscribedTopics;

  Future<void> initialize() async {
    // Request permission
    if (!kIsWeb) {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Initialize local notifications
    if (!kIsWeb) {
      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _localNotifications.initialize(initializationSettings);
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kIsWeb) {
        // Web handles notifications through the service worker
        return;
      }

      _showLocalNotification(message);
    });
  }

  Future<void> subscribeToTopic(String topic) async {
    if (kIsWeb) {
      // Web doesn't support topic subscription directly
      print('Topic subscription not supported on web');
      return;
    }

    try {
      await _messaging.subscribeToTopic(topic);
      _subscribedTopics.add(topic);
      notifyListeners();
    } catch (e) {
      print('Failed to subscribe to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    if (kIsWeb) {
      // Web doesn't support topic subscription directly
      print('Topic unsubscription not supported on web');
      return;
    }

    try {
      await _messaging.unsubscribeFromTopic(topic);
      _subscribedTopics.remove(topic);
      notifyListeners();
    } catch (e) {
      print('Failed to unsubscribe from topic: $e');
    }
  }

  Future<void> subscribeToRoleTopics(String role) async {
    if (kIsWeb) {
      print('Topic subscription not supported on web');
      return;
    }

    try {
      // Subscribe to general topic
      await subscribeToTopic('all');
      
      // Subscribe to role-specific topic
      await subscribeToTopic(role);
      
      // For residents, also subscribe to their flat number if available
      if (role == 'resident') {
        // You might want to pass the flat number as a parameter
        // await subscribeToTopic('flat_$flatNumber');
      }
    } catch (e) {
      print('Failed to subscribe to role topics: $e');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (kIsWeb) return;

    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default Channel',
            channelDescription: 'Default notification channel',
            importance: Importance.max,
            priority: Priority.high,
            icon: android?.smallIcon,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    }
  }
} 