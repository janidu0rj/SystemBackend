import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout(BuildContext context) async {
    setState(() => _isLoggingOut = true);
    final success = await AuthService().logout();
    setState(() => _isLoggingOut = false);

    // Optionally show a snackbar
    if (success) {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logout failed. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome, ${widget.username}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildHomeCard(
              icon: Icons.qr_code_scanner,
              label: 'Scan Product',
              onTap: () {
                Navigator.pushNamed(context, '/scan-product');
              },
            ),
            _buildHomeCard(
              icon: Icons.shopping_bag,
              label: 'View Products',
              onTap: () {
                Navigator.pushNamed(context, '/product-list');
              },
            ),
            _buildHomeCard(
              icon: Icons.list,
              label: 'Your Shopping List',
              onTap: () {
                Navigator.pushNamed(context, '/shopping-list');
              },
            ),
            _buildHomeCard(
              icon: Icons.shopping_cart,
              label: 'My Cart',
              onTap: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
            _buildHomeCard(
              icon: Icons.person,
              label: 'My Profile',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/profile',
                  arguments: {'username': widget.username},
                );
              },
            ),
            _isLoggingOut
                ? Center(child: CircularProgressIndicator())
                : _buildHomeCard(
              icon: Icons.logout,
              label: 'Logout',
              onTap: () => _handleLogout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.teal),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
