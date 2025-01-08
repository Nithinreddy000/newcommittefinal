class Facility {
  final String id;
  final String name;
  final String description;
  final List<String> bookings;

  Facility({
    required this.id,
    required this.name,
    required this.description,
    List<String>? bookings,
  }) : bookings = bookings ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'bookings': bookings,
    };
  }

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      bookings: List<String>.from(json['bookings'] ?? []),
    );
  }

  Facility copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? bookings,
  }) {
    return Facility(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      bookings: bookings ?? this.bookings,
    );
  }
}