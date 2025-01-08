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

  Member copyWith({
    String? name,
    String? email,
    String? flatNumber,
    String? idNumber,
    String? contactNumber,
    String? role,
  }) {
    return Member(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      flatNumber: flatNumber ?? this.flatNumber,
      idNumber: idNumber ?? this.idNumber,
      contactNumber: contactNumber ?? this.contactNumber,
      role: role ?? this.role,
    );
  }
}