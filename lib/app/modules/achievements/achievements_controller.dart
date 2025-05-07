import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:skystudy/app/modules/achievements/achievements_service.dart';
import 'package:skystudy/app/modules/achievements/achivement_model.dart';
import 'package:skystudy/app/modules/achievements/sticker/sticker_model.dart';

class AchievementsController extends GetxController {
  final AchievementApi _achievementApi = AchievementApi();
  List<Achievement> achievements = [];
  List<Sticker> stickers = <Sticker>[].obs;
  RxBool isLoadingStickers = true.obs;

  // Khởi tạo logger
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

  AchievementsController() {
    _logger.d('AchievementsController được khởi tạo');
  }

  get completedAchievements => null;

  @override
  void onInit() {
    _logger.d('onInit của AchievementsController được gọi');
    super.onInit();
    fetchAchievements();
    fetchStickers();
  }

  Future<void> fetchAchievements() async {
    try {
      achievements = await _achievementApi.getAchievements();
      update();
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
        _logger.i('Cập nhật thành tựu $achievementId thành công');
        update();
      }
      Get.snackbar('Thành công', 'Đã nhận thưởng thành tựu $achievementId!');
    } catch (e) {
      _logger.e('Lỗi khi nhận thưởng thành tựu $achievementId: $e');
      Get.snackbar('Lỗi', 'Không thể nhận thưởng: $e');
    }
  }


  Future<void> fetchStickers() async {
      final stickerList = await _achievementApi.getUserStickers();
      isLoadingStickers(false);
      if (stickerList.isEmpty) {
        Get.snackbar('Thông báo', 'Danh sách sticker rỗng. Hãy hoàn thành nhiệm vụ để nhận sticker!');
      }
      stickers.assignAll(stickerList);
    if (stickerList.isEmpty) {
        Get.snackbar('Thông báo', 'Danh sách sticker rỗng. Hãy hoàn thành nhiệm vụ để nhận sticker!');
    }
    isLoadingStickers(false);
  }
}