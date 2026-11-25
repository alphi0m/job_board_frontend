import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
    required List<int> fileBytes,
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
      fileBytes: fileBytes,
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

  Future<bool> downloadAndOpenCv(CandidateApplication application) async {
    if (kIsWeb) {
      // Su Web/Chrome: apre il PDF in una nuova scheda
      final uri = Uri.parse(application.cvUrl);
      return await launchUrl(uri, mode: LaunchMode.platformDefault);
    } else {
      // Su Mobile (Android/iOS) e Desktop: scarica in locale e apre con il viewer nativo
      final bytes = await apiService.downloadBytes(application.cvUrl);
      final tempDir = await getTemporaryDirectory();
      final localPath =
          '${tempDir.path}/${application.id}_${application.cvOriginalName}';
      final file = File(localPath);
      await file.writeAsBytes(bytes, flush: true);

      final result = await OpenFilex.open(localPath);
      return result.type.name == 'done';
    }
  }
}
