import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart'; // Import UserService

class HomePage extends StatefulWidget {
  final String? username; // Made nullable

  const HomePage({super.key, this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoggingOut = false;
  int _currentImageIndex = 0;
  late Timer _timer;
  late String username;

  final List<String> _bgImages = [
    'assets/images/home1.jpg',
    'assets/images/home2.jpg',
    'assets/images/home3.jpg',
    'assets/images/home4.jpg',
    'assets/images/home5.jpg',
    'assets/images/home6.jpg',
    'assets/images/home7.jpg',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize username either from widget or UserService
    username =
        widget.username?.isNotEmpty == true
            ? widget.username!
            : UserService().getUsername() ?? '';

    // Redirect to login if username empty
    if (username.isEmpty) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % _bgImages.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _handleLogout(BuildContext context) async {
    setState(() => _isLoggingOut = true);
    final success = await AuthService().logout();
    setState(() => _isLoggingOut = false);

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
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Welcome, $username',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            tooltip: 'My Profile',
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/profile',
                arguments: {'username': username},
              );
            },
          ),
        ],
      ),

      body: Stack(
        children: [
          // Background Image (rotating)
          AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            child: Image.asset(
              _bgImages[_currentImageIndex],
              key: ValueKey(_bgImages[_currentImageIndex]),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Overlay for contrast
          Container(color: Colors.black.withOpacity(0.4)),

          // Foreground content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildHomeCard(
                  icon: Icons.qr_code_scanner,
                  label: 'Scan Product',
                  onTap: () => Navigator.pushNamed(context, '/scan-product'),
                ),
                _buildHomeCard(
                  icon: Icons.shopping_bag,
                  label: 'View Products',
                  onTap: () => Navigator.pushNamed(context, '/product-list'),
                ),
                _buildHomeCard(
                  icon: Icons.list,
                  label: 'Your Shopping List',
                  onTap: () => Navigator.pushNamed(context, '/shopping-list'),
                ),
                _buildHomeCard(
                  icon: Icons.shopping_cart,
                  label: 'My Cart',
                  onTap: () => Navigator.pushNamed(context, '/cart'),
                ),
                _buildHomeCard(
                  icon: Icons.person,
                  label: 'My Profile',
                  onTap:
                      () => Navigator.pushNamed(
                        context,
                        '/profile',
                        arguments: {'username': username},
                      ),
                ),
                _buildHomeCard(
                  icon: Icons.map,
                  label: 'Store Navigation',
                  onTap: () {
                    Navigator.pushNamed(context, '/store-nav');
                  },
                ),
                _isLoggingOut
                    ? const Center(child: CircularProgressIndicator())
                    : _buildHomeCard(
                      icon: Icons.logout,
                      label: 'Logout',
                      onTap: () => _handleLogout(context),
                    ),
              ],
            ),
          ),
        ],
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
        color: Colors.white.withOpacity(0.35), // reduce opacity of background
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: const Color(0xFF1976D2)),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
