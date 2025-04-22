import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'realtime_controller.dart';
import 'package:skystudy/app/modules/global_widgets/appbar.dart'; // Thay bằng đường dẫn thực tế đến CustomAppBar

class RealtimePage extends StatelessWidget {
  const RealtimePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RealtimeController());
    controller.init();

    return Scaffold(
      extendBodyBehindAppBar: true, // Cho phép nội dung hiển thị phía sau AppBar
      appBar: CustomAppBar(
        title: 'Nhận diện thời gian thực',
        backgroundColor: Colors.transparent, // Làm AppBar trong suốt
        showBackButton: true, // Hiển thị nút back để quay lại
      ),
      body: Obx(() {
        if (!controller.isReady.value || controller.predictor == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: UltralyticsYoloCameraPreview(
              boundingBoxesColorList: controller.randomBoundingBoxColors,
              controller: controller.cameraController,
              predictor: controller.predictor!,
              onCameraCreated: () {},
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.cameraController.toggleLensDirection();
        },
        child: const Icon(Icons.flip_camera_android),
      ),
    );
  }
}