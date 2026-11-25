import 'package:flutter/foundation.dart';
import '../models/company.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService;

  Company? _currentCompany;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this.authService);

  Company? get currentCompany => _currentCompany;
  String? get token => _token;
  bool get isAuthenticated => _currentCompany != null && _token != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> checkSession() async {
    _isLoading = true;
    notifyListeners();
    try {
      final session = await authService.getSavedSession();
      if (session != null) {
        _token = session['token'] as String;
        _currentCompany = session['company'] as Company;
      }
    } catch (_) {
      _currentCompany = null;
      _token = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await authService.register(
        name: name,
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await authService.login(email: email, password: password);
      _token = res['token'] as String;
      _currentCompany = res['company'] as Company;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await authService.logout();
    _token = null;
    _currentCompany = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
