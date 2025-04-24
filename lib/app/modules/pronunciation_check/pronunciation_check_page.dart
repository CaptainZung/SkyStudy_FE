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
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                controller.accuracy.value >= 0.8 ? 'Phát Âm Đúng' : 'Sai Mất Rồi',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: controller.accuracy.value >= 0.8 ? Colors.green : Colors.red,
                                ),
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
                            Center(
                              child: Text(
                                'Độ chính xác: ${(controller.accuracy.value * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(fontSize: 16, color: Colors.black54),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 300),
                                child: Text(
                                  controller.pronunciationFeedback.value,
                                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Display Lottie animation and feedback message
                            Obx(() {
                              if (controller.lottieAnimationPath.value.isNotEmpty) {
                                return Column(
                                  children: [
                                    LottieAnimationWidget(
                                      animationPath: controller.lottieAnimationPath.value,
                                    ),
                                    const SizedBox(height: 8),
                                    Center(
                                      child: Text(
                                        controller.feedbackMessage.value,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                          ],
                        );
                      } else if (controller.isProcessing.value) {
                        return const Center(
                          child: Text(
                            'Đang xử lý...',
                            style: TextStyle(fontSize: 20, color: Colors.black54),
                          ),
                        );
                      }
                      return const Center(
                        child: Text(
                          'Hãy nói rõ ràng để kiểm tra phát âm nhé!',
                          style: TextStyle(fontSize: 20, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
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
                              onPressed: controller.handleSaveButton, // Gọi hàm handleSaveButton
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
                                controller.lottieAnimationPath.value = '';
                                controller.feedbackMessage.value = '';
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
                return const SizedBox.shrink(); // Dừng animation ngay khi isProcessing = false
              }),
            ],
          ),
        );
      },
    );
  }
}

// Separate widget to manage Lottie animation with a controller
class LottieAnimationWidget extends StatefulWidget {
  final String animationPath;

  const LottieAnimationWidget({super.key, required this.animationPath});

  @override
  LottieAnimationWidgetState createState() => LottieAnimationWidgetState();
}

class LottieAnimationWidgetState extends State<LottieAnimationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(LottieAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationPath != widget.animationPath) {
      // When the animation path changes, reset and play the new animation in a loop
      _controller.reset();
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      widget.animationPath,
      controller: _controller,
      width: 120,
      height: 120,
      fit: BoxFit.cover,
      onLoaded: (composition) {
        _controller.duration = composition.duration;
        _controller.repeat(); // Start looping the animation
      },
    );
  }
}