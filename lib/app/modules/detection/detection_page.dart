import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:skystudy/app/modules/global_widgets/appbar.dart';
import 'detection_controller.dart';
import 'package:skystudy/app/modules/global_widgets/bottom_navbar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lottie/lottie.dart';
import 'package:logger/logger.dart';
import 'package:audioplayers/audioplayers.dart';

class DetectionPage extends StatelessWidget {
  const DetectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AudioPlayer audioPlayer = AudioPlayer(); // Initialize AudioPlayer
    return GetBuilder<DetectionController>(
      init: DetectionController(),
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Nhận diện đối tượng',
            backgroundColor: Colors.blue,
            showBackButton: false,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () {
                  Get.snackbar(
                    'Hướng dẫn',
                    'Nhấn nút giữa để chụp ảnh và nhận diện đối tượng!'
                    '\nNhấn nút bên trái để chuyển đến trang nhận diện thời gian thực!'
                    '\nNhấn nút bên phải để chuyển camera trước/sau!',
                    duration: const Duration(seconds: 3),
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.blue,
                    colorText: Colors.white,
                    borderRadius: 10,
                    margin: const EdgeInsets.all(10),
                  );
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              // Camera preview kéo dài toàn màn hình
              Obx(() {


             if (controller.errorMessage.value.isNotEmpty) {
                 
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 50,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: const Text(
                                'Mở cài đặt để cấp quyền',
                                style: TextStyle(color: Colors.white),
                              ),
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
                      SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: CameraPreview(controller.cameraController!),
                      ),
                      // Thêm overlay để định khung khu vực nhận diện
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 100.0),
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.5,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withAlpha(128),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  );
                }
              }),
              // Đặt 3 nút ở dưới cùng, trên camera preview
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom:60.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          controller.navigateToRealtime();
                        },
                        child: AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(128),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/icons/upgrade.png',
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await audioPlayer.play(AssetSource('audio/shot.mp3')); // Play sound
                          controller.captureAndPredict();
                        },
                        child: AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(128),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/icons/detect.png',
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          controller.switchCamera();
                        },
                        child: AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(128),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/icons/reverse.png',
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Hiển thị Lottie animation khi đang chụp ảnh và nhận diện
              Obx(() {
                if (controller.isLoading.value) {
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