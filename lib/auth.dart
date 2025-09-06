import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screen.dart' show HomePage;
import 'auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    setState(() => _errorMessage = null);
    if (isLogin) {
      final uid = await AuthService.signIn(
        _emailController.text,
        _passwordController.text,
      );
      if (uid != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        setState(
          () => _errorMessage =
              "Invalid email or password. Please try again or sign up.",
        );
      }
    } else {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() => _errorMessage = "Passwords do not match");
        return;
      }
      final uid = await AuthService.signUp(
        _emailController.text,
        _passwordController.text,
      );
      if (uid != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        setState(
          () => _errorMessage =
              "Sign-up failed. Check your email/password or network.",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Icon(
                  Icons.shield,
                  color: const Color(0xFF5EEAD4),
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  isLogin ? 'Welcome Back!' : 'Create Account',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  isLogin
                      ? 'Login to continue to Big Phisher'
                      : 'Signup to get started with Big Phisher',
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Email
              _buildInputField(
                controller: _emailController,
                icon: Icons.email_outlined,
                hint: 'Email',
                obscure: false,
              ),
              const SizedBox(height: 20),

              // Password
              _buildInputField(
                controller: _passwordController,
                icon: Icons.lock_outline,
                hint: 'Password',
                obscure: true,
              ),
              const SizedBox(height: 20),

              // Confirm Password (Signup only)
              if (!isLogin)
                Column(
                  children: [
                    _buildInputField(
                      controller: _confirmPasswordController,
                      icon: Icons.lock_outline,
                      hint: 'Confirm Password',
                      obscure: true,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

              // Error Message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.inter(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5EEAD4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _handleAuth,
                child: Text(
                  isLogin ? 'Login' : 'Signup',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Switch Login/Signup
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLogin
                        ? "Don't have an account?"
                        : 'Already have an account?',
                    style: GoogleFonts.inter(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                        _errorMessage = null; // Clear error on switch
                      });
                    },
                    child: Text(
                      isLogin ? 'Signup' : 'Login',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF5EEAD4),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required bool obscure,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade400),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
