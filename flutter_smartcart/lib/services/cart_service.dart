import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/cart_dto.dart';

class CartService {
  Future<List<CartDTO>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token') ?? '';

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/cart/all'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => CartDTO.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch cart: ${response.body}');
    }
  }
}
