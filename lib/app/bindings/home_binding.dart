import 'package:get/get.dart';
import '../controllers/lottie_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LottieController());
  }
}