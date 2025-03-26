import 'package:get/get.dart';
import 'detection_controller.dart';

class DetectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DetectionController());
  }
}