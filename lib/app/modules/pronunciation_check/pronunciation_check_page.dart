import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:skystudy/app/modules/global_widgets/appbar.dart';
import 'pronunciation_check_controller.dart';

class PronunciationCheckPage extends StatelessWidget {
  const PronunciationCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PronunciationCheckController>(
      builder: (controller) {
        return Scaffold(
          appBar: const CustomAppBar(
            title: 'Kiểm Tra Phát Âm',
            backgroundColor: Colors.blue,
            showBackButton: true,
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hiển thị từ nhận diện và nút phát âm thanh
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.sampleSentence,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Obx(() {
                          return IconButton(
                            icon: Icon(
                              controller.isPlayingSampleSentence.value ? Icons.pause : Icons.volume_up,
                              color: Colors.blue,
                            ),
                            onPressed: controller.isPlayingSampleSentence.value
                                ? null
                                : () => controller.playSampleSentenceAudio(),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Kết quả nhận diện
                    Obx(() {
                      if (controller.recognizedText.value.isNotEmpty) {
                        return Column(
                          children: [
                            Text(
                              controller.accuracy.value >= 0.8 ? 'Phát Âm Đúng' : 'Sai Mất Rồi',
                              style: TextStyle(
                                fontSize: 20,
                                color: controller.accuracy.value >= 0.8 ? Colors.green : Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Nhận diện: ${controller.recognizedText.value}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    controller.isPlayingTts.value ? Icons.pause : Icons.play_arrow,
                                    color: Colors.blue,
                                  ),
                                  onPressed: controller.isPlayingTts.value
                                      ? null
                                      : () => controller.playTtsAudio(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Độ chính xác: ${(controller.accuracy.value * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              controller.pronunciationFeedback.value,
                              style: const TextStyle(fontSize: 16, color: Colors.black54),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      } else if (controller.isProcessing.value) {
                        return const Text(
                          'Đang xử lý...',
                          style: TextStyle(fontSize: 20, color: Colors.black54),
                        );
                      }
                      return const Text(
                        'Hãy nói rõ ràng để kiểm tra phát âm nhé!',
                        style: TextStyle(fontSize: 20, color: Colors.black54),
                      );
                    }),
                    const SizedBox(height: 32),
                    // Nút Lưu và Thử lại
                    Obx(() {
                      if (controller.recognizedText.value.isNotEmpty) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Logic lưu (có thể thêm sau)
                                Get.snackbar('Thông báo', 'Đã lưu kết quả.');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              ),
                              child: const Text(
                                'Lưu',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                controller.recognizedText.value = '';
                                controller.accuracy.value = 0.0;
                                controller.pronunciationFeedback.value = '';
                                controller.ttsAudioBase64.value = '';
                                controller.isPlayingTts.value = false;
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              ),
                              child: const Text(
                                'Thử lại',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    const Spacer(),
                    // Nút ghi âm
                    Obx(() {
                      return GestureDetector(
                        onTap: controller.isRecording.value
                            ? controller.stopRecording
                            : controller.startRecording,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: controller.isRecording.value ? Colors.red : Colors.green,
                          ),
                          child: Icon(
                            controller.isRecording.value ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              // Hiệu ứng loading khi đang xử lý
              Obx(() {
                if (controller.isProcessing.value) {
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