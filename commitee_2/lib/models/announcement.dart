enum AnnouncementPriority {
  low,
  normal,
  high,
  urgent
}

class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime datePosted;
  final String postedBy;
  final AnnouncementPriority priority;
  final List<String> visibleTo; // ['resident', 'security', 'admin']

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    DateTime? datePosted,
    required this.postedBy,
    this.priority = AnnouncementPriority.normal,
    this.visibleTo = const ['resident', 'security', 'admin'],
  }) : datePosted = datePosted ?? DateTime.now();
}

