import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:skystudy/app/modules/global_widgets/appbar.dart';
import 'detection_result_controller.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class DetectionResultPage extends StatelessWidget {
  const DetectionResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetectionResultController>(
      init: DetectionResultController(),
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Kết quả nhận diện',
            backgroundColor: Colors.blue,
            showBackButton: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () {
                  Get.snackbar(
                    'Hướng dẫn',
                    'Vuốt chữ nhận diện sang trái để luyện phát âm, vuốt sang phải để tạo câu bằng AI.',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.blue,
                    colorText: Colors.white,
                  );
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 224, 223, 223).withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
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
                    ),
                  ),
                  Container(
                    color: const Color.fromARGB(255, 230, 230, 229),
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
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Slidable(
                                        key: ValueKey(object['label']),
                                        startActionPane: ActionPane(
                                          motion: const DrawerMotion(),
                                          children: [
                                            CustomSlidableAction(
                                              onPressed: (_) {
                                                controller.generateSentence(object);
                                              },
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Increased vertical padding
                                                decoration: BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius: BorderRadius.circular(12.0),
                                                  // Removed border property
                                                ),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: const [
                                                      Icon(Icons.edit, color: Colors.white, size: 18),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'Tạo câu',
                                                        style: TextStyle(color: Colors.white, fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        endActionPane: ActionPane(
                                          motion: const DrawerMotion(),
                                          children: [
                                            CustomSlidableAction(
                                              onPressed: (_) {
                                                controller.onTtsPressed(object);
                                              },
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Increased vertical padding
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius: BorderRadius.circular(12.0),
                                                  // Removed border property
                                                ),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: const [
                                                      Icon(Icons.mic_sharp, color: Colors.white, size: 18),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'Kiểm tra',
                                                        style: TextStyle(color: Colors.white, fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,// Bo viền
                                            border: Border.all( // Thêm viền
                                              color: Colors.blueAccent,
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color.fromARGB(255, 242, 242, 242).withOpacity(0.3),
                                                spreadRadius: 2,
                                                blurRadius: 5,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${object['label'] ?? 'Không xác định'} : ${object['label_vi'] ?? 'Không xác định'}',
                                                style: const TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
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