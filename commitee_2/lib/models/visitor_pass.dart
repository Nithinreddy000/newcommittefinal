enum VisitorPassStatus { pending, approved, rejected }

class VisitorPass {
  final String id;
  final String visitorName;
  final String contactNumber;
  final String purpose;
  final DateTime visitDate;
  final String flatNumber;
  final bool isUsed;
  final String? status;
  final DateTime? createdAt;
  final DateTime? lastUpdated;

  const VisitorPass({
    required this.id,
    required this.visitorName,
    required this.contactNumber,
    required this.purpose,
    required this.visitDate,
    required this.flatNumber,
    this.isUsed = false,
    this.status = 'pending',
    this.createdAt,
    this.lastUpdated,
  });

  VisitorPass copyWith({
    String? visitorName,
    String? contactNumber,
    String? purpose,
    DateTime? visitDate,
    String? flatNumber,
    bool? isUsed,
    String? status,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) {
    return VisitorPass(
      id: this.id,
      visitorName: visitorName ?? this.visitorName,
      contactNumber: contactNumber ?? this.contactNumber,
      purpose: purpose ?? this.purpose,
      visitDate: visitDate ?? this.visitDate,
      flatNumber: flatNumber ?? this.flatNumber,
      isUsed: isUsed ?? this.isUsed,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toQRData() {
    return {
      'id': id,
      'visitorName': visitorName,
      'contactNumber': contactNumber,
      'purpose': purpose,
      'visitDate': visitDate.toIso8601String(),
      'flatNumber': flatNumber,
      'isUsed': isUsed,
      'status': status,
    };
  }
}