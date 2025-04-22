import 'package:get/get.dart';
import 'daily_check_controller.dart';

class DailyCheckBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DailyCheckController());
  }
}