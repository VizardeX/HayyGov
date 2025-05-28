class Announcement {
  final String title;
  final String info;
  final String location;
  final String picture;
  final DateTime timestamp;
  final DateTime? endTime;
  final String id; // Firestore doc ID
  final String? pdfUrl;

  Announcement({
    required this.title,
    required this.info,
    required this.location,
    required this.picture,
    required this.timestamp,
    this.endTime,
    required this.id,
    this.pdfUrl,
  });

  factory Announcement.fromFirestore(Map<String, dynamic> data, String id) {
    return Announcement(
      title: data['Title'] ?? '',
      info: data['Info'] ?? '',
      location: data['Location'] ?? '',
      picture: data['Picture'] ?? '',
      timestamp: data['Time'].toDate(),
      endTime: data['EndTime']?.toDate(),
      id: id,
      pdfUrl: data['PdfUrl'],
    );
  }
}
