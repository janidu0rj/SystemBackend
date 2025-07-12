import 'package:flutter/material.dart';
import '../models/product_dto.dart';
import '../services/product_service.dart'; // Import the service

class ProductDetailPage extends StatefulWidget {
  final ProductDTO product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int selectedQuantity = 1;
  final ProductService _productService = ProductService();

  Future<void> _handleAddToShoppingList() async {
    final product = widget.product;

    if (selectedQuantity > product.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Quantity exceeds available stock (${product.quantity})')),
      );
      return;
    }

    final totalWeight = selectedQuantity * product.weight;

    final success = await _productService.addToShoppingList(
      name: product.name,
      quantity: selectedQuantity,
      weight: totalWeight,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? '✅ Added to shopping list' : '❌ Failed to add item',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.imageUrl.isNotEmpty
                      ? product.imageUrl
                      : 'https://via.placeholder.com/150',
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Product Name
            Text(
              product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Price
            Text(
              'Price: Rs. ${product.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 8),

            // Weight
            Text(
              'Weight: ${product.weight} kg (per unit)',
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 8),

            // Quantity Available
            Text(
              'Available Units: ${product.quantity}',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),

            const SizedBox(height: 16),

            // Select Quantity Dropdown
            Row(
              children: [
                const Text("Select Quantity:", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: selectedQuantity,
                  items: List.generate(product.quantity, (i) => i + 1)
                      .map((qty) => DropdownMenuItem(
                    value: qty,
                    child: Text(qty.toString()),
                  ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedQuantity = val;
                      });
                    }
                  },
                ),
              ],
            ),

            const Spacer(),

            // Add to Shopping List button
            Center(
              child: ElevatedButton.icon(
                onPressed: _handleAddToShoppingList,
                icon: const Icon(Icons.playlist_add),
                label: const Text('Add to Shopping List'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
