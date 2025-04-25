import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:skystudy/app/utils/auth_manager.dart';
import 'package:skystudy/app/api/api_config.dart';
import 'package:skystudy/app/modules/achievements/achivement_model.dart';
import 'package:skystudy/app/modules/achievements/claim_achievement_response.dart';

class AchievementApi {
  static const String baseUrl = ApiConfig.baseUrl;

  // Khởi tạo Logger
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  // Lấy danh sách thành tựu
  Future<List<Achievement>> getAchievements() async {
    try {
      final url = Uri.parse('$baseUrl/checkAndInsertAchievements');
      _logger.d('Đang gọi API lấy danh sách thành tựu từ $url');

      final token = await AuthManager.getToken();
      _logger.d('Sử dụng token: ${token?.substring(0, token.length > 10 ? 10 : token.length)}...');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _logger.i('Mã trạng thái phản hồi: ${response.statusCode}');
      _logger.d('Nội dung phản hồi: ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<dynamic> achievementList;

        // Kiểm tra định dạng dữ liệu
        if (jsonData is List) {
          achievementList = jsonData; // Dữ liệu là danh sách trực tiếp
        } else if (jsonData is Map<String, dynamic> && jsonData.containsKey('data')) {
          achievementList = jsonData['data']; // Dữ liệu trong trường 'data'
          if (achievementList is! List) {
            _logger.e('Trường "data" không phải danh sách: $achievementList');
            throw Exception('Invalid data format: Expected a list in "data" field');
          }
        } else {
          _logger.e('Định dạng dữ liệu không hợp lệ: Dự kiến là danh sách hoặc đối tượng chứa trường "data", nhận được: $jsonData');
          throw Exception('Invalid data format: Expected a list or an object with "data" field');
        }

        _logger.i('Đã phân tích thành công ${achievementList.length} thành tựu');
        return achievementList.map((json) => Achievement.fromJson(json)).toList();
      } else {
        _logger.w('Không thể tải danh sách thành tựu: Mã trạng thái ${response.statusCode}');
        throw Exception('Failed to load achievements: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Lỗi khi lấy danh sách thành tựu: $e');
      throw Exception('Error fetching achievements: $e');
    }
  }

  // Nhận thưởng thành tựu
  Future<ClaimAchievementResponse> claimAchievement(int achievementId) async {
    try {
      final url = Uri.parse('$baseUrl/claimAchievement');
      _logger.d('Đang gọi API nhận thưởng thành tựu $achievementId từ $url');

      final token = await AuthManager.getToken();
      _logger.d('Sử dụng token: ${token?.substring(0, token.length > 10 ? 10 : token.length)}...');

      final body = jsonEncode({
        'achievement_id': achievementId.toString(),
      });
      _logger.d('Nội dung yêu cầu: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      _logger.i('Mã trạng thái phản hồi: ${response.statusCode}');
      _logger.d('Nội dung phản hồi: ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        _logger.i('Đã phân tích thành công phản hồi nhận thưởng: $jsonData');
        return ClaimAchievementResponse.fromJson(jsonData);
      } else {
        _logger.w('Không thể nhận thưởng thành tựu "$achievementId": Mã trạng thái ${response.statusCode}');
        throw Exception('Failed to claim achievement "$achievementId": ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Lỗi khi nhận thưởng thành tựu "$achievementId": $e');
      throw Exception('Error claiming achievement "$achievementId": $e');
    }
  }
}