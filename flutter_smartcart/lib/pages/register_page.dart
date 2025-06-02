import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _nicController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _address3Controller = TextEditingController();

  bool _isLoading = false;

  // For focus animations
  final _focusNodes = List.generate(9, (_) => FocusNode());

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _address3Controller.dispose();
    super.dispose();
  }

  // Merge address fields
  String _mergeAddress() {
    final a1 = _address1Controller.text.trim();
    final a2 = _address2Controller.text.trim();
    final a3 = _address3Controller.text.trim();
    List<String> lines = [a1, a2];
    if (a3.isNotEmpty) lines.add(a3);
    return lines.join(', ');
  }

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final mergedAddress = _mergeAddress();

      // AuthService should be updated to use these new fields!
      bool success = await AuthService().register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: mergedAddress,
        nic: _nicController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        _formKey.currentState!.reset();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed. Try again.')),
        );
      }
    }
  }

  InputDecoration _animatedInputDecoration(String label, int idx, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon == null ? null : Icon(icon),
      filled: true,
      fillColor: Colors.white.withOpacity(0.95),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.blue.shade100),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.blue.shade100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(
          color: _focusNodes[idx].hasFocus ? const Color(0xFF1976d2) : Colors.blue.shade100,
          width: 2.1,
        ),
      ),
      labelStyle: TextStyle(
        color: _focusNodes[idx].hasFocus ? const Color(0xFF1565c0) : Colors.grey[700],
        fontWeight: FontWeight.w500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gradient colors
    const lamaGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF2196F3),
        Color(0xFF1565C0),
        Color(0xFF42A5F5),
      ],
    );

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: lamaGradient,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 26),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.98),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.17),
                      blurRadius: 22,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFF1565C0),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // FIRST NAME
                      TextFormField(
                        controller: _firstNameController,
                        focusNode: _focusNodes[0],
                        decoration: _animatedInputDecoration('First Name', 0, icon: Icons.person),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'First name required';
                          if (value.trim().length < 5 || value.trim().length > 50) {
                            return 'First name must be 5–50 chars';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // LAST NAME
                      TextFormField(
                        controller: _lastNameController,
                        focusNode: _focusNodes[1],
                        decoration: _animatedInputDecoration('Last Name', 1, icon: Icons.person_outline),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Last name required';
                          if (value.trim().length < 5 || value.trim().length > 50) {
                            return 'Last name must be 5–50 chars';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // EMAIL
                      TextFormField(
                        controller: _emailController,
                        focusNode: _focusNodes[2],
                        decoration: _animatedInputDecoration('Email', 2, icon: Icons.email_outlined),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Email required';
                          if (!RegExp(r"^[\w\.-]+@[\w\.-]+\.\w{2,}$").hasMatch(value.trim())) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // PHONE
                      TextFormField(
                        controller: _phoneController,
                        focusNode: _focusNodes[3],
                        decoration: _animatedInputDecoration('Phone Number', 3, icon: Icons.phone_outlined),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Phone required';
                          if (value.trim().length < 8 || value.trim().length > 20) {
                            return 'Phone must be 8–20 chars';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // ADDRESS LINES
                      TextFormField(
                        controller: _address1Controller,
                        focusNode: _focusNodes[4],
                        decoration: _animatedInputDecoration('Address Line 1', 4, icon: Icons.home_outlined),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Address required';
                          if ((_address1Controller.text.trim() + _address2Controller.text.trim() + _address3Controller.text.trim()).length < 10) {
                            return 'Address must total at least 10 chars';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _address2Controller,
                        focusNode: _focusNodes[5],
                        decoration: _animatedInputDecoration('Address Line 2', 5),
                        validator: (value) {
                          // Only require at least one line (checked above)
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _address3Controller,
                        focusNode: _focusNodes[6],
                        decoration: _animatedInputDecoration('Address Line 3 (optional)', 6),
                        validator: (value) {
                          return null; // optional
                        },
                      ),
                      const SizedBox(height: 14),

                      // NIC
                      TextFormField(
                        controller: _nicController,
                        focusNode: _focusNodes[7],
                        decoration: _animatedInputDecoration('NIC', 7, icon: Icons.credit_card_outlined),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'NIC required';
                          if (value.trim().length < 10 || value.trim().length > 12) {
                            return 'NIC must be 10–12 chars';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Register button
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFF1976D2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: _isLoading ? null : _registerUser,
                          child: _isLoading
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3.0,
                            ),
                          )
                              : const Text('Register'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
