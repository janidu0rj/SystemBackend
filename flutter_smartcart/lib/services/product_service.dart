import '../models/product_dto.dart';
import '../config/api_client_auth.dart';
import 'dart:convert';

class ProductService {
  final AuthApiClient _client = AuthApiClient();

  Future<List<ProductDTO>> fetchAllProducts() async {
    try {
      final response = await _client.get('/product/all/all');
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => ProductDTO.fromJson(item)).toList();
      } else {
        print('Fetch products error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Fetch products error: $e');
      return [];
    }
  }
}
