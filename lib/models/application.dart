class CandidateApplication {
  final int id;
  final int jobId;
  final String firstName;
  final String lastName;
  final String email;
  final String cvFilename;
  final String cvOriginalName;
  final String cvUrl;
  final DateTime createdAt;

  CandidateApplication({
    required this.id,
    required this.jobId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.cvFilename,
    required this.cvOriginalName,
    required this.cvUrl,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  factory CandidateApplication.fromJson(Map<String, dynamic> json) {
    return CandidateApplication(
      id: json['id'] as int,
      jobId: json['job_id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      cvFilename: json['cv_filename'] as String,
      cvOriginalName: json['cv_original_name'] as String? ?? 'curriculum.pdf',
      cvUrl: json['cv_url'] as String,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
