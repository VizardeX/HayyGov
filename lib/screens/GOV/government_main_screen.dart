import 'package:flutter/material.dart';
import 'polls_section.dart';
import 'emergency_n.dart';
import '../messaging/admin_inbox_screen.dart';
import '../report/report_list_screen.dart';
import '../AD/ad_approval_screen.dart';
import 'announcement_feed_screen.dart';
import 'gov_dashboard_header.dart';

class GovernmentMainScreen extends StatefulWidget {
  const GovernmentMainScreen({super.key});

  @override
  State<GovernmentMainScreen> createState() => _GovernmentMainScreenState();
}

class _GovernmentMainScreenState extends State<GovernmentMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    _GovDashboard(), // 0: Dashboard
    AnnouncementFeedScreen(), // 1: Announcements
    PollsSection(), // 2: Polls
    AdminInboxScreen(), // 4: Inbox
    EmergencyN(), // 3: Emergency
  ];

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E0DB),
      body: SafeArea(
        child: Column(
          children: [
            GovDashboardHeader(onNav: _navigateTo, currentIndex: _currentIndex),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GovDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final parentState = context.findAncestorStateOfType<_GovernmentMainScreenState>();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ListTile(
          leading: const Icon(Icons.announcement),
          title: const Text('Announcements'),
          onTap: () => parentState?._navigateTo(1),
        ),
        ListTile(
          leading: const Icon(Icons.poll),
          title: const Text('Polls'),
          onTap: () => parentState?._navigateTo(2),
        ),
        ListTile(
          leading: const Icon(Icons.phone),
          title: const Text('Emergency Numbers'),
          onTap: () => parentState?._navigateTo(3),
        ),
        ListTile(
          leading: const Icon(Icons.message),
          title: const Text('Inbox'),
          onTap: () => parentState?._navigateTo(4),
        ),
        ListTile(
          leading: const Icon(Icons.report_problem),
          title: const Text('Reports'),
          onTap: () => parentState?._navigateTo(5),
        ),
        ListTile(
          leading: const Icon(Icons.verified),
          title: const Text('Approve Ads'),
          onTap: () => parentState?._navigateTo(6),
        ),
      ],
    );
  }
}
