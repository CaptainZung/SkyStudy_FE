import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'exercise_3_controller.dart';
import 'package:skystudy/app/routes/app_pages.dart';

class Exercise3Page extends GetView<Exercise3Controller> {
  const Exercise3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phát âm từ')),
      body: Obx(() {
        final lesson = controller.lesson.value;
        if (lesson == null)
          return const Center(child: CircularProgressIndicator());

        return Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Ấn vào Panda để nghe phát âm mẫu, sau đó nhấn mic và đọc lại nhé!',
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: controller.playSampleAudio,
              child: Lottie.asset(
                'assets/lottie/pandatalk.json',
                width: 120,
                repeat: true,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              lesson.word,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Obx(
              () => GestureDetector(
                onTap:
                    controller.isRecording.value
                        ? controller.stopRecording
                        : controller.startRecording,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor:
                      controller.isRecording.value ? Colors.red : Colors.green,
                  child: Icon(
                    controller.isRecording.value ? Icons.stop : Icons.mic,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () =>
                  controller.isProcessing.value
                      ? const CircularProgressIndicator()
                      : Column(
                        children: [
                          Text(
                            controller.recognizedText.value.isNotEmpty
                                ? 'Bé nói: ${controller.recognizedText.value}'
                                : 'Chưa nhận được phát âm',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            controller.accuracy.value >= 0.8
                                ? '🎉 Chính xác!'
                                : controller.accuracy.value > 0
                                ? '❌ Chưa đúng rồi!'
                                : '',
                            style: TextStyle(
                              fontSize: 22,
                              color:
                                  controller.accuracy.value >= 0.8
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ),
                        ],
                      ),
            ),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
              onPressed: controller.enableContinueButton.value
                  ? () {
                      // Chuyển sang Exercise 3
                      controller.goToNextExercise(); 
                    }
                  : null, // Nếu chưa đúng thì disable
              child: const Text('Tiếp tục'),
            )),
          ],
        );
      }),
    );
  }
}
