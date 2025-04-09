import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'realtime_controller.dart';
 
class RealtimePage extends StatelessWidget {
  const RealtimePage({super.key});
 
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RealtimeController());
    controller.init();
 
    return Scaffold(
      appBar: AppBar(
        title: const Text('YOLO Real-time Detection'),
        backgroundColor: Colors.blue,
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
              boundingBoxesColorList: const [Colors.red],
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