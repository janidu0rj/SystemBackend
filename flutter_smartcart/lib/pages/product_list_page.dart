import 'package:flutter/material.dart';
import '../models/product_dto.dart';
import '../services/product_service.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<ProductDTO> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final products = await ProductService().fetchAllProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Products')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
          ? Center(
        child: Text(
          'No products found.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
        ),
      )
          : ListView.separated(
        itemCount: _products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: product.imageUrl.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.shopping_bag, size: 36),
                ),
              )
                  : const Icon(Icons.shopping_bag, size: 36),
              title: Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Brand: ${product.brand} | Category: ${product.category}',
                      style: TextStyle(color: Colors.teal.shade700, fontSize: 13),
                    ),
                    Text(
                      'Weight: ${product.weight.toStringAsFixed(2)} kg',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      'Stock: ${product.quantity}',
                      style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
              trailing: Text(
                'Rs. ${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.teal,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/product-detail',
                  arguments: product,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
