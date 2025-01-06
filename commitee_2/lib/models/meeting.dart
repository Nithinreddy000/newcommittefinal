class Meeting {
  final String id;
  final String title;
  final DateTime date;
  final String agenda;
  final List<String> attendees;
  final String status;

  Meeting({
    required this.id,
    required this.title,
    required this.date,
    required this.agenda,
    required this.attendees,
    this.status = 'Scheduled',
  });
} 