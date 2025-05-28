import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

import '../../models/announcement.dart';
import '../../services/announcement_service.dart';
import 'announcement_detail_screen.dart';
import '../../services/poll_service.dart';
import '../../models/comment.dart';
import '../../services/comment_filter_service.dart';
import 'poll_detail_screen.dart';

class CitizenAnnouncementsPollsScreen extends StatefulWidget {
  const CitizenAnnouncementsPollsScreen({super.key});

  @override
  State<CitizenAnnouncementsPollsScreen> createState() =>
      _CitizenAnnouncementsPollsScreenState();
}

class _CitizenAnnouncementsPollsScreenState
    extends State<CitizenAnnouncementsPollsScreen> {
  final announcementService = AnnouncementService();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _pollsKey = GlobalKey();
  bool showAllAnnouncements = false;

  Future<String> _formatDateTime(DateTime? date) async {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy - h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E0DB),
      body: FutureBuilder<List<Announcement>>(
        future: announcementService.getAnnouncements(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final announcements = snapshot.data!;
          final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

          // Show only the latest 3 announcements unless expanded
          final visibleAnnouncements =
              showAllAnnouncements
                  ? announcements
                  : announcements.take(3).toList();

          return Stack(
            children: [
              PrimaryScrollController(
                controller: _scrollController,
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Text(
                        '📣 Announcements',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // After const SizedBox(height: 10), and before ...visibleAnnouncements.map(...)
                    ...visibleAnnouncements.map((announcement) {
                      return FutureBuilder<String>(
                        future: _formatDateTime(announcement.timestamp),
                        builder: (context, snapshot) {
                          final dateLabel = snapshot.data ?? '';
                          final Color cardColor = Colors.white;
                          final Color borderColor = const Color(0xFFD6CFC7);
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: borderColor, width: 2),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header row with icon and title
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.amber,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              announcement.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "Date: $dateLabel",
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Location row
                                  if (announcement.location.isNotEmpty)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.black54,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          announcement.location,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (announcement.location.isNotEmpty)
                                    const SizedBox(height: 12),
                                  // Image and info row
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (announcement.picture.isNotEmpty &&
                                          Uri.tryParse(
                                                announcement.picture,
                                              )?.hasAbsolutePath ==
                                              true)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            announcement.picture,
                                            height: 120,
                                            width: 160,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const SizedBox(
                                                      width: 160,
                                                      height: 120,
                                                    ),
                                          ),
                                        ),
                                      if (announcement.picture.isNotEmpty)
                                        const SizedBox(width: 16),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 14,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: borderColor,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Text(
                                            announcement.info,
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // PDF URL row (if present)
                                  if (announcement.pdfUrl != null &&
                                      announcement.pdfUrl!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 10,
                                        bottom: 2,
                                      ),
                                      child: GestureDetector(
                                        onTap: () async {
                                          final url = announcement.pdfUrl!;
                                          if (await canLaunch(url)) {
                                            await launch(
                                              url,
                                              forceSafariVC: false,
                                              forceWebView: false,
                                            );
                                          } else {
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (ctx) => AlertDialog(
                                                    title: const Text(
                                                      'Could not open PDF',
                                                    ),
                                                    content: SelectableText(
                                                      url,
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Clipboard.setData(
                                                            ClipboardData(
                                                              text: url,
                                                            ),
                                                          );
                                                          Navigator.pop(ctx);
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                'PDF link copied to clipboard.',
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: const Text(
                                                          'Copy Link',
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              ctx,
                                                            ),
                                                        child: const Text(
                                                          'Close',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            );
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.picture_as_pdf,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                announcement.pdfUrl!,
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.open_in_new,
                                              color: Colors.blue,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 0,
                                        vertical: 0,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (_) =>
                                                            AnnouncementDetailScreen(
                                                              announcement:
                                                                  announcement,
                                                            ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                ),
                                                alignment: Alignment.centerLeft,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                    ),
                                                child: Text(
                                                  'Write a comment...',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade500,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) =>
                                                          AnnouncementDetailScreen(
                                                            announcement:
                                                                announcement,
                                                          ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(10.0),
                                                child: Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                  size: 22,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                    if (announcements.length > 3 && !showAllAnnouncements)
                      Center(
                        child: Material(
                          color: Color(0xFFEAD8C5), // Change parent Material color to a light brown
                          borderRadius: BorderRadius.circular(24),
                          elevation: 4,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              setState(() {
                                showAllAnnouncements = !showAllAnnouncements;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.black87,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Show More Announcements',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Polls section remains always visible
                    SizedBox(
                      key: _pollsKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              '🗳 Polls',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 10),
                          StreamBuilder<QuerySnapshot>(
                            stream:
                                FirebaseFirestore.instance
                                    .collection('Polls')
                                    .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              }
                              final polls = snapshot.data!.docs;
                              final pollService = PollService();

                              return Column(
                                children:
                                    polls.map((doc) {
                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      final pollId = doc.id;
                                      final title = data['Title'] ?? '';
                                      final voters = List<String>.from(
                                        data['Voters'] ?? [],
                                      );
                                      final hasVoted = voters.contains(userId);
                                      final entries =
                                          Map<String, int>.fromEntries(
                                            data.entries
                                                .where(
                                                  (e) =>
                                                      e.key != 'Title' &&
                                                      e.key != 'Voters' &&
                                                      e.value is int,
                                                )
                                                .map(
                                                  (e) => MapEntry(
                                                    e.key,
                                                    e.value as int,
                                                  ),
                                                ),
                                          );
                                      final totalVotes = entries.values
                                          .fold<int>(0, (a, b) => a + b);
                                      // Find the leading option (for preview)
                                      String? leadingOption;
                                      int maxVotes = -1;
                                      entries.forEach((k, v) {
                                        if (v > maxVotes) {
                                          maxVotes = v;
                                          leadingOption = k;
                                        }
                                      });
                                      final percent =
                                          (totalVotes > 0 &&
                                                  leadingOption != null)
                                              ? ((entries[leadingOption] ?? 0) /
                                                      totalVotes *
                                                      100)
                                                  .toStringAsFixed(0)
                                              : '0';
                                      return StatefulBuilder(
                                        builder: (context, setPollState) {
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) => PollDetailScreen(
                                                        pollId: pollId,
                                                        title: title,
                                                        entries: entries,
                                                        voters: voters,
                                                        hasVoted: hasVoted,
                                                      ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              padding: const EdgeInsets.all(18),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFFD6CFC7,
                                                  ),
                                                  width: 2,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.03),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.poll,
                                                        color:
                                                            Colors
                                                                .blue
                                                                .shade700,
                                                        size: 28,
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Text(
                                                          title,
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 17,
                                                              ),
                                                          maxLines: 2,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  if (entries.isNotEmpty &&
                                                      leadingOption != null)
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 10,
                                                                vertical: 4,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color:
                                                                Colors
                                                                    .blue
                                                                    .shade50,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .leaderboard,
                                                                color:
                                                                    Colors
                                                                        .blue
                                                                        .shade400,
                                                                size: 18,
                                                              ),
                                                              const SizedBox(
                                                                width: 4,
                                                              ),
                                                              Text(
                                                                '$leadingOption',
                                                                style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text(
                                                                '$percent%',
                                                                style: const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .blue,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        Text(
                                                          '$totalVotes votes',
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 13,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  if (entries.isEmpty)
                                                    const Text(
                                                      'No votes yet',
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        hasVoted
                                                            ? Icons.check_circle
                                                            : Icons
                                                                .radio_button_unchecked,
                                                        color:
                                                            hasVoted
                                                                ? Colors.green
                                                                : Colors.grey,
                                                        size: 18,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        hasVoted
                                                            ? 'You voted'
                                                            : 'Not voted',
                                                        style: TextStyle(
                                                          color:
                                                              hasVoted
                                                                  ? Colors.green
                                                                  : Colors.grey,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Floating close button overlay for extra announcements
              if (showAllAnnouncements && announcements.length > 3)
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Material(
                      color: Color(0xFFEAD8C5),
                      borderRadius: BorderRadius.circular(24),
                      elevation: 4,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          setState(() {
                            showAllAnnouncements = false;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black87,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Show Less Announcements',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
