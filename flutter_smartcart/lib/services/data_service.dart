import 'dart:convert';

import '../../config/api_client_auth.dart';
import '../../models/navigation/fixture.dart';
import '../../models/navigation/item.dart';
import '../../models/navigation/item_position.dart';
import '../models/shoppingItem_dto.dart';

class DataService {
  /// Finds the position of an item by its name in the item map.
  static ItemPosition? findItemPositionByName(
    String itemName,
    Map<String, Fixture> fixtures,
    Map<String, List<List<List<Item>>>> itemMap,
  ) {
    for (final entry in itemMap.entries) {
      final edgeKey = entry.key;
      final edgeItems = entry.value;
      final parts = edgeKey.split('-edge-');
      if (parts.length != 2) continue;
      final fixtureId = parts[0];
      final edgeIndexStr = parts[1];
      double? edgeIndexDouble = double.tryParse(edgeIndexStr);
      if (edgeIndexDouble == null) continue;
      int edgeIndex = (edgeIndexDouble * 2).toInt();
      final fixture = fixtures[fixtureId];
      if (fixture == null) continue;
      for (int rowIndex = 0; rowIndex < edgeItems.length; rowIndex++) {
        final row = edgeItems[rowIndex];
        for (int colIndex = 0; colIndex < row.length; colIndex++) {
          final column = row[colIndex];
          for (int itemIndex = 0; itemIndex < column.length; itemIndex++) {
            final item = column[itemIndex];
            if (item.name == itemName) {
              final edgePoints = fixture.getEdgePoints(edgeIndex);
              final totalColumns = row.length;
              final totalItemsInColumn = column.length;
              double finalPosition;
              if (totalColumns == 1) {
                if (totalItemsInColumn == 1) {
                  finalPosition = 0.5;
                } else {
                  finalPosition = (itemIndex + 0.5) / totalItemsInColumn;
                }
              } else {
                double columnWidth = 1.0 / totalColumns;
                double columnStart = colIndex * columnWidth;
                double columnCenter = columnStart + (columnWidth / 2);
                if (totalItemsInColumn == 1) {
                  finalPosition = columnCenter;
                } else {
                  double itemPositionInColumn =
                      (itemIndex + 0.5) / totalItemsInColumn;
                  double usableColumnWidth = columnWidth * 0.8;
                  double columnOffset = columnWidth * 0.1;
                  finalPosition =
                      columnStart +
                      columnOffset +
                      (itemPositionInColumn * usableColumnWidth);
                }
              }
              finalPosition = finalPosition.clamp(0.0, 1.0);
              final position = edgePoints.getPositionAt(finalPosition);
              return ItemPosition(
                fixtureId: fixtureId,
                edgeIndex: edgeIndex,
                position: position,
                item: item,
              );
            }
          }
        }
      }
    }
    return null;
  }

  // Set this to true to use API data instead of hardcoded data
  static const bool useApi = false;
  final AuthApiClient _client = AuthApiClient();

  /// Retrieves the saved fixture layout and item mapping from the backend for a specific store.
  /// Requires authentication.
  /// @returns A Future that resolves to a map containing the layoutId, fixtureLayout, and itemMap, with correct types.
  Future<
    ({
      String layoutId,
      Map<String, Fixture> fixtureLayout,
      Map<String, List<List<List<Item>>>> itemMap,
    })?
  >
  getLayout() async {
    try {
      print('📦 Attempting to fetch layout data from /layout/auth/all');
      final response = await _client.get('/layout/auth/all');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isEmpty) {
          print('⚠️ No layouts found in the response');
          throw Exception('No layout data available');
        }
        final firstLayout = data[0] as Map<String, dynamic>;
        final layoutId = firstLayout['layoutId'] as String;
        // Parse fixtureLayout
        final fixtureLayoutRaw =
            firstLayout['fixtureLayout'] as Map<String, dynamic>;
        final Map<String, Fixture> fixtureLayout = {};
        fixtureLayoutRaw.forEach((k, v) {
          fixtureLayout[k] = Fixture.fromJson(v as Map<String, dynamic>);
        });
        // Parse itemMap
        final itemMapRaw = firstLayout['itemMap'] as Map<String, dynamic>;
        final Map<String, List<List<List<Item>>>> itemMap = {};
        itemMapRaw.forEach((k, v) {
          final List<List<List<Item>>> edge = [];
          for (final row in (v as List)) {
            final List<List<Item>> rowList = [];
            for (final col in (row as List)) {
              final List<Item> colList = [];
              for (final item in (col as List)) {
                colList.add(Item.fromJson(item as Map<String, dynamic>));
              }
              rowList.add(colList);
            }
            edge.add(rowList);
          }
          itemMap[k] = edge;
        });
        print('✅ Layout data fetched successfully');
        print('🆔 First Layout ID: $layoutId');
        print('🧱 Fixture Layout: $fixtureLayout');
        print('📦 Item Map: $itemMap');
        return (
          layoutId: layoutId,
          fixtureLayout: fixtureLayout,
          itemMap: itemMap,
        );
      } else {
        throw Exception(
          'Failed to fetch layout: \\${response.statusCode} - \\${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error fetching layout data: $e');
      rethrow;
    }
  }

  Future<Map<String, Fixture>> loadFixtures() async {
    if (useApi) {
      try {
        final response = await _client.get('/fixtures/all');
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return data.map(
            (key, value) => MapEntry(key, Fixture.fromJson(value)),
          );
        } else {
          print(
            'Failed to fetch fixtures: ${response.statusCode} - ${response.body}',
          );
          return _loadHardcodedFixtures();
        }
      } catch (e) {
        print('Fixture load error: $e');
        return _loadHardcodedFixtures();
      }
    }
    return _loadHardcodedFixtures();
  }

  static Map<String, Fixture> _loadHardcodedFixtures() {
    const String fixtureJsonData = '''
    {"7b4ead7a-9567-4689-a6dd-13d8c6f67830":{"id":"7b4ead7a-9567-4689-a6dd-13d8c6f67830","x":19.475,"y":8.025,"points":[-0.5,-4.025,-0.5,3.9749999999999996,0.5,3.9749999999999996,0.5,-4.025],"color":"#37ff00","name":"New Fixture"},"7b8a2c5b-0173-4de9-ad0d-ba25010af67a":{"id":"7b8a2c5b-0173-4de9-ad0d-ba25010af67a","x":10.025,"y":8,"points":[-0.5,-3.925,-0.5,4.075,0.5,4.075,0.5,-3.925],"color":"#f5a051","name":"New Fixture"},"dffcc314-34bb-4c43-a08a-ed1627f00450":{"id":"dffcc314-34bb-4c43-a08a-ed1627f00450","x":14.85,"y":5,"points":[-1.4999999999999982,-1,-1.4999999999999982,1,1.5,1,1.5,-1],"color":"#66c4ff","name":"New Fixture"},"6b848cf2-567e-4afb-852a-71e18b66bbc6":{"id":"6b848cf2-567e-4afb-852a-71e18b66bbc6","x":17.35,"y":12.7,"points":[-0.5,-0.5,-0.5,0.5,0.5,0.5,0.5,-0.5],"color":"#ffdf0f","name":"start"}}
    ''';

    final Map<String, dynamic> fixtureData = json.decode(fixtureJsonData);
    return fixtureData.map(
      (key, value) => MapEntry(key, Fixture.fromJson(value)),
    );
  }

  // static Future<Map<String, List<List<List<Item>>>>> loadItemMap() async {
  //   if (useApi) {
  //     // return ApiService.fetchItemMap();
  //     return _loadHardcodedItemMap(); // Fallback to hardcoded data for now
  //   }
  //   return _loadHardcodedItemMap();
  // }

  Future<Map<String, List<List<List<Item>>>>> loadItemMap() async {
    if (useApi) {
      try {
        final response = await _client.get('/item-map');
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final Map<String, List<List<List<Item>>>> loadedItemMap = {};

          data.forEach((edgeKey, edgeData) {
            List<List<List<Item>>> rows = [];
            for (var rowData in edgeData) {
              List<List<Item>> columns = [];
              for (var colData in rowData) {
                List<Item> items = [];
                for (var itemJson in colData) {
                  items.add(Item.fromJson(itemJson));
                }
                columns.add(items);
              }
              rows.add(columns);
            }
            loadedItemMap[edgeKey] = rows;
          });

          return loadedItemMap;
        } else {
          print(
            'Failed to fetch item map: ${response.statusCode} - ${response.body}',
          );
          return _loadHardcodedItemMap();
        }
      } catch (e) {
        print('Item map load error: $e');
        return _loadHardcodedItemMap();
      }
    }

    return _loadHardcodedItemMap();
  }

  static Map<String, List<List<List<Item>>>> _loadHardcodedItemMap() {
    const String itemMapJsonData = '''
    {"dffcc314-34bb-4c43-a08a-ed1627f00450-edge-0.5":[[[{"id":"c344724b-ee6c-4ffb-859a-7b35398ea516","name":"Nescafe Ice Cold Coffee 180ml","row":0,"col":0,"index":0},{"id":"fffccbbc-56d3-4af8-83ff-d1bd98c7c7b0","name":"Nescafe Ice Cold Coffee 180ml","row":0,"col":0,"index":1},{"id":"d6b7c137-5f82-45e7-810d-63267d61d85f","name":"Nescafe Ice Cold Coffee 180ml","row":0,"col":0,"index":2}],[{"id":"0540b624-b83a-4b1a-94fd-efe5ed9030f1","name":"Kist Jam Mixed Fruit 510g","row":0,"col":1,"index":0}]],[[{"id":"113c2d45-06db-4bdb-8bf0-cec329ba2963","name":"Krest Chicken Sausages Bockwurst 400g","row":1,"col":0,"index":0}],[{"id":"36e52e6e-a1eb-4285-b85d-f06e44e8a609","name":"Milo Food Drink Chocolate Tetra 180ml","row":1,"col":1,"index":0}],[{"id":"7b2ee6b4-c695-41e6-881d-77ac34683424","name":"Krest Chicken Sausages Bockwurst 400g","row":1,"col":2,"index":0}],[{"id":"84a835aa-dcd0-44f6-a6cd-73266f333ac4","name":"Krest Chicken Sausages Bockwurst 400g","row":1,"col":3,"index":0}]]],"7b8a2c5b-0173-4de9-ad0d-ba25010af67a-edge-0":[[[{"id":"6fa1ad6a-df8a-4f97-81ee-fe3b82d63944","name":"Kist Jam Mixed Fruit 510g","row":0,"col":0,"index":0}]],[[{"id":"b7c379d2-8bcf-4a1e-9d7e-c26adfee6690","name":"Krest Chicken Sausages Bockwurst 400g","row":1,"col":0,"index":0}]],[[],[],[],[{"id":"7f5e9735-8015-4d4f-9793-4ab67f52b6ad","name":"Kist Jam Mixed Fruit 510g","row":2,"col":3,"index":0}],[]]]}
    ''';

    final Map<String, dynamic> itemData = json.decode(itemMapJsonData);
    final Map<String, List<List<List<Item>>>> loadedItemMap = {};

    itemData.forEach((edgeKey, edgeData) {
      List<List<List<Item>>> rows = [];
      for (var rowData in edgeData) {
        List<List<Item>> columns = [];
        for (var colData in rowData) {
          List<Item> items = [];
          for (var itemData in colData) {
            items.add(Item.fromJson(itemData));
          }
          columns.add(items);
        }
        rows.add(columns);
      }
      loadedItemMap[edgeKey] = rows;
    });

    return loadedItemMap;
  }

  Future<List<String>> loadShoppingList() async {
    if (useApi) {
      try {
        final response = await _client.get('/shopping-list/items');
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          return data
              .map((itemJson) => ShoppingItem.fromJson(itemJson).itemName)
              .toList();
        } else {
          print('Failed to fetch shopping list: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching shopping list: $e');
      }
    }

    // fallback to hardcoded list of item IDs
    return _loadHardcodedShoppingList();
  }

  static List<String> _loadHardcodedShoppingList() {
    // Return a list of item names, matching the backend's new behavior
    return [
      "Nescafe Ice Cold Coffee 180ml",
      "Kist Jam Mixed Fruit 510g",
      "Krest Chicken Sausages Bockwurst 400g",
      "Milo Food Drink Chocolate Tetra 180ml",
      // Add more names as needed for your test data
    ];
  }

  static ItemPosition? findItemPosition(
    String itemId,
    Map<String, Fixture> fixtures,
    Map<String, List<List<List<Item>>>> itemMap,
  ) {
    // Search through all edge keys in itemMap
    for (final entry in itemMap.entries) {
      final edgeKey = entry.key;
      final edgeItems = entry.value;

      // Extract fixture ID and edge index from the key
      // Expected format: "fixtureId-edge-edgeIndex"
      final parts = edgeKey.split('-edge-');
      if (parts.length != 2) continue;

      final fixtureId = parts[0];
      final edgeIndexStr = parts[1];

      // Parse edge index (might be decimal like "1.5")
      double? edgeIndexDouble = double.tryParse(edgeIndexStr);
      if (edgeIndexDouble == null) continue;

      // Convert from React's half-integer system to actual edge index
      // React uses 0, 0.5, 1, 1.5... but we need 0, 1, 2, 3...
      int edgeIndex = (edgeIndexDouble * 2).toInt();

      final fixture = fixtures[fixtureId];
      if (fixture == null) continue;

      // Search through rows and columns
      for (int rowIndex = 0; rowIndex < edgeItems.length; rowIndex++) {
        final row = edgeItems[rowIndex];
        for (int colIndex = 0; colIndex < row.length; colIndex++) {
          final column = row[colIndex];
          for (int itemIndex = 0; itemIndex < column.length; itemIndex++) {
            final item = column[itemIndex];
            if (item.id == itemId) {
              // Calculate position on the edge
              final edgePoints = fixture.getEdgePoints(edgeIndex);

              final totalColumns = row.length;
              final totalItemsInColumn = column.length;

              // Calculate the position along the edge
              double finalPosition;

              if (totalColumns == 1) {
                // Single column case - center the item in the edge
                if (totalItemsInColumn == 1) {
                  finalPosition = 0.5; // Center of the edge
                } else {
                  // Multiple items in single column - distribute evenly
                  finalPosition = (itemIndex + 0.5) / totalItemsInColumn;
                }
              } else {
                // Multiple columns case
                // Each column occupies an equal portion of the edge
                double columnWidth = 1.0 / totalColumns;
                double columnStart = colIndex * columnWidth;
                double columnCenter = columnStart + (columnWidth / 2);

                if (totalItemsInColumn == 1) {
                  // Single item in column - place at column center
                  finalPosition = columnCenter;
                } else {
                  // Multiple items in column - distribute within the column
                  // Calculate item position within the column (0 to 1)
                  double itemPositionInColumn =
                      (itemIndex + 0.5) / totalItemsInColumn;

                  // Scale to column width and offset by column start
                  // Use 80% of column width to avoid overlap with adjacent columns
                  double usableColumnWidth = columnWidth * 0.8;
                  double columnOffset =
                      columnWidth * 0.1; // 10% padding on each side

                  finalPosition =
                      columnStart +
                      columnOffset +
                      (itemPositionInColumn * usableColumnWidth);
                }
              }

              // Ensure position stays within bounds
              finalPosition = finalPosition.clamp(0.0, 1.0);

              // Get the actual world coordinates
              final position = edgePoints.getPositionAt(finalPosition);

              return ItemPosition(
                fixtureId: fixtureId,
                edgeIndex: edgeIndex,
                position: position,
                item: item,
              );
            }
          }
        }
      }
    }
    return null;
  }
}
