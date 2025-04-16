import 'package:get/get.dart';
import 'exercise_4_controller.dart';

class Exercise4Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Exercise4Controller>(() => Exercise4Controller());
  }
}
