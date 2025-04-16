import 'package:get/get.dart';
import 'package:logger/logger.dart';

class TopicController extends GetxController {
  final Logger logger = Logger();

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

  void onTopicTap(Map<String, String> topic) {
    logger.i('Topic tapped: ${topic['name']}');
    // Thêm logic điều hướng nếu cần, ví dụ: Get.toNamed(Routes.someRoute, arguments: topic);
  }
}