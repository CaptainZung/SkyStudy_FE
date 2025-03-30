import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'detection_controller.dart';
import 'package:skystudy/app/modules/global_widgets/bottom_navbar.dart';
import 'package:permission_handler/permission_handler.dart ';
class DetectionPage extends StatelessWidget {
  const DetectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetectionController>(
      init: DetectionController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Get.back();
              },
            ),
            title: const Text('Detection'),
            backgroundColor: Colors.blue,
          ),
          body: Obx(() {
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
            if (controller.isCameraInitialized.value &&
                controller.cameraController != null &&
                controller.cameraController!.value.isInitialized) {
              return Stack(
                children: [
                  CameraPreview(controller.cameraController!),
                  ...controller.detectedObjects.map((object) {
                    return Positioned(
                      top: object['position']['top'],
                      left: object['position']['left'],
                      child: Container(
                        width: object['position']['width'],
                        height: object['position']['height'],
                        decoration: BoxDecoration(
                          border: Border.all(color: object['color'], width: 2),
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              object['name'],
                              style: TextStyle(
                                color: object['color'],
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
          bottomNavigationBar: const CustomBottomNavBar(
            currentIndex: 2,
          ),
        );
      },
    );
  }
}