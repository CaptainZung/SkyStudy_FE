import 'dart:convert';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skystudy/app/modules/achievements/achievements_service.dart';
import 'package:skystudy/app/modules/achievements/achivement_model.dart';

class AchievementsController extends GetxController {
  final AchievementApi _achievementApi = AchievementApi();
  var achievements = <Achievement>[].obs; // Sử dụng RxList
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

  // Key cho SharedPreferences
  static const String _cacheKey = 'achievements_cache';
  static const String _cacheTimestampKey = 'achievements_cache_timestamp';

  AchievementsController() {
    _logger.d('AchievementsController được khởi tạo');
  }

  @override
  void onInit() {
    _logger.d('onInit của AchievementsController được gọi');
    super.onInit();
    loadCachedAchievements(); // Load cache trước
    fetchAchievements(); // Gọi API nếu cần
  }

  // Lưu danh sách achievements vào cache
  Future<void> saveAchievementsToCache(List<Achievement> achievements) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(achievements.map((a) => a.toJson()).toList());
      await prefs.setString(_cacheKey, jsonString);
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
      _logger.i('Đã lưu cache danh sách thành tựu');
    } catch (e) {
      _logger.e('Lỗi khi lưu cache: $e');
    }
  }

  // Đọc danh sách achievements từ cache
  Future<void> loadCachedAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);
      final timestamp = prefs.getInt(_cacheTimestampKey);

      // Kiểm tra nếu cache tồn tại và còn mới (dưới 1 giờ)
      if (jsonString != null && timestamp != null) {
        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (cacheAge < 3600000) { // 1 giờ
          final List<dynamic> jsonList = jsonDecode(jsonString);
          achievements.assignAll(jsonList.map((json) => Achievement.fromJson(json)).toList());
          _logger.i('Đã load ${achievements.length} thành tựu từ cache');
          return;
        }
      }
      _logger.i('Không có cache hợp lệ, sẽ gọi API');
    } catch (e) {
      _logger.e('Lỗi khi đọc cache: $e');
    }
  }

  Future<void> fetchAchievements() async {
    try {
      _logger.i('Bắt đầu lấy danh sách thành tựu');
      final fetchedAchievements = await _achievementApi.getAchievements();
      achievements.assignAll(fetchedAchievements); // Cập nhật RxList
      await saveAchievementsToCache(fetchedAchievements); // Lưu vào cache
      _logger.i('Lấy danh sách thành tựu thành công: ${achievements.length} thành tựu');
    } catch (e) {
      _logger.e('Lỗi khi lấy danh sách thành tựu: $e');
      Get.snackbar('Lỗi', 'Không thể tải danh sách thành tựu: $e');
    }
  }

  Future<void> claimAchievement(int achievementId) async {
    try {
      _logger.i('Bắt đầu nhận thưởng thành tựu $achievementId');
      final result = await _achievementApi.claimAchievement(achievementId);
      final claimedAchievement = result.achievement;
      final index = achievements.indexWhere((a) => a.id == achievementId);
      if (index != -1) {
        achievements[index] = Achievement(
          id: achievements[index].id,
          name: achievements[index].name,
          type: achievements[index].type,
          progress: achievements[index].progress,
          status: achievements[index].status,
          statusClaim: 'complete',
          sticker: claimedAchievement.sticker,
        );
        await saveAchievementsToCache(achievements); // Cập nhật cache sau khi claim
        _logger.i('Cập nhật thành tựu $achievementId thành công');
      }
      Get.snackbar('Thành công', 'Đã nhận thưởng thành tựu $achievementId!');
    } catch (e) {
      _logger.e('Lỗi khi nhận thưởng thành tựu $achievementId: $e');
      Get.snackbar('Lỗi', 'Không thể nhận thưởng: $e');
    }
  }
}