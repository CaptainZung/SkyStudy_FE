import 'package:get/get.dart';
import 'ai_speech_controller.dart';

class AISpeechBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AISpeechController>(() => AISpeechController());
  }
}