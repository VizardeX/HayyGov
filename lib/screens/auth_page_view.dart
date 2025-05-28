import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class AuthPageView extends StatefulWidget {
  const AuthPageView({super.key});

  @override
  State<AuthPageView> createState() => _AuthPageViewState();
}

class _AuthPageViewState extends State<AuthPageView> {
  late final PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  void goToSignup() {
    _controller.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentPage = 1);
  }

  void goToLogin() {
    _controller.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentPage = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/bg.png',
            fit: BoxFit.cover,
          ),
          // White overlay
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.5)),
          ),
          // Main content (PageView and buttons)
          Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  children: [
                    LoginScreen(onSignUpTap: goToSignup),
                    SignupScreen(onLoginTap: goToLogin),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 24, top: 8),
                child: Row(
                  children: [
                    // Login button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _currentPage == 0 ? null : goToLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.7),
                          foregroundColor: Colors.white70,
                          disabledBackgroundColor: Colors.black,
                          disabledForegroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(left: Radius.circular(32)),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: Column(
                          children: const [
                            Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('الدخول', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    // Signup button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _currentPage == 1 ? null : goToSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.7),
                          foregroundColor: Colors.white70,
                          disabledBackgroundColor: Colors.black,
                          disabledForegroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(right: Radius.circular(32)),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: Column(
                          children: const [
                            Text('Sign-up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('التسجيل', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
