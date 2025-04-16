import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lesson_model.dart';
import '../../../api/api_config.dart';
import 'package:logger/logger.dart';

class LessonService {
  // Đã loại bỏ exercise, nó sẽ là giá trị cố định trong URL
  static Future<LessonModel> fetchLesson(String topic, int node) async {
    final Logger logger = Logger();

    final url = Uri.parse('${ApiConfig.baseUrl}/getLesson2'); // Lấy bài học theo exercise cố định
    
    // Log request
    logger.i('Request to API: ${url.toString()}');
    logger.i('Request body: {"topic": "$topic", "node": $node}');
  
    // Gửi yêu cầu HTTP POST
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'topic': topic, 'node': node}),  // Chỉ truyền topic và node
    );
  
    // Log response status và body
    logger.i('Response status code: ${response.statusCode}');
    logger.i('Response body: ${response.body}');
  
    // Kiểm tra nếu response status là 200
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      logger.i('Response Data: $data');  // Log dữ liệu trả về từ API
  
      // Kiểm tra xem dữ liệu có hợp lệ không
      if (data['data'] != null) {
        return LessonModel.fromJson(data['data'][0]);
      } else {
        logger.e('Data not found in response');
        throw Exception('Dữ liệu bài học không có');
      }
    } else {
      // Nếu có lỗi, log chi tiết lỗi và ném exception
      logger.e('Error: ${response.statusCode} ${response.body}');
      throw Exception('Không thể tải bài học');
    }
  }
}
