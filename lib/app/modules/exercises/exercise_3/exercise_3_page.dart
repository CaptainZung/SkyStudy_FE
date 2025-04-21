import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:skystudy/app/routes/app_pages.dart';
import 'exercise_3_controller.dart';
import 'package:skystudy/app/modules/global_widgets/appbar.dart';

class Exercise3Page extends StatelessWidget {
  const Exercise3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Exercise3Controller>(
      builder: (controller) {
        return Scaffold(
          appBar: const CustomAppBar(
            title: 'Phát Âm Từ',
            backgroundColor: Colors.blue,
            showBackButton: true,
          ),
          body: Obx(() {
            final lesson = controller.lesson.value;
            if (lesson == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hiển thị từ và nút phát âm thanh mẫu
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            lesson.word,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Obx(() {
                            return IconButton(
                              icon: Icon(
                                controller.isPlayingSampleSentence.value
                                    ? Icons.pause
                                    : Icons.volume_up,
                                color: Colors.blue,
                              ),
                              onPressed:
                                  controller.isPlayingSampleSentence.value
                                      ? null
                                      : () =>
                                          controller.playSampleSentenceAudio(),
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
                                  controller.accuracy.value >= 0.8
                                      ? 'Phát Âm Đúng'
                                      : 'Sai Mất Rồi',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color:
                                        controller.accuracy.value >= 0.8
                                            ? Colors.green
                                            : Colors.red,
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
                                      controller.isPlayingTts.value
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.blue,
                                    ),
                                    onPressed:
                                        controller.isPlayingTts.value
                                            ? null
                                            : () => controller.playTtsAudio(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  'Độ chính xác: ${(controller.accuracy.value * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 300,
                                  ),
                                  child: Text(
                                    controller.pronunciationFeedback.value,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Hiển thị Lottie animation và thông điệp phản hồi
                              Obx(() {
                                if (controller
                                    .lottieAnimationPath
                                    .value
                                    .isNotEmpty) {
                                  return Column(
                                    children: [
                                      LottieAnimationWidget(
                                        animationPath:
                                            controller
                                                .lottieAnimationPath
                                                .value,
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
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black54,
                              ),
                            ),
                          );
                        }
                        return const Center(
                          child: Text(
                            'Hãy nói rõ ràng để kiểm tra phát âm nhé!',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }),
                      const SizedBox(height: 32),

                      // Nút Tiếp tục và Thử lại
                      Obx(() {
                        if (controller.recognizedText.value.isNotEmpty) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: controller.enableContinueButton.value
                                    ? () {
                                        controller.goToNextExercise();
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                ),
                                child: const Text(
                                  'Tiếp tục',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () {
                                  controller.resetState();
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
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     ElevatedButton(
                      //       onPressed: () {
                      //         Get.toNamed(
                      //           Routes.exercise4,
                      //           arguments: {
                      //             'topic': controller.topic,
                      //             'node': controller.node,
                      //             'exercise': 4,
                      //           },
                      //         );
                      //       },
                      //       style: ElevatedButton.styleFrom(
                      //         backgroundColor: Colors.green,
                      //         padding: const EdgeInsets.symmetric(
                      //           horizontal: 32,
                      //           vertical: 12,
                      //         ),
                      //       ),
                      //       child: const Text(
                      //         'Tiếp tục',
                      //         style: TextStyle(
                      //           color: Colors.white,
                      //           fontSize: 16,
                      //         ),
                      //       ),
                      //     ),
                      //     const SizedBox(width: 16),
                      //     ElevatedButton(
                      //       onPressed: () {
                      //         controller.resetState();
                      //       },
                      //       style: ElevatedButton.styleFrom(
                      //         backgroundColor: Colors.blue,
                      //         padding: const EdgeInsets.symmetric(
                      //           horizontal: 32,
                      //           vertical: 12,
                      //         ),
                      //       ),
                      //       child: const Text(
                      //         'Thử lại',
                      //         style: TextStyle(
                      //           color: Colors.white,
                      //           fontSize: 16,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      const Spacer(),
                      // Nút ghi âm
                      Obx(() {
                        return GestureDetector(
                          onTap:
                              controller.isRecording.value
                                  ? controller.stopRecording
                                  : controller.startRecording,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  controller.isRecording.value
                                      ? Colors.red
                                      : Colors.green,
                            ),
                            child: Icon(
                              controller.isRecording.value
                                  ? Icons.stop
                                  : Icons.mic,
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
            );
          }),
        );
      },
    );
  }
}

// Widget riêng để quản lý Lottie animation với controller
class LottieAnimationWidget extends StatefulWidget {
  final String animationPath;

  const LottieAnimationWidget({super.key, required this.animationPath});

  @override
  LottieAnimationWidgetState createState() => LottieAnimationWidgetState();
}

class LottieAnimationWidgetState extends State<LottieAnimationWidget>
    with SingleTickerProviderStateMixin {
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
        _controller.repeat();
      },
    );
  }
}
