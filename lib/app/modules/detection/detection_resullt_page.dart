import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:skystudy/app/modules/global_widgets/appbar.dart';
import 'detection_result_controller.dart';

class DetectionResultPage extends StatelessWidget {
  const DetectionResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng GetBuilder thay vì Get.find để đảm bảo controller được khởi tạo
    return GetBuilder<DetectionResultController>(
      init: DetectionResultController(), // Khởi tạo controller nếu cần
      builder: (controller) {
        return Scaffold(
          appBar: const CustomAppBar(
            title: 'Detection Result',
            backgroundColor: Colors.blue,
            showBackButton: true,
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: controller.processedImageBase64.isNotEmpty
                        ? Image.memory(
                            base64Decode(controller.processedImageBase64),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(child: Text('Lỗi khi hiển thị ảnh nhận diện'));
                            },
                          )
                        : const Center(child: Text('Không có ảnh nhận diện')),
                  ),
                  Container(
                    color: Colors.grey[200],
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 180,
                          child: controller.detectedObjects.isEmpty
                              ? const Center(child: Text('Không có đối tượng nào được nhận diện'))
                              : ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemCount: controller.detectedObjects.length,
                                  itemBuilder: (context, index) {
                                    final object = controller.detectedObjects[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${object['label'] ?? 'Không xác định'} : ${object['label_vi'] ?? 'Không xác định'}',
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Image.asset('assets/icons/generate.png', width: 24, height: 24),
                                                onPressed: () {
                                                  controller.generateSentence(object);
                                                },
                                              ),
                                              IconButton(
                                                icon: Image.asset('assets/icons/tts.png', width: 24, height: 24),
                                                onPressed: () {
                                                  controller.onTtsPressed();
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Obx(() {
                if (controller.isGenerating.value) {
                  return Container(
                    color: Colors.black54,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 250,
                            height: 250,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Lottie.asset(
                            'assets/lottie/loadinggenerate.json',
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        );
      },
    );
  }
}