import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/message.dart';
import '../GOV/announcement_feed_screen.dart';
import '../GOV/polls_section.dart';
import '../GOV/emergency_n.dart';
import '../report/report_list_screen.dart';

class AdminChatScreen extends StatefulWidget {
  final String userId;
  final String userRole;

  const AdminChatScreen({super.key, required this.userId, required this.userRole});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  final String adminId = "gov"; // gov is always the sender from admin side

  Future<void> sendReply() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final message = Message(
      senderId: adminId,
      receiverId: widget.userId,
      text: text,
      timestamp: DateTime.now(),
    );

    final chatRef = _firestore.collection("chats").doc(widget.userId);

    try {
      // Update metadata
      await chatRef.set({
        'role': widget.userRole,
        'lastMessage': text,
        'lastTimestamp': Timestamp.now(),
      }, SetOptions(merge: true));

      // Add the message to the thread
      await chatRef.collection("messages").add(message.toMap());

      _controller.clear();
    } catch (e) {
      // Error handling
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = _firestore
        .collection("chats")
        .doc(widget.userId)
        .collection("messages")
        .orderBy("timestamp", descending: false);

    final Color bgColor = const Color(0xFFE5E0DB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Admin Chat',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30), // for status bar space
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final msg = Message.fromMap(docs[index].data() as Map<String, dynamic>);
                    final isAdmin = msg.senderId == adminId;

                    return Align(
                      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isAdmin ? const Color.fromARGB(255, 255, 255, 255) :  const Color.fromARGB(255, 184, 149, 110),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg.text),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 30),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.brown),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: sendReply,
                  child: const Icon(Icons.send, color: Colors.black, size: 24),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(15),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}