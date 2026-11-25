import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/company.dart';
import 'api_service.dart';

class AuthService {
  static const String _prefTokenKey = 'job_board_token';
  static const String _prefCompanyKey = 'job_board_company';

  final ApiService apiService;

  AuthService(this.apiService);

  Future<Company> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await apiService.post('/api/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    return Company.fromJson(res as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await apiService.post('/api/auth/login', {
      'email': email,
      'password': password,
    });

    final token = res['access_token'] as String;
    final company = Company.fromJson(res['company'] as Map<String, dynamic>);

    // Salva sessione in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefTokenKey, token);
    await prefs.setString(_prefCompanyKey, json.encode(company.toJson()));

    apiService.updateToken(token);

    return {
      'token': token,
      'company': company,
    };
  }

  Future<Map<String, dynamic>?> getSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_prefTokenKey);
    final companyRaw = prefs.getString(_prefCompanyKey);

    if (token != null && companyRaw != null) {
      try {
        final companyJson = json.decode(companyRaw) as Map<String, dynamic>;
        final company = Company.fromJson(companyJson);
        apiService.updateToken(token);
        return {
          'token': token,
          'company': company,
        };
      } catch (_) {
        await clearSavedSession();
      }
    }
    return null;
  }

  Future<void> logout() async {
    try {
      await apiService.post('/api/auth/logout', {});
    } catch (_) {
      // Ignora errori di rete sul logout: procediamo comunque alla rimozione locale
    } finally {
      await clearSavedSession();
      apiService.updateToken(null);
    }
  }

  Future<void> clearSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefTokenKey);
    await prefs.remove(_prefCompanyKey);
  }
}
