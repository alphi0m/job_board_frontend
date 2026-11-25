import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig extends ChangeNotifier {
  static const String _prefKey = 'job_board_backend_url';

  // Default IP: per Android Emulator è 10.0.2.2, per iOS Simulator è localhost.
  // Su smartphone fisico, l'utente può inserire l'IP del computer (es. 192.168.1.X:8000) o tunnel.
  static const String _defaultUrl = 'http://10.0.2.2:8000';

  String _baseUrl = _defaultUrl;

  String get baseUrl => _baseUrl;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null && saved.trim().isNotEmpty) {
      _baseUrl = saved.trim();
    } else {
      if (kIsWeb) {
        _baseUrl = 'http://localhost:8000';
      } else if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        _baseUrl = 'http://localhost:8000';
      } else {
        _baseUrl = 'http://10.0.2.2:8000';
      }
    }
    notifyListeners();
  }

  Future<void> setBaseUrl(String newUrl) async {
    var formatted = newUrl.trim();
    if (!formatted.startsWith('http://') && !formatted.startsWith('https://')) {
      formatted = 'http://$formatted';
    }
    if (formatted.endsWith('/')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    _baseUrl = formatted;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _baseUrl);
    notifyListeners();
  }
}
