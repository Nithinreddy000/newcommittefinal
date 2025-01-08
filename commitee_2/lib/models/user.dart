class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? flatNumber;
  final String? idNumber;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.flatNumber,
    this.idNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      flatNumber: json['flatNumber'],
      idNumber: json['idNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      if (flatNumber != null) 'flatNumber': flatNumber,
      if (idNumber != null) 'idNumber': idNumber,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? flatNumber,
    String? idNumber,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      flatNumber: flatNumber ?? this.flatNumber,
      idNumber: idNumber ?? this.idNumber,
    );
  }
}