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
      appBar: CustomAppBar(
        title: 'YOLO Real-time Detection',
        backgroundColor: Colors.blue, // Giữ màu nền giống AppBar cũ
        showBackButton: true, // Hiển thị nút back để quay lại
      ),
      body: Obx(() {
        if (!controller.isReady.value || controller.predictor == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.85,
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