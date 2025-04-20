import 'package:get/get.dart';
import 'package:skystudy/app/routes/app_pages.dart';
import 'package:skystudy/app/modules/exercises/exercise_utils.dart';
import 'lesson_service.dart';
import 'lesson_model.dart';
import 'package:logger/logger.dart';
import 'package:skystudy/app/utils/auth_manager.dart';

class Exercise2Controller extends GetxController {
  Rxn<LessonModel> lesson = Rxn<LessonModel>();
  final Logger logger = Logger();
  var enableContinueButton = false.obs;

  late String topic;
  late int node;
  late int exercise;

  Future<void> loadLesson(String topic, int node) async {
    try {
      // Log: Lấy token và kiểm tra tính hợp lệ
      logger.i('Fetching token...');
      final token = await AuthManager.getToken();
      final isTokenValid = await AuthManager.isTokenValid();

      logger.i('Token fetched: $token');
      logger.i('Token validity: $isTokenValid');

      if (token == null || !isTokenValid) {
        Get.snackbar('Lỗi', 'Token không hợp lệ. Vui lòng đăng nhập lại.');
        Get.offAllNamed(Routes.login); // Điều hướng về trang login
        return;
      }

      // Log: Fetch bài học
      logger.i('Fetching lesson for topic: $topic, node: $node, exercise: $exercise');

      // Gọi LessonService để lấy dữ liệu bài học
      final result = await LessonService.fetchLesson(topic, node);
      lesson.value = result; // Lưu dữ liệu bài học vào lesson

      // Log: Dữ liệu bài học đã nhận
      logger.i('Fetched lesson: ${lesson.value}');
    } catch (e) {
      // Log lỗi nếu không thể tải bài học
      Get.snackbar('Lỗi', 'Không thể tải bài học');
      logger.e('Error fetching lesson: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();

    logger.i('📥 Get.arguments: ${Get.arguments}');

    try {
      topic = Get.arguments['topic'] ?? 'Animal';
      node = Get.arguments['node'] ?? 1;
      exercise = Get.arguments['exercise'] ?? 1;

      logger.i('✅ onInit - topic: $topic, node: $node, exercise: $exercise');
      loadLesson(topic, node); // Luôn luôn tải bài học đầu tiên trong node
    } catch (e) {
      logger.e('⛔ Error in onInit: $e');
    }
  }

  // Hàm chuyển đến bài tập tiếp theo trong node
  void goToNextExercise() {
    if (exercise < 4) { // Kiểm tra xem còn bài tập nào trong node không
      final nextExercise = exercise + 1; // Tăng số bài tập lên 1
      final nextRoute = getRouteByExercise(nextExercise);  // Lấy route của bài tập tiếp theo

      if (nextRoute != null) {
        Get.toNamed(
          nextRoute,
          arguments: {'topic': topic, 'node': node, 'exercise': nextExercise}, // Truyền topic, node, exercise vào page mới
        );
      }
    }
  }
}
