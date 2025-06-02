import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _titleFade;

  final _userFocus = FocusNode();
  final _passFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _titleFade = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  void _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final userData = await AuthService().login(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);

      // The tokens and role are already saved in SharedPreferences in AuthService
      if (userData != null && userData['access_token'] != null) {
        // (Optional) You can fetch tokens/role from SharedPreferences like this:
        final prefs = await SharedPreferences.getInstance();
        final username = _usernameController.text.trim();
        final accessToken = prefs.getString('access_token') ?? '';
        final refreshToken = prefs.getString('refresh_token') ?? '';
        final role = prefs.getString('role') ?? '';

        // Example: Navigate and pass username, or role if needed
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: {
            'username': username,
            'role': role,
            'accessToken': accessToken,
            // You can pass refreshToken if your /home page needs it
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed. Check credentials.")),
        );
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _animatedInputDecoration(String label, FocusNode focusNode) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: focusNode.hasFocus ? const Color(0xFF1565c0) : Colors.grey[700],
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.93),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.blue.shade100,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.blue.shade100,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(
          color: focusNode.hasFocus ? const Color(0xFF1976d2) : Colors.blue.shade100,
          width: 2.2,
        ),
      ),
      prefixIcon: label == 'Username'
          ? const Icon(Icons.person_outline)
          : const Icon(Icons.lock_outline),
    );
  }

  @override
  Widget build(BuildContext context) {
    // LAMA blue palette gradient
    const lamaGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF2196F3), // Lama blue mid
        Color(0xFF1565C0), // Lama blue dark
        Color(0xFF42A5F5), // Lama blue light
      ],
    );

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard
        child: Container(
          decoration: const BoxDecoration(
            gradient: lamaGradient,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: 1,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 22),
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.96),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.withOpacity(0.17),
                        blurRadius: 20,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FadeTransition(
                          opacity: _titleFade,
                          child: Text(
                            'Smart Cart Login',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: const Color(0xFF1565C0),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: TextFormField(
                            controller: _usernameController,
                            focusNode: _userFocus,
                            onTap: () => setState(() {}),
                            decoration: _animatedInputDecoration('Username', _userFocus),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter username'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 18),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: TextFormField(
                            controller: _passwordController,
                            focusNode: _passFocus,
                            onTap: () => setState(() {}),
                            obscureText: true,
                            decoration: _animatedInputDecoration('Password', _passFocus),
                            validator: (value) => value == null || value.length < 6
                                ? 'Password too short'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 30),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color(0xFF1976D2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            onPressed: _isLoading ? null : _loginUser,
                            child: _isLoading
                                ? const SizedBox(
                              height: 28,
                              width: 28,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 3.0,
                              ),
                            )
                                : const Text('Login'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text(
                            "Don't have an account? Register",
                            style: TextStyle(
                              color: Color(0xFF1976D2),
                              fontWeight: FontWeight.w600,
                            ),
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
      ),
    );
  }
}
