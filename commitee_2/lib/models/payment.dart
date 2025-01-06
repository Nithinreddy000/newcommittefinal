class Payment {
  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final PaymentType type;
  final PaymentStatus status;
  final String residentId;

  Payment({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.type,
    required this.status,
    required this.residentId,
  });
}

enum PaymentType {
  electricity,
  water,
  maintenance,
  parkingFee,
  securityFee,
  other
}

enum PaymentStatus {
  pending,
  paid,
  overdue,
  partiallyPaid
}

