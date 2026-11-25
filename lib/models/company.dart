class Company {
  final int id;
  final String name;
  final String email;
  final DateTime createdAt;

  Company({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
