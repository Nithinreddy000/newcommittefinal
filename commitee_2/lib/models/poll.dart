class Poll {
  final String id;
  final String title;
  final String description;
  final List<PollOption> options;
  final String createdBy;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final bool isActive;

  Poll({
    required this.id,
    required this.title,
    required this.description,
    required this.options,
    required this.createdBy,
    required this.createdAt,
    DateTime? lastUpdated,
    this.isActive = true,
  }) : this.lastUpdated = lastUpdated ?? createdAt;

  // Get all users who voted
  List<String> get votedUsers {
    final Set<String> users = {};
    for (var option in options) {
      users.addAll(option.votes);
    }
    return users.toList();
  }

  // Get expiry date (7 days from creation)
  DateTime get expiresAt => createdAt.add(const Duration(days: 7));

  Poll copyWith({
    String? id,
    String? title,
    String? description,
    List<PollOption>? options,
    String? createdBy,
    DateTime? createdAt,
    DateTime? lastUpdated,
    bool? isActive,
  }) {
    return Poll(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      options: options ?? this.options,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
    );
  }
}

class PollOption {
  final String id;
  final String text;
  final List<String> votes;

  PollOption({
    required this.id,
    required this.text,
    List<String>? votes,
  }) : this.votes = votes ?? [];

  PollOption copyWith({
    String? id,
    String? text,
    List<String>? votes,
  }) {
    return PollOption(
      id: id ?? this.id,
      text: text ?? this.text,
      votes: votes ?? this.votes,
    );
  }
}