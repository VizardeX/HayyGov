import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onLoginTap;
  const SignupScreen({super.key, required this.onLoginTap});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = 'citizen'; // Default role
  bool obscurePassword = true;

  Future<void> _signUp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.signUpWithRole(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      role: selectedRole,
    );
    if (!mounted) return;
    if (result != "success") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    } else {
      widget.onLoginTap(); // switch page instead of pop
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // <-- Add this line!
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'HayyGov',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),

              // Email labels
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Email', style: TextStyle(color: Colors.black)),
                  Text('البريد الإلكتروني', style: TextStyle(color: Colors.black)),
                ],
              ),
              const SizedBox(height: 8),

              // Email field
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: '@',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14), // <-- Add vertical padding
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Password labels
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Password', style: TextStyle(color: Colors.black)),
                  Text('كلمة السر', style: TextStyle(color: Colors.black)),
                ],
              ),
              const SizedBox(height: 8),

              // Password field
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    hintText: '🔑',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // <-- Match padding
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => obscurePassword = !obscurePassword);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Role selection label
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Role', style: TextStyle(color: Colors.black)),
                  Text('الدور', style: TextStyle(color: Colors.black)),
                ],
              ),
              const SizedBox(height: 8),

              // Role Dropdown
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: DropdownButton<String>(
                  value: selectedRole,
                  underline: const SizedBox(),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'citizen', child: Text('Citizen')),
                    DropdownMenuItem(value: 'advertiser', child: Text('Advertiser')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedRole = value);
                    }
                  },
                  // Add vertical padding for visual consistency
                  dropdownColor: Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              // Sign-up Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2c2c2c),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Text('Sign-up   التسجيل', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

const SizedBox(height: 20),

Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Text(
      "Already have an account? ",
      style: TextStyle(
        color: Colors.black87,
        fontSize: 14,
      ),
    ),
    TextButton(
      onPressed: widget.onLoginTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(50, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        alignment: Alignment.centerLeft,
      ),
      child: const Text(
        "Login",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
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
}
