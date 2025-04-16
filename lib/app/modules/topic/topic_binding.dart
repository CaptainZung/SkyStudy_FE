import 'package:get/get.dart';
import 'topic_controller.dart';

class TopicBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TopicController>(() => TopicController());
  }
}