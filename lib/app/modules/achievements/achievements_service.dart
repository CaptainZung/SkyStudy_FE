import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skystudy/app/utils/auth_manager.dart';
import 'package:skystudy/app/api/api_config.dart';
import 'package:skystudy/app/modules/achievements/achivement_model.dart';
import 'package:skystudy/app/modules/achievements/claim_achievement_response.dart';
import 'package:skystudy/app/modules/achievements/sticker/sticker_model.dart';

class AchievementApi {
  static const String baseUrl = ApiConfig.baseUrl;

  Future<http.Response> getmethod(String nameurls) async {
    final url = Uri.parse('$baseUrl/$nameurls');
    final token = await AuthManager.getToken();
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  // Lấy danh sách thành tựu
  Future<List<Achievement>> getAchievements() async {
    try {
      final response = await getmethod('checkAndInsertAchievements');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is! List) {
          throw Exception(
            'Invalid data format: Expected a list of achievements',
          );
        }
        return jsonData.map((json) => Achievement.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load achievements: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching achievements: $e');
    }
  }

  // Nhận thưởng thành tựu
  Future<ClaimAchievementResponse> claimAchievement(int achievementId) async {
    try {
      final url = Uri.parse('$baseUrl/claimAchievement');
      final token = await AuthManager.getToken();

      final body = jsonEncode({'achievement_id': achievementId.toString()});

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ClaimAchievementResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to claim achievement "$achievementId": ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error claiming achievement "$achievementId": $e');
    }
  }

Future<List<Sticker>> getUserStickers() async {
    try {
      final response = await getmethod('getUserSticker');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is! List) {
          throw Exception(
            'Invalid data format: Expected a list of stickers',
          );
        }
        return jsonData.map((json) => Sticker.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load stickers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching stickers: $e');
    }
  }
}

