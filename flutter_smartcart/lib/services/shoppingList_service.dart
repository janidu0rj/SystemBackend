import 'package:http/http.dart';

import '../config/api_client_auth.dart';
import '../models/shoppingItem_dto.dart';
import 'dart:convert';

class ShoppingListService {
  final _client = AuthApiClient();

  Future<List<ShoppingItem>> getItems() async {
    final res = await _client.get('/shopping-list/items');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((item) => ShoppingItem.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load shopping items");
    }
  }

  Future<void> deleteItem(String itemName) async {
    final res = await _client.delete('/shopping-list/delete/$itemName');
    if (res.statusCode != 200) throw Exception("Failed to delete item");
  }

  Future<void> deleteAll() async {
    final res = await _client.delete('/shopping-list/delete-all');
    if (res.statusCode != 200) throw Exception("Failed to delete all items");
  }
}
