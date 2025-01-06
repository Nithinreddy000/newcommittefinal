enum VisitorPassStatus { pending, approved, rejected }

class VisitorPass {
  final String id;
  final String visitorName;
  final String purpose;
  final DateTime visitDate;
  final VisitorPassStatus status;
  final String? qrCode;
  final String flatNumber;
  final String contactNumber;
  final bool isUsed;

  VisitorPass({
    required this.id,
    required this.visitorName,
    required this.purpose,
    required this.visitDate,
    this.status = VisitorPassStatus.pending,
    this.qrCode,
    required this.flatNumber,
    required this.contactNumber,
    this.isUsed = false,
  });

  Map<String, dynamic> toQRData() {
    return {
      'id': id,
      'visitorName': visitorName,
      'purpose': purpose,
      'visitDate': visitDate.toIso8601String(),
      'flatNumber': flatNumber,
      'contactNumber': contactNumber,
    };
  }
} 