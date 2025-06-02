import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthApiClient {
  /// Get the JWT access token from shared preferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<http.Response> get(String endpoint) async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return await http.get(url, headers: headers);
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return await http.post(url, headers: headers, body: jsonEncode(body));
  }

// Add PUT, DELETE, etc., as needed
}
