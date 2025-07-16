import 'package:flutter/material.dart';
import '../models/navigation/fixture.dart';
import '../models/navigation/item.dart';
import '../models/navigation/item_position.dart';
import '../services/data_service.dart';

/// Utility to get ItemPosition for each item in the shopping list (except selected)
class ShoppingListMapOverlay {
  /// Returns a list of ItemPosition for all shopping list items except the selected one
  static List<ItemPosition> getShoppingListPositions({
    required List<String> shoppingList,
    required String? selectedItemName,
    required Map<String, Fixture> fixtures,
    required Map<String, List<List<List<Item>>>> itemMap,
  }) {
    final List<ItemPosition> positions = [];
    for (final itemName in shoppingList) {
      if (itemName == selectedItemName) continue;
      final pos = DataService.findItemPositionByName(itemName, fixtures, itemMap);
      if (pos != null) positions.add(pos);
    }
    return positions;
  }
}
