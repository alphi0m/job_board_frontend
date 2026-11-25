import 'package:flutter/foundation.dart';
import '../models/job.dart';
import '../models/application.dart';
import '../services/jobs_service.dart';
import '../services/applications_service.dart';

class JobsProvider extends ChangeNotifier {
  final JobsService jobsService;
  final ApplicationsService applicationsService;

  List<Job> _publicJobs = [];
  List<Job> _companyJobs = [];
  List<CandidateApplication> _currentApplications = [];

  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;

  JobsProvider({
    required this.jobsService,
    required this.applicationsService,
  });

  List<Job> get publicJobs => _publicJobs;
  List<Job> get companyJobs => _companyJobs;
  List<CandidateApplication> get currentApplications => _currentApplications;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPublicJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _publicJobs = await jobsService.getPublicJobs();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCompanyJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _companyJobs = await jobsService.getCompanyJobs();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createJob({
    required String title,
    required String description,
    String? location,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await jobsService.createJob(
        title: title,
        description: description,
        location: location,
      );
      // Aggiorna sia gli annunci dell'azienda che la bacheca pubblica
      await fetchCompanyJobs();
      await fetchPublicJobs();
      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchApplications(int jobId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentApplications =
          await applicationsService.getJobApplications(jobId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyToJob({
    required int jobId,
    required String firstName,
    required String lastName,
    required String email,
    required List<int> fileBytes,
    required String originalFilename,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await applicationsService.applyToJob(
        jobId: jobId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        fileBytes: fileBytes,
        originalFilename: originalFilename,
      );
      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> openCandidateCv(CandidateApplication app) async {
    try {
      return await applicationsService.downloadAndOpenCv(app);
    } catch (e) {
      _errorMessage = 'Impossibile aprire il CV: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
