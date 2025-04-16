import 'package:get/get.dart';
import 'exercise_3_controller.dart';

class Exercise3Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Exercise3Controller>(() => Exercise3Controller());
  }
}
