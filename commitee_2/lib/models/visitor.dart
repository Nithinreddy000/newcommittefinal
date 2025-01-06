class Visitor {
  final String id;
  final String name;
  final String purpose;
  final String flatNumber;
  final DateTime entryTime;
  DateTime? exitTime;
  final String contactNumber;
  final String vehicleNumber;
  final String approvedBy;
  bool isInside;
  String status;

  Visitor({
    required this.id,
    required this.name,
    required this.purpose,
    required this.flatNumber,
    required this.entryTime,
    this.exitTime,
    required this.contactNumber,
    this.vehicleNumber = '',
    required this.approvedBy,
    this.isInside = true,
    this.status = 'pending',
  });
} 