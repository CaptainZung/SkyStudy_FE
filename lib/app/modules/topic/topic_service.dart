import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skystudy/app/utils/auth_manager.dart';
import 'package:skystudy/app/api/api_config.dart';

class TopicApi {
  static const String baseUrl = ApiConfig.baseUrl;

  Future<Map<String, dynamic>> getword(String topic) async {
    try {
      final url = Uri.parse('$baseUrl/suggestWord');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await AuthManager.getToken()}',
        },
        body: jsonEncode({'topic': topic}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData == null) {
          throw Exception('Invalid data format: $jsonData');
        }
        return jsonData; // Trả về từ vựng duy nhất
      } else {
        throw Exception(
          'Failed to load word for topic "$topic": ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching word for topic "$topic": $e');
    }
  }
}