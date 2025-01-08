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
  final DateTime? lastUpdated;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    DateTime? datePosted,
    required this.postedBy,
    this.priority = AnnouncementPriority.normal,
    this.visibleTo = const ['resident', 'security', 'admin'],
    this.lastUpdated,
  }) : datePosted = datePosted ?? DateTime.now();

  Announcement copyWith({
    String? title,
    String? content,
    DateTime? datePosted,
    String? postedBy,
    AnnouncementPriority? priority,
    List<String>? visibleTo,
    DateTime? lastUpdated,
  }) {
    return Announcement(
      id: this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      datePosted: datePosted ?? this.datePosted,
      postedBy: postedBy ?? this.postedBy,
      priority: priority ?? this.priority,
      visibleTo: visibleTo ?? List.from(this.visibleTo),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
