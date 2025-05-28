import 'dart:convert';
import 'package:http/http.dart' as http;

class CommentFilterService {
  static const String apiKey = 'AIzaSyAle2QH7QMEAPxJtZIjemJ1ZAnqo53Y57Y';
  static const String apiUrl = 'https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key=$apiKey';

  static Future<bool> isOffensive(String commentText) async {
    final body = {
      "comment": {"text": commentText},
      "languages": ["en", "ar"],
      "requestedAttributes": {"TOXICITY": {}, "INSULT": {}, "PROFANITY": {}}
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final double toxicityScore =
          result['attributeScores']['TOXICITY']['summaryScore']['value'];
      final double insultScore =
          result['attributeScores']['INSULT']['summaryScore']['value'];
      final double profanityScore =
          result['attributeScores']['PROFANITY']['summaryScore']['value'];

      // Threshold (adjustable)
      return toxicityScore > 0.7 || insultScore > 0.7 || profanityScore > 0.7;
    } else {
      print('API Error: ${response.statusCode}');
      return false; // Fail-safe: allow comment
    }
  }
}
