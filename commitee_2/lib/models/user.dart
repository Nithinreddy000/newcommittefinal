class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? flatNumber;
  final String? idNumber;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.flatNumber,
    this.idNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      flatNumber: json['flatNumber'],
      idNumber: json['idNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'flatNumber': flatNumber,
      'idNumber': idNumber,
    };
  }
} 