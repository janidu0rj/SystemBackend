// lib/services/api_client_noauth.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class NoAuthApiClient {
  Future<http.Response> get(String endpoint) async {
    final headers = {'Content-Type': 'application/json'};
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return await http.get(url, headers: headers);
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = {'Content-Type': 'application/json'};
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return await http.post(url, headers: headers, body: jsonEncode(body));
  }

// Add PUT, DELETE etc. as needed
}
