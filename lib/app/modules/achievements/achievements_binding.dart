import 'package:get/get.dart';
import './achievements_controller.dart';

class AchievementsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AchievementsController(), tag: 'AchievementsController');
  }
}