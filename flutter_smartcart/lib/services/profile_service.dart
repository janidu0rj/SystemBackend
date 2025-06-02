import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ProfileService {

  Future<Map<String, dynamic>?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/customer/profile/get'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Failed to fetch profile: ${response.statusCode} - ${response
            .body}');
        return null;
      }
    } catch (e) {
      print('Profile fetch error: $e');
      return null;
    }
  }

}
