import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'admin_chat_screen.dart';
import '../GOV/announcement_feed_screen.dart';
import '../GOV/polls_section.dart';
import '../GOV/emergency_n.dart';
import '../report/report_list_screen.dart';

class AdminInboxScreen extends StatefulWidget {
  const AdminInboxScreen({super.key});

  @override
  State<AdminInboxScreen> createState() => _AdminInboxScreenState();
}

class _AdminInboxScreenState extends State<AdminInboxScreen> {
  bool showInbox = true; // For the switch

  void _toggleView(bool inbox) {
    setState(() {
      showInbox = inbox;
    });
  }

  void _onHorizontalDrag(DragEndDetails details) {
    // Swipe left to go to Reports, right to go to Inbox
    if (details.primaryVelocity != null) {
      if (details.primaryVelocity! < -50) {
        _toggleView(false);
      } else if (details.primaryVelocity! > 50) {
        _toggleView(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatStream = FirebaseFirestore.instance
        .collection('chats')
        .orderBy('lastTimestamp', descending: true)
        .snapshots();
    final Color bgColor = const Color(0xFFE5E0DB);
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          //const SizedBox(height: 30), // for status bar space
          // --- Switch between Inbox and Reports ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: _onHorizontalDrag,
              child: Container(
                width: 240,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      alignment: showInbox ? Alignment.centerLeft : Alignment.centerRight,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: 120,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 62, 59, 45),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        // Inbox icon always on the left
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _toggleView(true);
                            },
                            child: Center(
                              child: Icon(
                                Icons.messenger,
                                color: showInbox ? Colors.white : Colors.green,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                        // Reports icon always on the right
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _toggleView(false);
                            },
                            child: Center(
                              child: Icon(
                                Icons.error,
                                color: showInbox ? Colors.orange : Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // --- End Switch --- Increased space below switch, matches emergency_n
          Expanded(
            child: showInbox
                ? StreamBuilder<QuerySnapshot>(
                    stream: chatStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return const Center(child: Text("No messages yet."));
                      }
                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          final senderId = docs[index].id;
                          final role = data['role'] ?? 'unknown';
                          final lastMessage = data['lastMessage'] ?? '';
                          final timestamp = (data['lastTimestamp'] as Timestamp).toDate();
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection('users').doc(senderId).get(),
                            builder: (context, userSnapshot) {
                              String displayName = senderId;
                              if (userSnapshot.connectionState == ConnectionState.done && userSnapshot.hasData) {
                                final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                                if (userData != null && userData.containsKey('email')) {
                                  displayName = userData['email'];
                                }
                              }
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: const Color(0xFFD6CFC7), width: 2),
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    role == "citizen" ? Icons.person : Icons.business,
                                    color: const Color(0xFF9C7B4B),
                                    size: 32,
                                  ),
                                  title: Text(
                                    "From: $displayName",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "$role - $lastMessage",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}",
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AdminChatScreen(
                                          userId: senderId,
                                          userRole: role,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  )
                : ReportListScreen(),
          ),
        ],
      ),
    );
  }
}