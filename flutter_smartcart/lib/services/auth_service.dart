import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  /// Logs in a user and saves user tokens if successful.
  Future<Map<String, dynamic>?> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/customer/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save tokens and role if present
        await saveAuthData(
          data['access_token'] ?? '',
          data['refresh_token'] ?? '',
          data['role'] ?? '',
        );

        print('Login success: $data');
        return data;
      } else {
        print('Login failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<void> saveAuthData(String accessToken, String refreshToken, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    await prefs.setString('role', role);
  }

  /// Logout user, call backend, clear local storage
  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token') ?? '';

    try {
      // Call the backend logout endpoint (if token exists)
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/customer/profile/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      // Clean up local storage always
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('role');

      return response.statusCode == 200;
    } catch (e) {
      print('Logout error: $e');
      // Still clear storage on error
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('role');
      return false;
    }
  }

  /// Registers a new user (customer)
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String address,
    required String nic,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/customer/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phoneNumber': phoneNumber,
          'address': address,
          'nic': nic,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Register success: ${response.body}');
        return true;
      } else {
        print('Register failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }
}
