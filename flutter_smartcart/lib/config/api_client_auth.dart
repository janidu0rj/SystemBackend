// lib/services/api_client_auth.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthApiClient {
  // Retrieve the JWT token from secure storage (implement this yourself)
  Future<String?> getToken() async {
    // Use flutter_secure_storage or shared_preferences
    // Example:
    // return await storage.read(key: 'jwt_token');
    return null; // Replace this
  }

  Future<http.Response> get(String endpoint) async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return await http.get(url, headers: headers);
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return await http.post(url, headers: headers, body: jsonEncode(body));
  }

// Add PUT, DELETE etc. as needed
}
