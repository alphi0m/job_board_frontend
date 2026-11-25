import '../models/job.dart';
import 'api_service.dart';

class JobsService {
  final ApiService apiService;

  JobsService(this.apiService);

  Future<List<Job>> getPublicJobs() async {
    final res = await apiService.get('/api/jobs');
    final list = res as List<dynamic>;
    return list.map((item) => Job.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Job> getJobDetail(int jobId) async {
    final res = await apiService.get('/api/jobs/$jobId');
    return Job.fromJson(res as Map<String, dynamic>);
  }

  Future<Job> createJob({
    required String title,
    required String description,
    String? location,
  }) async {
    final res = await apiService.post('/api/jobs', {
      'title': title,
      'description': description,
      'location': location ?? 'Remoto',
    });
    return Job.fromJson(res as Map<String, dynamic>);
  }

  Future<List<Job>> getCompanyJobs() async {
    final res = await apiService.get('/api/company/my-jobs');
    final list = res as List<dynamic>;
    return list.map((item) => Job.fromJson(item as Map<String, dynamic>)).toList();
  }
}
