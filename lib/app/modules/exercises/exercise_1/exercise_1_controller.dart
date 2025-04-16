import 'package:get/get.dart';
import 'package:skystudy/app/modules/exercises/exercise_utils.dart';
import 'package:skystudy/app/routes/app_pages.dart';
import 'package:skystudy/app/utils/auth_manager.dart';
import 'lesson_service.dart';
import 'lesson_model.dart';
import 'package:logger/logger.dart';

class Exercise1Controller extends GetxController {
  Rxn<LessonModel> lesson = Rxn<LessonModel>();
  var enableContinueButton = false.obs;
  final Logger logger = Logger();

  late String topic;
  late int node;
  late int exercise = 1; // Mặc định là bài tập 1

  @override
  void onInit() {
    super.onInit();

    logger.i('📥 Get.arguments: ${Get.arguments}');

    try {
      topic =
          Get.arguments['topic'] ??
          'Animal'; // Nếu không có topic, mặc định là 'Animal'
      node = Get.arguments['node'] ?? 1; // Nếu không có node, mặc định là 1

      logger.i('✅ onInit - topic: $topic, node: $node');
      loadLesson(topic, node); // Luôn luôn tải bài học đầu tiên trong node
    } catch (e) {
      logger.e('⛔ Error in onInit: $e');
    }
    print('Exercise1 - topic: $topic, node: $node');
  }

  // Hàm tải bài học từ server
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
      logger.i('Fetching lesson for topic: $topic, node: $node');

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

  // Hàm chuyển sang bài tập tiếp theo trong node
  void goToNextExercise() {
    if (exercise < 4) {
      // Kiểm tra xem bài tập trong node đã hoàn thành chưa (từ exercise 1 đến exercise 4)
      final nextExercise =
          exercise + 1; // Tăng bài tập lên 1 (từ 1 -> 2, 2 -> 3, 3 -> 4)

      final nextRoute = getRouteByExercise(
        nextExercise,
      ); // Dùng hàm getRouteByExercise để lấy đúng route

      if (nextRoute != null) {
        Get.toNamed(
          nextRoute, // Chuyển đến bài tập tiếp theo theo đúng route
          arguments: {
            'topic': topic, // Truyền topic không đổi
            'node': node, // Truyền node không đổi
            'exercise': nextExercise, // Truyền bài tập tiếp theo
          },
        );
      }
    } else {
      // Nếu đã hoàn thành tất cả bài tập trong node (exercise == 4)
      final nextNode = node + 1; // Chuyển sang node tiếp theo trong cùng topic

      if (nextNode <= 4) {
        // Kiểm tra xem còn node nào không (giả sử chỉ có 4 node trong mỗi topic)
        Get.toNamed(
          Routes
              .exercise1, // Đi tới bài tập đầu tiên của node mới (exercise = 1)
          arguments: {
            'topic': topic, // Truyền topic không đổi
            'node': nextNode, // Chuyển sang node tiếp theo
            'exercise': 1, // Đặt lại bài tập là bài đầu tiên
          },
        );
      } else {
        // Nếu không còn node nào, thông báo hoàn thành bài học
        Get.snackbar('Hoàn thành', 'Bạn đã hoàn tất bài học này 🎉');
      }
    }
  }
}
