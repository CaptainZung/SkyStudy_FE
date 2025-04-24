import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import 'package:skystudy/app/api/api_config.dart';
import 'package:skystudy/app/utils/auth_manager.dart';

class PronunciationCheckService {
  final String baseUrl = ApiConfig.baseUrl;
  final Logger logger = Logger();

  // ignore: non_constant_identifier_names
  Future<String> SaveWord(String word) async {
    final token = await AuthManager.getToken();

    if (token == null) throw Exception('No token found');

    final response = await http.post(
      Uri.parse('$baseUrl/addWordToYourDictionary'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'word': word}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message']; // "word added to your dictionary successfully"
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to add word');
      }
  }
}
