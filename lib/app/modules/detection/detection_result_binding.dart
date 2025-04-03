import 'package:get/get.dart';
import 'detection_result_controller.dart';

class DetectionResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetectionResultController>(() => DetectionResultController());
  }
}