import 'package:get/get.dart';
import 'exercise_2_controller.dart';

class Exercise2Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Exercise2Controller>(() => Exercise2Controller());
  }
}
