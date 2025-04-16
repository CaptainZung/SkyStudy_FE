import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lesson_model.dart';
import 'package:skystudy/app/api/api_config.dart';
import 'package:logger/logger.dart';

class Exercise4Service {
  static Future<Exercise4Model> fetchLesson(String topic, int node) async {
    final logger = Logger();
    final url = Uri.parse('${ApiConfig.baseUrl}/getLesson4');

    logger.i('Requesting $url');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'topic': topic, 'node': node}),
    );

    logger.i('Response status: ${response.statusCode}');
    logger.i('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Exercise4Model.fromJson(data['data'][0]);
    } else {
      throw Exception('Failed to load lesson');
    }
  }
}
