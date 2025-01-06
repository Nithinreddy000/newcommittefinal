class Poll {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final DateTime createdAt;
  final List<PollOption> options;
  final bool isActive;

  Poll({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.options,
    this.isActive = true,
  });
}

class PollOption {
  final String id;
  final String text;
  final List<String> votes;

  PollOption({
    required this.id,
    required this.text,
    List<String>? votes,
  }) : votes = votes ?? [];
}

class PollResponse {
  final String userId;
  final String userName;
  final String text;

  PollResponse({
    required this.userId,
    required this.userName,
    required this.text,
  });
} 