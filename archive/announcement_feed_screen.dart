import 'package:flutter/material.dart';
import 'package:continuehayygov/models/announcement.dart';
import 'package:continuehayygov/services/announcement_service.dart';
import 'package:continuehayygov/screens/CIT/announcement_detail_screen.dart';

class AnnouncementFeedScreen extends StatelessWidget {
  AnnouncementFeedScreen({super.key});
  final service = AnnouncementService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Announcements')),
      body: FutureBuilder<List<Announcement>>(
        future: service.getAnnouncements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No announcements found.'));
          }

          final announcements = snapshot.data!;

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final a = announcements[index];
              return ListTile(
                title: Text(a.title),
                subtitle: Text(a.location),
                trailing: Text('${a.timestamp.year}/${a.timestamp.month}/${a.timestamp.day}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AnnouncementDetailScreen(announcement: a)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
