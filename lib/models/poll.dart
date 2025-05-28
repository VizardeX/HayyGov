class Poll {
  final String id;
  final String title;
  final int yes;
  final int no;

  Poll({
    required this.id,
    required this.title,
    required this.yes,
    required this.no,
  });

  factory Poll.fromFirestore(Map<String, dynamic> data, String id) {
    return Poll(
      id: id,
      title: data['Title'] ?? '',
      yes: data['Yes'] ?? 0,
      no: data['No'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Title': title,
      'Yes': yes,
      'No': no,
    };
  }
}
