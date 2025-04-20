import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skystudy/app/utils/auth_manager.dart';
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

  static Future<void> completeLesson(String topic, int node) async {
    final logger = Logger();
    final token = await AuthManager.getToken();

    final url = Uri.parse('${ApiConfig.baseUrl}/completeLevel');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({'topic': topic, 'node': node});

    logger.i('📦 Gửi completeLesson → BODY = $body');

    final response = await http.post(url, headers: headers, body: body);

    logger.i('🔁 Status code: ${response.statusCode}');
    logger.i('🔁 Response body: ${response.body}');

    if (response.statusCode != 200) {
      final body = response.body;

      // ✅ Trường hợp đặc biệt: đã hoàn thành thì vẫn coi là thành công
      if (body.contains('Level already completed')) {
        return; // ⬅️ coi như xong
      }

      // ❌ Các lỗi khác thì vẫn ném ra
      throw Exception('Failed to mark lesson as complete: $body');
    }
  }
}
