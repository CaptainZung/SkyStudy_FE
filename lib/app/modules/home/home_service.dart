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
}
