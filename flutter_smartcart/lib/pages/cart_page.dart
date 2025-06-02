import 'package:flutter/material.dart';
import '../models/cart_dto.dart';
import '../services/cart_service.dart'; // We'll write this below

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<CartDTO>> _futureCartItems;

  @override
  void initState() {
    super.initState();
    _futureCartItems = CartService().getCartItems();
  }

  double getTotal(List<CartDTO> items) =>
      items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.teal,
        elevation: 2,
      ),
      body: FutureBuilder<List<CartDTO>>(
        future: _futureCartItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Failed to load cart. Try again later.",
                style: TextStyle(color: Colors.red.shade700),
              ),
            );
          }
          final cartItems = snapshot.data ?? [];

          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.remove_shopping_cart, size: 60, color: Colors.teal.shade200),
                  const SizedBox(height: 16),
                  const Text(
                    "Your cart is empty.",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final item = cartItems[idx];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade100,
                          child: Icon(Icons.shopping_bag, color: Colors.teal.shade700),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Quantity: ${item.quantity}"),
                            if (item.weight != null)
                              Text("Weight: ${item.weight} kg"),
                            Text(
                              "Price: Rs. ${item.price.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        trailing: Text(
                          "Rs. ${(item.quantity * item.price).toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.shade100.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, -2),
                    )
                  ],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Rs. ${getTotal(cartItems).toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement checkout flow
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Checkout coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.payment),
                      label: const Text('Checkout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
