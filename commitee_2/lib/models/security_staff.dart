class SecurityStaff {
  final String id;
  final String name;
  final String location;
  final String contactNumber;
  bool isActive; // Change to mutable

  SecurityStaff({
    required this.id,
    required this.name,
    required this.location,
    required this.contactNumber,
    this.isActive = true, // Default to active
  });
} 