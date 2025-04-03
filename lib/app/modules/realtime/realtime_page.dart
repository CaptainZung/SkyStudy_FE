import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:skystudy/app/modules/global_widgets/bottom_navbar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'realtime_controller.dart';

class RealtimePage extends StatelessWidget {
  const RealtimePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RealtimeController>(
      init: RealtimeController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // controller.disposeCamera();
                Get.back();
              },
            ),
            title: const Text('Real-Time Detection'),
            backgroundColor: Colors.blue,
          ),
          body: Stack(
            children: [
              Obx(() {
                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.errorMessage.value,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        if (controller.errorMessage.value.contains('permission'))
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                await openAppSettings();
                              },
                              child: const Text('Open Settings to Grant Permission'),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                double? cameraAspectRatio;
                if (controller.isCameraInitialized.value &&
                    controller.cameraController != null &&
                    controller.cameraController!.value.isInitialized) {
                  cameraAspectRatio = controller.cameraController!.value.aspectRatio;
                }

                if (controller.processedImageBase64.value.isNotEmpty) {
                  return AspectRatio(
                    aspectRatio: cameraAspectRatio ?? 4 / 3,
                    child: Image.memory(
                      base64Decode(controller.processedImageBase64.value),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Text('Lỗi khi hiển thị ảnh từ server'));
                      },
                    ),
                  );
                }

                if (controller.isCameraInitialized.value &&
                    controller.cameraController != null &&
                    controller.cameraController!.value.isInitialized) {
                  return CameraPreview(controller.cameraController!);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
              Obx(() {
                if (controller.detectedObjects.isNotEmpty) {
                  return Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.black54,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: controller.detectedObjects.map((object) {
                          return Text(
                            '${object['label'] ?? 'Không xác định'} : ${object['label_vi'] ?? 'Không xác định'}',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
          bottomNavigationBar: const CustomBottomNavBar(
            currentIndex: 2,
          ),
        );
      },
    );
  }
}