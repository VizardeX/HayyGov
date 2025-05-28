import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/poll.dart';
import '../models/comment.dart';

class PollService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Poll>> getPolls() {
    return _db.collection('Polls').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Poll.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> vote(String pollId, String choice) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final userId = user.uid;

    final docRef = _db.collection('Polls').doc(pollId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = snapshot.data() ?? {};

      List<dynamic> voters = data['Voters'] ?? [];

      if (voters.contains(userId)) {
        throw Exception("You've already voted!");
      }

      final updatedFields = {
        'Voters': FieldValue.arrayUnion([userId]),
        if (choice == 'yes') 'Yes': (data['Yes'] ?? 0) + 1,
        if (choice == 'no') 'No': (data['No'] ?? 0) + 1,
      };

      transaction.update(docRef, updatedFields);
    });
  }

  Future<void> deletePoll(String pollId) async {
    await _db.collection('Polls').doc(pollId).delete();
  }

  Future<void> updatePoll(String pollId, Map<String, dynamic> data) async {
    await _db.collection('Polls').doc(pollId).update(data);
  }

  // 💬 Stream comments for a poll
  Stream<List<CommentModel>> getComments(String pollId) {
    return _db
        .collection('Polls')
        .doc(pollId)
        .collection('Comments')
        .orderBy('Timestamp')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CommentModel.fromFirestore(doc.data())).toList();
    });
  }

  // 📝 Add a comment to a poll
  Future<void> addComment(String pollId, CommentModel comment) async {
    final data = comment.toMap();
    await _db
        .collection('Polls')
        .doc(pollId)
        .collection('Comments')
        .add(data);
  }
}
