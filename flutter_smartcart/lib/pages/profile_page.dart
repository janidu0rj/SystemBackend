import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  void _fetchProfileData() async {
    final profile = await ProfileService().getProfile();
    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  Widget _buildProfileTile({required IconData icon, required String label, required String value}) {
    return Card(
      elevation: 0.8,
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.withOpacity(0.12),
          child: Icon(icon, color: Colors.teal.shade800),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text(value, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = "${_profile?['firstName'] ?? ''} ${_profile?['lastName'] ?? ''}";
    final email = _profile?['email'] ?? '';
    final nic = _profile?['nic'] ?? '';
    final phone = _profile?['phoneNumber'] ?? '';
    final address = _profile?['address'] ?? '';

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("My Profile"),
        elevation: 0,
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
          ? const Center(child: Text("Failed to load profile"))
          : Column(
        children: [
          // Gradient header with avatar and name
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 30, bottom: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2196F3),
                  Color(0xFF42A5F5),
                  Color(0xFF1565C0),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.teal.shade300,
                    child: const Icon(Icons.person, size: 42, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.teal[50],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
              children: [
                _buildProfileTile(icon: Icons.badge_outlined, label: "NIC", value: nic),
                _buildProfileTile(icon: Icons.phone, label: "Phone", value: phone),
                _buildProfileTile(icon: Icons.home_outlined, label: "Address", value: address),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
