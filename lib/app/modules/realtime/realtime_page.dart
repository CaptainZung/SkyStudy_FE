import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'realtime_controller.dart';
import 'package:camera/camera.dart';

class RealtimePage extends StatelessWidget {
  const RealtimePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RealtimeController>(
      init: RealtimeController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: const Text('Nhận diện vật thể'),
          actions: [
            IconButton(
              icon: const Icon(Icons.switch_camera),
              onPressed: controller.toggleCamera,
            ),
          ],
        ),
        body: _buildCameraView(controller),
      ),
    );
  }

  Widget _buildCameraView(RealtimeController controller) {
    return Obx(() {
      if (!controller.isCameraInitialized.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(controller),
          _buildDetectedClassDisplay(controller),
        ],
      );
    });
  }

  Widget _buildCameraPreview(RealtimeController controller) {
    return Center(
      child: AspectRatio(
        aspectRatio: controller.cameraController!.value.aspectRatio,
        child: CameraPreview(controller.cameraController!),
      ),
    );
  }

  Widget _buildDetectedClassDisplay(RealtimeController controller) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Obx(() {
        final detected = controller.detectedClasses;

        if (detected.isEmpty) {
          return const SizedBox(); // Không hiển thị gì nếu chưa detect
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: detected.map((label) {
              return Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList(),
          ),
        );
      }),
    );
  }
}
