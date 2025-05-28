import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/comment.dart';
import '../../services/poll_service.dart';
import '../../services/comment_filter_service.dart';

class PollDetailScreen extends StatefulWidget {
  final String pollId;
  final String title;
  final Map<String, int> entries;
  final List<String> voters;
  final bool hasVoted;

  const PollDetailScreen({
    super.key,
    required this.pollId,
    required this.title,
    required this.entries,
    required this.voters,
    required this.hasVoted,
  });

  @override
  State<PollDetailScreen> createState() => _PollDetailScreenState();
}

class _PollDetailScreenState extends State<PollDetailScreen> {
  String? selectedOption;
  final TextEditingController _commentController = TextEditingController();
  bool anonymous = false;
  final pollService = PollService();

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final totalVotes = widget.entries.values.fold<int>(0, (a, b) => a + b);
    final hasVoted = widget.voters.contains(userId);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 16),
                if (!hasVoted) ...[
                  ...widget.entries.keys.map((choice) {
                    return RadioListTile<String>(
                      title: Text(choice),
                      value: choice,
                      groupValue: selectedOption,
                      onChanged: (val) => setState(() => selectedOption = val),
                    );
                  }),
                  ElevatedButton(
                    onPressed: selectedOption == null
                        ? null
                        : () async {
                            final choice = selectedOption!;
                            await FirebaseFirestore.instance
                                .collection('Polls')
                                .doc(widget.pollId)
                                .update({
                              choice: FieldValue.increment(1),
                              'Voters': FieldValue.arrayUnion([userId]),
                            });
                            setState(() {
                              widget.voters.add(userId); // Mark as voted instantly in UI
                              widget.entries[choice] = (widget.entries[choice] ?? 0) + 1; // Update local count
                              selectedOption = null;
                            });
                          },
                    child: const Center(child: Text("Vote")),
                  ),
                ] else ...[
                  const Text("✅ You’ve already voted", style: TextStyle(color: Colors.green)),
                  const SizedBox(height: 8),
                  ...widget.entries.entries.map((entry) {
                    final label = entry.key;
                    final votes = entry.value;
                    final percent = totalVotes > 0 ? (votes / totalVotes * 100).toStringAsFixed(1) : '0.0';
                    final parsedPercent = double.tryParse(percent) ?? 0.0;
                    final barWidth = MediaQuery.of(context).size.width * (parsedPercent / 100);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label),
                          Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              Container(
                                width: barWidth,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ),
                          Text('$percent%', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    );
                  }),
                ],
                const Divider(height: 30),
                const Text("Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                StreamBuilder<List<CommentModel>>(
                  stream: pollService.getComments(widget.pollId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final comments = snapshot.data!;
                    if (comments.isEmpty) {
                      return const Text("No comments yet.");
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => const Divider(color: Colors.grey),
                      itemBuilder: (context, index) {
                        final c = comments[index];
                        return ListTile(
                          title: Text(c.author),
                          subtitle: Text(c.text),
                          trailing: Text("${c.timestamp.hour}:${c.timestamp.minute.toString().padLeft(2, '0')}")
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5F2),
              border: Border.all(color: Color(0xFFB0A99F), width: 1.5),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      fillColor: Color(0xFFF7F5F2),
                      hintText: 'Write a comment...',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                    ),
                  ),
                ),
                Column(
                  children: [
                    const Text("Anon"),
                    Switch(
                      value: anonymous,
                      onChanged: (val) => setState(() => anonymous = val),
                      activeColor: const Color(0xFF22211F),
                      activeTrackColor: const Color(0xFFB0A99F),
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: Colors.grey.shade300,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = _commentController.text.trim();
                    if (text.isEmpty) return;
                    final isOffensive = await CommentFilterService.isOffensive(text);
                    if (isOffensive) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Inappropriate Comment"),
                          content: const Text("Your comment seems offensive and cannot be posted."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                    final comment = CommentModel(
                      text: text,
                      author: anonymous ? "Anonymous" : "You",
                      timestamp: DateTime.now(),
                    );
                    await pollService.addComment(widget.pollId, comment);
                    _commentController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
