import 'package:get/get.dart';
import 'exercise_1_controller.dart';

class Exercise1Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Exercise1Controller>(() => Exercise1Controller());
  }
}
