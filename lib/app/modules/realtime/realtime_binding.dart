import 'package:get/get.dart';
import 'realtime_controller.dart';

class DetectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RealtimeController());
  }
}