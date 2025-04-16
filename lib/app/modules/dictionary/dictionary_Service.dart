// lib/app/api/dictionary_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dictionary_model.dart';
import 'package:skystudy/app/api/api_config.dart';

class DictionaryApi {
  static const String baseUrl = ApiConfig.baseUrl;

  Future<Map<String, List<Dictionary>>> getTopWordsByTopic() async {
    try {
      final url = Uri.parse('$baseUrl/getTopWordsByTopic');
    
      final response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        
        // Không cần truy cập jsonData['data'], làm việc trực tiếp với jsonData
        Map<String, List<Dictionary>> result = {};

        jsonData.forEach((topic, words) {
         
          if (words is! List) {
            throw Exception('Words for topic "$topic" is not a List: $words');
          }
          result[topic] = words.map((word) {
            
            return Dictionary.fromJson(word);
          }).toList();
        });

        return result;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Future<List<Dictionary>> getWordByTopic(String topic) async {
    try {
        final url = Uri.parse('$baseUrl/getWordbyTopic'); // Sửa URL cho khớp với backend
        final response = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'topic': topic}),
        );

        if (response.statusCode == 200) {
            final jsonData = jsonDecode(response.body);
            if (jsonData['data'] == null || jsonData['data'] is! List) {
                throw Exception('Invalid data format: ${jsonData['data']}');
            }
            return (jsonData['data'] as List)
                .map((word) => Dictionary.fromJson(word as Map<String, dynamic>))
                .toList();
        } else {
            throw Exception('Failed to load words for topic "$topic": ${response.statusCode}');
        }
    } catch (e) {
        throw Exception('Error fetching words for topic "$topic": $e');
    }
}
}