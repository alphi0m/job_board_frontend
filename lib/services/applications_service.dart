import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../models/application.dart';
import 'api_service.dart';

class ApplicationsService {
  final ApiService apiService;

  ApplicationsService(this.apiService);

  Future<Map<String, dynamic>> applyToJob({
    required int jobId,
    required String firstName,
    required String lastName,
    required String email,
    required String filePath,
    required String originalFilename,
  }) async {
    final res = await apiService.postMultipart(
      endpoint: '/api/jobs/$jobId/apply',
      fields: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
      },
      fileFieldName: 'cv',
      filePath: filePath,
      originalFilename: originalFilename,
    );
    return res as Map<String, dynamic>;
  }

  Future<List<CandidateApplication>> getJobApplications(int jobId) async {
    final res = await apiService.get('/api/jobs/$jobId/applications');
    final list = res as List<dynamic>;
    return list
        .map((item) =>
            CandidateApplication.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<OpenResult> downloadAndOpenCv(CandidateApplication application) async {
    // 1. Scarica i byte del file PDF dal server
    final bytes = await apiService.downloadBytes(application.cvUrl);

    // 2. Salva temporaneamente il file sul dispositivo
    final tempDir = await getTemporaryDirectory();
    final localPath =
        '${tempDir.path}/${application.id}_${application.cvOriginalName}';
    final file = File(localPath);
    await file.writeAsBytes(bytes, flush: true);

    // 3. Apre il PDF con il visualizzatore nativo del sistema operativo dello smartphone
    final result = await OpenFilex.open(localPath);
    return result;
  }
}
