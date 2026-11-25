import 'package:flutter_test/flutter_test.dart';
import 'package:job_board_frontend/models/job.dart';
import 'package:job_board_frontend/models/company.dart';
import 'package:job_board_frontend/models/application.dart';

void main() {
  group('Unit Test Modelli Front-end', () {
    test('Job model serialization/deserialization', () {
      final json = {
        'id': 1,
        'company_id': 10,
        'company_name': 'Acme Corp',
        'title': 'Flutter Senior Dev',
        'description': 'Ottima opportunità con Dart e Flutter.',
        'location': 'Ibrido',
        'created_at': '2026-11-25T10:00:00',
        'applications_count': 3,
      };

      final job = Job.fromJson(json);
      expect(job.id, 1);
      expect(job.companyName, 'Acme Corp');
      expect(job.title, 'Flutter Senior Dev');
      expect(job.applicationsCount, 3);
      expect(job.location, 'Ibrido');

      final serialized = job.toJson();
      expect(serialized['id'], 1);
      expect(serialized['title'], 'Flutter Senior Dev');
    });

    test('Company model deserialization', () {
      final json = {
        'id': 2,
        'name': 'OpenAI Tech',
        'email': 'hr@openaitech.com',
        'created_at': '2026-11-25T10:00:00',
      };

      final company = Company.fromJson(json);
      expect(company.id, 2);
      expect(company.name, 'OpenAI Tech');
      expect(company.email, 'hr@openaitech.com');
    });

    test('CandidateApplication model deserialization and fullName', () {
      final json = {
        'id': 5,
        'job_id': 1,
        'first_name': 'Mario',
        'last_name': 'Rossi',
        'email': 'mario.rossi@studenti.unisa.it',
        'cv_filename': 'abc.pdf',
        'cv_original_name': 'curriculum.pdf',
        'cv_url': 'http://localhost:8000/api/uploads/cv/abc.pdf',
        'created_at': '2026-11-25T10:00:00',
      };

      final app = CandidateApplication.fromJson(json);
      expect(app.fullName, 'Mario Rossi');
      expect(app.email, 'mario.rossi@studenti.unisa.it');
      expect(app.cvOriginalName, 'curriculum.pdf');
    });
  });
}
