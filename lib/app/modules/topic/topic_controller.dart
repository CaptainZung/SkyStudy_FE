import 'package:get/get.dart';
import 'package:logger/logger.dart';
import './singleword_page.dart';
import 'topic_service.dart';

class TopicController extends GetxController {
  final Logger logger = Logger();
  final TopicApi topicApi = TopicApi();

  // Danh sách các chủ đề với tên và đường dẫn icon
  final List<Map<String, String>> topics = [
    {'name': 'Family', 'icon': 'assets/images/family.png'},
    {'name': 'Animal', 'icon': 'assets/images/animal.png'},
    {'name': 'Sport', 'icon': 'assets/images/sport.png'},
    {'name': 'Fruits', 'icon': 'assets/images/fruit.png'},
    {'name': 'Foods', 'icon': 'assets/images/food.png'},
    {'name': 'School', 'icon': 'assets/images/school.png'},
    {'name': 'Travel', 'icon': 'assets/images/travel.png'},
    {'name': 'Clothes', 'icon': 'assets/images/clothes.png'},
  ];

  Future<void> onTopicTap(Map<String, String> topic) async {
    logger.i('Topic tapped: ${topic['name']}');
    try {
      final word = await topicApi.getword(topic['name']!);
      // Điều hướng đến SingleWordPage, truyền dữ liệu từ vựng
      Get.to(() => const SingleWordPage(), arguments: word);
    } catch (e) {
      logger.e('Error: $e');
      Get.snackbar('Lỗi', 'Không thể tải từ vựng cho chủ đề ${topic['name']}');
    }
  }
}