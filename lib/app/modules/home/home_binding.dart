import 'package:get/get.dart';
import 'package:skystudy/app/modules/home/home_controller.dart';
import 'package:skystudy/app/controllers/lottie_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => LottieController());
  }
}