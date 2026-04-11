import 'dart:convert';
import 'package:http/http.dart' as http;

class QuoteService {
  Future<Map<String, String>> fetchQuote() async {
    try {
      final response = await http
          .get(Uri.parse('https://zenquotes.io/api/random'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        if (data.isNotEmpty) {
          return {
            'quote': data[0]['q'] as String? ?? '',
            'author': data[0]['a'] as String? ?? '',
          };
        }
      }
    } catch (_) {}
    return {
      'quote': 'Take care of your body. It\'s the only place you have to live.',
      'author': 'Jim Rohn',
    };
  }
}
