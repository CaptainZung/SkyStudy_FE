import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:skystudy/app/api/api_config.dart';
import 'package:skystudy/app/utils/auth_manager.dart';

class ProgressService {
  final String baseUrl = ApiConfig.baseUrl;
  final Logger logger = Logger();

  Future<Map<String, dynamic>> fetchUserProgress() async {
    final token = await AuthManager.getToken();
    if (token == null) throw Exception('No token found');

    int retries = 3;
    while (retries > 0) {
      try {
        logger.i('Gửi yêu cầu fetchUserProgress, retries left: $retries');
        final response = await http.post(
          Uri.parse('$baseUrl/getUserHighestLevel'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 5));

        logger.i('fetchUserProgress response - Status: ${response.statusCode}, Body: ${response.body}');
        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          final progressData = jsonData['data'];
          return {'topic': progressData['topic'] ?? 'Family', 'node': progressData['node'] ?? 1};
        } else {
          throw Exception('Failed to fetch progress: ${response.statusCode}');
        }
      } catch (e) {
        retries--;
        logger.e('Lỗi fetchUserProgress, retries left: $retries, Error: $e');
        if (retries == 0) throw Exception('Failed to fetch progress after retries: $e');
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    throw Exception('Failed to fetch progress after all retries');
  }

  Future<String?> openMysteryChest(String topic) async {
    final token = await AuthManager.getToken();
    logger.i('Sending openMysteryChest request - Topic: $topic, Token: $token');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/openMysteryChest'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'topic': topic}),
      ).timeout(const Duration(seconds: 5));

      logger.i('openMysteryChest response - Status: ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.i('openMysteryChest success - Message: ${data['data']['message']}');
        return data['data']['message'];
      } else {
        logger.w('openMysteryChest failed - Status: ${response.statusCode}, Message: Rương này đã mở rồi! hoặc chưa đủ điều kiện!');
        return 'Rương này đã mở rồi! hoặc chưa đủ điều kiện!';
      }
    } catch (e) {
      logger.e('Error in openMysteryChest - Topic: $topic, Error: $e');
      return null;
    }
  }
}