import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const Duration timeoutDuration = Duration(seconds: 30);

  // GET request
  static Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    final uri = Uri.parse(url);
    if (uri.scheme != 'https' && !url.contains('127.0.0.1') && !url.contains('localhost') && !url.contains('10.0.2.2')) {
      throw SecurityException("Seules les connexions HTTPS sont autorisées en production.");
    }

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
      ).timeout(timeoutDuration);
      
      return response;
    } catch (e) {
      throw NetworkException("Erreur de connexion au serveur. Vérifiez votre réseau.");
    }
  }

  // POST request
  static Future<http.Response> post(String url, Map<String, dynamic> body, {Map<String, String>? headers}) async {
    final uri = Uri.parse(url);
    if (uri.scheme != 'https' && !url.contains('127.0.0.1') && !url.contains('localhost') && !url.contains('10.0.2.2')) {
      throw SecurityException("Seules les connexions HTTPS sont autorisées en production.");
    }

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: json.encode(body),
      ).timeout(timeoutDuration);

      return response;
    } catch (e) {
      throw NetworkException("Erreur de connexion au serveur. Vérifiez votre réseau.");
    }
  }
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}
