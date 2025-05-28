import 'package:cloud_firestore/cloud_firestore.dart';

class Ad {
  final String id;
  final String advertiserId;
  final String title;
  final String description;
  final String? imageUrl;
  final bool approved;
  final DateTime timestamp;

  Ad({
    required this.id,
    required this.advertiserId,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.approved,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'advertiserId': advertiserId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'approved': approved,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Ad.fromMap(String id, Map<String, dynamic> map) {
    return Ad(
      id: id,
      advertiserId: map['advertiserId'],
      title: map['title'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      approved: map['approved'] ?? false,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
