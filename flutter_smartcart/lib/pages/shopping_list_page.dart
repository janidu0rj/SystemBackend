import 'package:flutter/material.dart';
import '../services/shoppingList_service.dart';
import '../models/shoppingItem_dto.dart';
import '../widgets/shoppingItem_card.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final _service = ShoppingListService();
  List<ShoppingItem> _items = [];
  bool _isLoading = true;

  Future<void> _loadItems() async {
    try {
      final fetched = await _service.getItems();
      setState(() {
        _items = fetched;
        _isLoading = false;
      });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load items")),
      );
    }
  }

  Future<void> _deleteItem(String name) async {
    await _service.deleteItem(name);
    await _loadItems();
  }

  Future<void> _deleteAll() async {
    await _service.deleteAll();
    await _loadItems();
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛍️ Your Shopping List'),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Delete All',
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Confirm Delete All'),
                    content: const Text('Are you sure you want to delete all items?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await _deleteAll();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const Center(child: Text("🛒 Your shopping list is empty"))
          : ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return ShoppingItemCard(
            item: _items[index],
            onDelete: () => _deleteItem(_items[index].itemName),
          );
        },
      ),
    );
  }
}
