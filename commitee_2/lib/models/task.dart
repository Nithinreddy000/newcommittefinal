class Task {
  final String id;
  final String title;
  final String description;
  final String assignedTo;
  final DateTime dueDate;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.dueDate,
    this.isCompleted = false,
  });
} 