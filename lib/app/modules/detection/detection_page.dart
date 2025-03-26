import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'detection_controller.dart';

class DetectionPage extends StatelessWidget {
  const DetectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetectionController>(
      init: DetectionController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Detection'),
            backgroundColor: Colors.blue,
          ),
          body: Column(
            children: [
              Expanded(
                child: Obx(() {
                  if (controller.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Text(
                        controller.errorMessage.value,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  if (controller.isCameraInitialized.value &&
                      controller.cameraController != null &&
                      controller.cameraController!.value.isInitialized) {
                    return Stack(
                      children: [
                        CameraPreview(controller.cameraController!),
                        // Hiển thị bounding box và nhãn
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
              ),
              Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.brightness_6, color: Colors.orange),
                          onPressed: () {
                            // Chức năng điều chỉnh độ sáng (chưa triển khai)
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.purple),
                          onPressed: null, // Không cần nút chụp nữa
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.grey),
                          onPressed: () {
                            controller.detectedObjects.clear();
                            controller.errorMessage.value = '';
                            controller.update();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: controller.detectedObjects.map((object) {
                              return Text(
                                '${object['name']} : ${object['translation']}',
                                style: const TextStyle(fontSize: 16),
                              );
                            }).toList(),
                          ),
                          const Column(
                            children: [
                              Icon(Icons.volume_up, color: Colors.grey),
                              SizedBox(height: 8),
                              Icon(Icons.bookmark_border, color: Colors.grey),
                            ],
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}