import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:skystudy/app/api/api_config.dart';
import 'package:skystudy/app/utils/auth_manager.dart';

class ProgressService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<Map<String, dynamic>> fetchUserProgress() async {
    final token = await AuthManager.getToken();

    if (token == null) throw Exception('No token found');

    final response = await http.post(
      Uri.parse('$baseUrl/GetUserHighestLevel'),
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
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/GetUserHighestLevel'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
        body: jsonEncode({'topic': topic}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['message'];
      } else {
        return 'Rương này đã mở rồi! hoặc chưa đủ điều kiện!';
      }
    } catch (e) {
      return null;
    }
  }
}
