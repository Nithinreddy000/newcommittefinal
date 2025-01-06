class PaymentTransaction {
  final String id;
  final String userId;
  final String flatNumber;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String description;
  final PaymentStatus status;
  final String? transactionId;

  PaymentTransaction({
    required this.id,
    required this.userId,
    required this.flatNumber,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.description,
    this.status = PaymentStatus.pending,
    this.transactionId,
  });
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  overdue
} 