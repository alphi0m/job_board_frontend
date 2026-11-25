class Job {
  final int id;
  final int companyId;
  final String companyName;
  final String title;
  final String description;
  final String location;
  final DateTime createdAt;
  final int applicationsCount;

  Job({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.title,
    required this.description,
    required this.location,
    required this.createdAt,
    this.applicationsCount = 0,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as int,
      companyId: json['company_id'] as int,
      companyName: json['company_name'] as String? ?? 'Azienda',
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String? ?? 'Remoto',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      applicationsCount: json['applications_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'company_name': companyName,
      'title': title,
      'description': description,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'applications_count': applicationsCount,
    };
  }
}
