import 'package:get/get.dart';
import 'package:skystudy/app/modules/home/home_controller.dart';
import 'package:skystudy/app/controllers/lottie_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
Get.put(HomeController(), permanent: true); // Giữ controller mãi mãi
    Get.put(LottieController(), permanent: true);
  }
}