import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement.dart';
import '../models/comment.dart';

class AnnouncementService {
  final _db = FirebaseFirestore.instance;

  // 🔥 Fetch announcements ordered by the 'Time' field (Timestamp)
  Future<List<Announcement>> getAnnouncements() async {
    final snapshot = await _db
        .collection('Announcements')
        .orderBy('Time', descending: true)
        .get();

    // print("📄 Announcements fetched: ${snapshot.docs.length}");

    return snapshot.docs
        .map((doc) => Announcement.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // 💬 Stream comments from the correct 'Comments' subcollection (with capital C)
  Stream<List<CommentModel>> getComments(String announcementId) {
    return _db
        .collection('Announcements')
        .doc(announcementId)
        .collection('Comments') // ✅ MATCHES YOUR FIRESTORE STRUCTURE
        .orderBy('Timestamp')   // ✅ MUST MATCH Firestore field exactly
        .snapshots()
        .map((snapshot) {
          // print("📥 Streaming ${snapshot.docs.length} comments for $announcementId");
          // for (var doc in snapshot.docs) {
          //   print("🧾 ${doc.data()}");
          // }
          return snapshot.docs
              .map((doc) => CommentModel.fromFirestore(doc.data()))
              .toList();
        });
  }

  // 📝 Add a comment to the correct subcollection with TitleCase field names
  Future<void> addComment(String announcementId, CommentModel comment) async {
    final data = comment.toMap();
    // print("📨 Adding comment: $data");

    await _db
        .collection('Announcements')
        .doc(announcementId)
        .collection('Comments') // ✅ Again, must match Firestore
        .add(data);
  }
}
