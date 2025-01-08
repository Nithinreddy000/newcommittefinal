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

  Visitor copyWith({
    String? name,
    String? purpose,
    String? contactNumber,
    String? vehicleNumber,
    String? flatNumber,
    DateTime? exitTime,
    bool? isInside,
    String? status,
  }) {
    return Visitor(
      id: this.id,
      name: name ?? this.name,
      purpose: purpose ?? this.purpose,
      flatNumber: flatNumber ?? this.flatNumber,
      entryTime: this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      contactNumber: contactNumber ?? this.contactNumber,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      approvedBy: this.approvedBy,
      isInside: isInside ?? this.isInside,
      status: status ?? this.status,
    );
  }
}