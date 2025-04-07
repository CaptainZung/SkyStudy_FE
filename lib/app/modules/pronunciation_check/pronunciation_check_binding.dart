import 'package:get/get.dart';
import 'pronunciation_check_controller.dart';

class PronunciationCheckBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PronunciationCheckController>(() => PronunciationCheckController());
  }
}