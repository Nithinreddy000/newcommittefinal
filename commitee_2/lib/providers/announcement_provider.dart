import 'package:flutter/foundation.dart';
import '../models/announcement.dart';

class AnnouncementProvider extends ChangeNotifier {
  final List<Announcement> _announcements = [];

  List<Announcement> get announcements => _announcements;

  void addAnnouncement({
    required String title,
    required String content,
    required String postedBy,
    AnnouncementPriority priority = AnnouncementPriority.normal,
    List<String> visibleTo = const ['resident', 'security', 'admin'],
  }) {
    final announcement = Announcement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      postedBy: postedBy,
      priority: priority,
      visibleTo: visibleTo,
    );
    _announcements.add(announcement);
    notifyListeners();
  }

  void removeAnnouncement(String id) {
    _announcements.removeWhere((announcement) => announcement.id == id);
    notifyListeners();
  }
} 