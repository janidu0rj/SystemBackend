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

  Widget _buildProfileTile({
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = const Color(0xFF1976D2),
  }) {
    return Card(
      elevation: 0.8,
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.5), // 0.5 opacity container background
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.12),
          child: Icon(icon, color: iconColor),
        ),
        title:
            const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    )
                    is TextStyle
                ? Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                )
                : Text(label),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name =
        "${_profile?['firstName'] ?? ''} ${_profile?['lastName'] ?? ''}".trim();
    final email = _profile?['email'] ?? '';
    final nic = _profile?['nic'] ?? '';
    final phone = _profile?['phoneNumber'] ?? '';
    final address = _profile?['address'] ?? '';

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/images/myprofile.jpg', fit: BoxFit.cover),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: const Color(0xFF1976D2).withOpacity(0.85),
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "My Profile",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              tooltip: 'Back',
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
                tooltip: 'Go to Home',
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
              ),
            ],
          ),
          body:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _profile == null
                  ? const Center(child: Text("Failed to load profile"))
                  : Column(
                    children: [
                      // Gradient header with avatar and name
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 30, bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: Colors.white.withOpacity(0.5),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: const Color(0xFF1976D2),
                                child: const Icon(
                                  Icons.person,
                                  size: 42,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
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
                            _buildProfileTile(
                              icon: Icons.badge_outlined,
                              label: "NIC",
                              value: nic,
                              iconColor: const Color(0xFF1976D2),
                            ),
                            _buildProfileTile(
                              icon: Icons.phone,
                              label: "Phone",
                              value: phone,
                              iconColor: const Color(0xFF1976D2),
                            ),
                            _buildProfileTile(
                              icon: Icons.home_outlined,
                              label: "Address",
                              value: address,
                              iconColor: const Color(0xFF1976D2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
        ),
      ],
    );
  }
}
