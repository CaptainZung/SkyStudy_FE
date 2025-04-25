import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skystudy/app/modules/global_widgets/appbar.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'realtime_controller.dart';

import 'package:skystudy/app/routes/app_pages.dart';

class RealtimePage extends StatelessWidget {
  const RealtimePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RealtimeController());
    controller.init();

    return PopScope(
      canPop: false, // Ngăn back mặc định
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Get.offNamed(Routes.home); // Điều hướng về Home khi người dùng back
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(
          title: 'Nhận diện thời gian thực',
          backgroundColor: Colors.transparent,
          showBackButton: true,
          onBack: () {
            Get.offNamed(Routes.home); // Nút back trong AppBar
          },
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
      ),
    );
  }
}
