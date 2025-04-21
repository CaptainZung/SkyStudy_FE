import 'package:get/get.dart';
import 'package:skystudy/app/modules/exercises/exercise_utils.dart';
import 'lesson_model.dart';
import 'lesson_service.dart';
import 'package:skystudy/app/routes/app_pages.dart';
import 'package:skystudy/app/utils/auth_manager.dart';
import 'package:logger/logger.dart';

class Exercise4Controller extends GetxController {
  Rxn<Exercise4Model> lesson = Rxn<Exercise4Model>();
  var enableContinueButton = false.obs;
  final Logger logger = Logger();

  late String topic;
  late int node;

  Future<void> loadLesson(String topic, int node) async {
    try {
      logger.i('Fetching token...');
      final token = await AuthManager.getToken();
      final isTokenValid = await AuthManager.isTokenValid();

      logger.i('Token fetched: $token');
      logger.i('Token validity: $isTokenValid');

      if (token == null || !isTokenValid) {
        Get.snackbar('Lỗi', 'Token không hợp lệ. Vui lòng đăng nhập lại.');
        Get.offAllNamed(Routes.login);
        return;
      }

      logger.i('Fetching lesson for topic: $topic, node: $node');
      final result = await Exercise4Service.fetchLesson(topic, node);
      lesson.value = result;
      logger.i('Fetched lesson: ${lesson.value}');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải bài học');
      logger.e('Error fetching lesson: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();

    topic = Get.arguments?['topic'] ?? 'Animal';
    node = Get.arguments?['node'] ?? 1;

    logger.i('✅ Init topic = $topic | node = $node');

    loadLesson(topic, node);
  }

  void completeExercise() async {
    // Ghi log trước khi gửi
    logger.i('⚠️ completeExercise → topic = "$topic" | node = $node');

    final String currentTopic = topic;
    final int currentNode = node;

    try {
      await Exercise4Service.completeLesson(currentTopic, currentNode);
      Get.snackbar('Hoàn thành', 'Bạn đã hoàn tất bài học này 🎉');

      // Reset sau khi gửi thành công
      topic = '';
      node = 0;

      Get.offAllNamed(Routes.home);
    } catch (e) {
      logger.e('⛔ Error completing lesson: $e');
      Get.snackbar('Lỗi', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }
}
