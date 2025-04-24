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

    final response = await http.post(
      Uri.parse('$baseUrl/getUserHighestLevel'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final progressData = jsonData['data'];

      return {'topic': progressData['topic'], 'node': progressData['node']};
    } else {
      throw Exception('Failed to fetch progress: ${response.statusCode}');
    }
  }
  Future<String?> openMysteryChest(String topic) async {
    final token = await AuthManager.getToken();
    
    // Log token và topic trước khi gửi request
    logger.i('Sending openMysteryChest request - Topic: $topic, Token: $token');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/openMysteryChest'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'topic': topic}),
      );

      // Log status code và response body
      logger.i('openMysteryChest response - Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Log message từ response
        logger.i('openMysteryChest success - Message: ${data['data']['message']}');
        return data['data']['message'];
      } else {
        // Log lỗi khi status code không phải 200
        logger.w('openMysteryChest failed - Status: ${response.statusCode}, Message: Rương này đã mở rồi! hoặc chưa đủ điều kiện!');
        return 'Rương này đã mở rồi! hoặc chưa đủ điều kiện!';
      }
    } catch (e) {
      // Log lỗi nếu có exception
      logger.e('Error in openMysteryChest - Topic: $topic, Error: $e');
      return null;
    }
  }
}