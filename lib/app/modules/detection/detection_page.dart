import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'detection_controller.dart';
import 'package:skystudy/app/modules/global_widgets/bottom_navbar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lottie/lottie.dart';
import 'package:skystudy/app/modules/global_widgets/appbar.dart';
import 'package:logger/logger.dart';
class DetectionPage extends StatelessWidget {
  const DetectionPage({super.key});


  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetectionController>(
      init: DetectionController(),
      builder: (controller) {
        return Scaffold(
          appBar: const CustomAppBar(
            title: 'Detection',
            backgroundColor: Colors.blue,
            showBackButton: false,
          ),
          body: Stack(
            children: [
              // Camera preview kéo dài toàn màn hình
              Obx(() {
                print('Rendering DetectionPage UI. isCameraInitialized: ${controller.isCameraInitialized.value}');
                print('Error message: ${controller.errorMessage.value}');

                if (controller.errorMessage.value.isNotEmpty) {
                  print('Hiển thị thông báo lỗi: ${controller.errorMessage.value}');
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
                              child: const Text('Mở cài đặt để cấp quyền'),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                if (controller.isCameraInitialized.value &&
                    controller.cameraController != null &&
                    controller.cameraController!.value.isInitialized) {
                  print('Hiển thị CameraPreview');
                  return SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: CameraPreview(controller.cameraController!),
                  );
                } else {
                  print('Hiển thị CircularProgressIndicator');
                  return const Center(child: CircularProgressIndicator());
                }
              }),
              // Đặt 3 nút ở dưới cùng, trên camera preview
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80.0),
                  child: Container(
                    color: const Color.fromARGB(255, 14, 104, 238),
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            print('Nhấn nút navigateToRealtime');
                            controller.navigateToRealtime();
                          },
                          child: Image.asset(
                            'assets/icons/upgrade.png',
                            width: 40,
                            height: 40,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            print('Nhấn nút captureAndPredict');
                            controller.captureAndPredict();
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Image.asset(
                              'assets/icons/detect.png',
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            print('Nhấn nút switchCamera');
                            controller.switchCamera();
                          },
                          child: Image.asset(
                            'assets/icons/reverse.png',
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Hiển thị Lottie animation khi đang chụp ảnh và nhận diện
              Obx(() {
                if (controller.isLoading.value) {
                  print('Hiển thị Lottie loadingdetection');
                  return Container(
                    color: Colors.black54,
                    child: Center(
                      child: Lottie.asset(
                        'assets/lottie/loadingdetection.json',
                        width: 250,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
          bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
        );
      },
    );
  }
}