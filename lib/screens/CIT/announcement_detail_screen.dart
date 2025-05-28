import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // 🧠 Import for Clipboard
import '../../screens/GOV/pdf_viewer_screen.dart';
import '../../models/announcement.dart';
import '../../models/comment.dart';
import '../../services/announcement_service.dart';
import '../../services/comment_filter_service.dart'; // 🧠 Import the AI filter

class AnnouncementDetailScreen extends StatefulWidget {
  final Announcement announcement;

  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  State<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  final service = AnnouncementService();
  final _controller = TextEditingController();
  bool anonymous = false;

  String _formatDate(DateTime dateTime) {
    return DateFormat('yyyy/MM/dd HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.announcement;
    final hasImage = a.picture.isNotEmpty;
    final hasEndTime = a.endTime != null;

    return Scaffold(
      appBar: AppBar(title: Text(a.title)),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (hasImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      a.picture,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  a.info,
                  style: const TextStyle(fontSize: 16),
                ),
                if (a.pdfUrl != null && a.pdfUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                    child: GestureDetector(
                      onTap: () async {
                        final url = a.pdfUrl!;
                        if (await canLaunch(url)) {
                          await launch(url, forceSafariVC: false, forceWebView: false);
                        } else {
                          // Show dialog with copy option
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: Row(
                                children: const [
                                  Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
                                  SizedBox(width: 10),
                                  Text('Could not open PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Unable to open the PDF link.',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.blue.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.link, color: Colors.blue, size: 18),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            url,
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontSize: 13,
                                              decoration: TextDecoration.underline,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.copy, size: 18, color: Colors.blue),
                                          tooltip: 'Copy Link',
                                          onPressed: () async {
                                            await Clipboard.setData(ClipboardData(text: url));
                                            Navigator.pop(ctx);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('PDF link copied to clipboard.')),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'You can copy the link and open it manually in your browser.',
                                    style: TextStyle(fontSize: 13, color: Colors.black54),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.picture_as_pdf, color: Colors.blue),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                a.pdfUrl!,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.open_in_new, color: Colors.blue, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  "📍 ${a.location}",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  hasEndTime
                      ? "🕒 ${_formatDate(a.timestamp)} → ${_formatDate(a.endTime!)}"
                      : "🕒 ${_formatDate(a.timestamp)}",
                  style: const TextStyle(color: Colors.grey),
                ),
                const Divider(height: 30),
                const Text(
                  "Comments",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                StreamBuilder<List<CommentModel>>(
                  stream: service.getComments(a.id),
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
                      separatorBuilder: (_, __) =>
                          const Divider(color: Colors.grey),
                      itemBuilder: (context, index) {
                        final c = comments[index];
                        return ListTile(
                          title: Text(c.author),
                          subtitle: Text(c.text),
                          trailing: Text(
                              "${c.timestamp.hour}:${c.timestamp.minute.toString().padLeft(2, '0')}"),
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
              color: const Color(0xFFF7F5F2), // subtle background, matches input fields
              border: Border.all(color: Color(0xFFB0A99F), width: 1.5),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      fillColor: const Color(0xFFF7F5F2),
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
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;

                    // 🔍 Check for offensive content
                    final isOffensive =
                        await CommentFilterService.isOffensive(text);

                    if (isOffensive) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Inappropriate Comment"),
                          content: const Text(
                              "Your comment seems offensive and cannot be posted."),
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

                    // ✅ Submit the comment
                    final comment = CommentModel(
                      text: text,
                      author: anonymous ? "Anonymous" : "You",
                      timestamp: DateTime.now(),
                    );

                    await service.addComment(a.id, comment);
                    _controller.clear();
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
