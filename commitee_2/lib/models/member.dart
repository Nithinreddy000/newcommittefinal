import 'package:flutter/foundation.dart';

class Member {
  final String id;
  final String name;
  final String email;
  final String? flatNumber;
  final String? idNumber;
  final String contactNumber;
  final String role;

  Member({
    required this.id,
    required this.name,
    required this.email,
    this.flatNumber,
    this.idNumber,
    required this.contactNumber,
    this.role = 'resident',
  });
} 