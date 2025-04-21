import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:skystudy/app/api/api_config.dart'; // Adjust the import path based on your project structure

class LeaderboardController extends GetxController {
  final Logger logger = Logger();
  var leaderboardData = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/leaderboard'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        leaderboardData.value = data.asMap().entries.map((entry) {
          int index = entry.key;
          var user = entry.value;
          return {
            'name': user['username'],
            'score': user['point'],
            'avatar': _getAvatar(user['username']),
            'badge': _getBadge(index),
            'progress': _calculateProgress(user['point']),
          };
        }).toList();
        logger.i('Leaderboard data fetched: ${leaderboardData.length} entries');
      } else {
        logger.e('Failed to fetch leaderboard: ${response.statusCode}');
        Get.snackbar('Lỗi', 'Không thể tải bảng xếp hạng: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error fetching leaderboard: $e');
      Get.snackbar('Lỗi', 'Lỗi khi tải bảng xếp hạng: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _getAvatar(String username) {
    return username.length % 2 == 0 ? '👧' : '👦';
  }

  String _getBadge(int index) {
    switch (index) {
      case 0:
        return '🏆';
      case 1:
        return '🥈';
      case 2:
        return '🥉';
      case 3:
        return '🌟';
      case 4:
        return '⭐';
      case 5:
        return '✨';
      default:
        return '';
    }
  }

  double _calculateProgress(int points) {
    const maxPoints = 1250;
    return (points / maxPoints).clamp(0.0, 1.0);
  }
}