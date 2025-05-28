import 'package:flutter/material.dart';
import 'emergency_n.dart';
import 'citizen_announcements_polls_screen.dart';
import '../messaging/chat_screen.dart';
import '../report/report_form_screen.dart';
import '../AD/ad_feed_screen.dart';

class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    CitizenAnnouncementsPollsScreen(), // 0 - Announcements
    HomeScreen(), // 1 - Emergency
    ChatScreen(senderRole: "citizen"), // 2 - Chat
    ReportFormScreen(), // 3 - Report
    AdFeedScreen(), // 4 - Ads
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
          // 🔼 Top Navigation Bar
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
                Icons.campaign,
                color: _currentIndex == 0 ? Colors.black : Colors.black45,
              ),
            ),
            IconButton(
              onPressed: () => _handleNavigation(1),
              icon: Icon(
                Icons.phone,
                color: _currentIndex == 1 ? Colors.black : Colors.black45,
              ),
            ),
            IconButton(
              onPressed: () => _handleNavigation(2),
              icon: Icon(
                Icons.message,
                color: _currentIndex == 2 ? Colors.black : Colors.black45,
              ),
            ),
            IconButton(
              onPressed: () => _handleNavigation(3),
              icon: Icon(
                Icons.report,
                color: _currentIndex == 3 ? Colors.black : Colors.black45,
              ),
            ),
            IconButton(
              onPressed: () => _handleNavigation(4),
              icon: Icon(
                Icons.local_offer,
                color: _currentIndex == 4 ? Colors.black : Colors.black45,
              ),
            ),
          ],
        ),
      ],
    ),
  ),
),
          // 🔽 Screen content
          Expanded(child: _screens[_currentIndex]),
        ],
      ),
    );
  }
}
