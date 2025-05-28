class CommentModel {
  final String text;
  final String author;
  final DateTime timestamp;

  CommentModel({
    required this.text,
    required this.author,
    required this.timestamp,
  });

  factory CommentModel.fromFirestore(Map<String, dynamic> data) {
    return CommentModel(
      text: data['Text'] ?? '',
      author: data['Author'] ?? 'Anonymous',
      timestamp: data['Timestamp'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Text': text,
      'Author': author,
      'Timestamp': timestamp,
    };
  }
}
