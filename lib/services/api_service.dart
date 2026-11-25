import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  final ApiConfig apiConfig;
  String? _authToken;

  ApiService(this.apiConfig);

  void updateToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _buildHeaders({bool isJson = true}) {
    final headers = <String, String>{};
    if (isJson) {
      headers['Content-Type'] = 'application/json';
      headers['Accept'] = 'application/json';
    }
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  dynamic _processResponse(http.Response response) {
    final status = response.statusCode;
    final body = response.body;

    dynamic jsonBody;
    try {
      jsonBody = json.decode(utf8.decode(response.bodyBytes));
    } catch (_) {
      jsonBody = null;
    }

    if (status >= 200 && status < 300) {
      return jsonBody;
    } else {
      String errorMessage = 'Errore di comunicazione ($status)';
      if (jsonBody is Map && jsonBody.containsKey('detail')) {
        errorMessage = jsonBody['detail'].toString();
      } else if (body.isNotEmpty) {
        errorMessage = body;
      }
      throw ApiException(errorMessage, statusCode: status);
    }
  }

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('${apiConfig.baseUrl}$endpoint');
    try {
      final response = await http
          .get(url, headers: _buildHeaders())
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Impossibile contattare il server: $e');
    }
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    final url = Uri.parse('${apiConfig.baseUrl}$endpoint');
    try {
      final response = await http
          .post(
            url,
            headers: _buildHeaders(),
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Impossibile contattare il server: $e');
    }
  }

  Future<dynamic> postMultipart({
    required String endpoint,
    required Map<String, String> fields,
    required String fileFieldName,
    required String filePath,
    required String originalFilename,
  }) async {
    final url = Uri.parse('${apiConfig.baseUrl}$endpoint');
    try {
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(_buildHeaders(isJson: false));
      request.fields.addAll(fields);

      final multipartFile = await http.MultipartFile.fromPath(
        fileFieldName,
        filePath,
        filename: originalFilename,
      );
      request.files.add(multipartFile);

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Errore durante l\'invio del file: $e');
    }
  }

  Future<List<int>> downloadBytes(String fileUrlOrEndpoint) async {
    final String fullUrl = fileUrlOrEndpoint.startsWith('http')
        ? fileUrlOrEndpoint
        : '${apiConfig.baseUrl}$fileUrlOrEndpoint';

    final url = Uri.parse(fullUrl);
    try {
      final response = await http
          .get(url, headers: _buildHeaders(isJson: false))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      } else {
        throw ApiException(
            'Errore scaricamento file: status ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Errore connessione per download file: $e');
    }
  }
}
