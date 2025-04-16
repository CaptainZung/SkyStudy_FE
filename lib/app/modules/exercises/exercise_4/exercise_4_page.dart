import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'exercise_4_controller.dart';
import 'package:skystudy/app/routes/app_pages.dart';  

class Exercise4Page extends GetView<Exercise4Controller> {
  const Exercise4Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn hình đúng với từ')),
      body: Obx(() {
        final lesson = controller.lesson.value;

        if (lesson == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            const SizedBox(height: 20),
            Text(
              lesson.word,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Bé có biết từ trên trong tiếng Anh có nghĩa là gì không?'),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: lesson.options.map((url) {
                  return GestureDetector(
                    onTap: () {
                      final isCorrect = url == lesson.correctAnswer;
                      Get.snackbar(
                        isCorrect ? '🎉 Chính xác' : '❌ Sai rồi',
                        isCorrect ? 'Bạn giỏi lắm!' : 'Hãy thử lại nhé!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: isCorrect ? Colors.green : Colors.red,
                        colorText: Colors.white,
                      );
                      if (isCorrect) {
                        controller.enableContinueButton.value = true;
                      }
                    },
                    child: Image.network(url, fit: BoxFit.cover),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Obx(() => ElevatedButton(
              onPressed: controller.enableContinueButton.value
                  ? () => controller.completeExercise()
                  : null,
              child: const Text('Tiếp tục'),
            )),
            const SizedBox(height: 16),
          ],
        );
      }),
    );
  }
}
