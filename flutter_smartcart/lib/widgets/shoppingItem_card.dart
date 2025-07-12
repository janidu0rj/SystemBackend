import 'package:flutter/material.dart';
import '../models/shoppingItem_dto.dart';

class ShoppingItemCard extends StatelessWidget {
  final ShoppingItem item;
  final VoidCallback onDelete;

  const ShoppingItemCard({super.key, required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ListTile(
        leading: const Icon(Icons.local_grocery_store, color: Colors.teal),
        title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          'Qty: ${item.quantity} • Weight: ${item.weight}\nShelf: ${item.productShelfNumber}, Row: ${item.productRowNumber}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
