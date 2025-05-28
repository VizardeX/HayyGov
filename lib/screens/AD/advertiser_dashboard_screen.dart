import 'package:flutter/material.dart';
import '../CIT/emergency_n.dart';
import '../CIT/citizen_announcements_polls_screen.dart';
import '../messaging/chat_screen.dart';
import '../report/report_form_screen.dart';
import 'ad_feed_screen.dart';
import 'create_ad_screen.dart';
import 'my_ads_screen.dart';

class AdvertiserDashboardScreen extends StatefulWidget {
  const AdvertiserDashboardScreen({super.key});

  @override
  State<AdvertiserDashboardScreen> createState() => _AdvertiserDashboardScreenState();
}

class _AdvertiserDashboardScreenState extends State<AdvertiserDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    CreateAdScreen(),
    MyAdsScreen(),
  ];

  void _handleNavigation(int index) {
    if (index < _screens.length) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E0DB),
      body: Column(
        children: [
          const SizedBox(height: 30), // for status bar space
          // Top Navigation Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: const AssetImage('assets/images/bg.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.dstATop,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'HayyGov',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () => _handleNavigation(0),
                        icon: Icon(
                          Icons.post_add,
                          color: _currentIndex == 0 ? Colors.black : Colors.black45,
                        ),
                        tooltip: 'Create Ad',
                      ),
                      IconButton(
                        onPressed: () => _handleNavigation(1),
                        icon: Icon(
                          Icons.edit_note,
                          color: _currentIndex == 1 ? Colors.black : Colors.black45,
                        ),
                        tooltip: 'My Ads',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Screen content
          Expanded(child: _screens[_currentIndex]),
        ],
      ),
    );
  }
}
