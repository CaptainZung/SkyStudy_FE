import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'exercise_1_controller.dart';
import 'package:skystudy/app/routes/app_pages.dart';  // Đảm bảo bạn đã import Routes

class Exercise1Page extends GetView<Exercise1Controller> {
  const Exercise1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nghe & chọn hình')),
      body: Obx(() {
        final lesson = controller.lesson.value;

        if (lesson == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Ấn vào Panda để nghe âm thanh',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                AudioPlayer().play(UrlSource(lesson.sound));
              },
              child: Lottie.asset(
                'assets/lottie/pandatalk.json',
                width: 120,
                repeat: true,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: lesson.options.map((imgUrl) {
                  return GestureDetector(
                    onTap: () {
                      final isCorrect = imgUrl == lesson.correctAnswer;
                      Get.snackbar(
                        isCorrect ? '🎉 Chính xác' : '❌ Sai rồi',
                        isCorrect ? 'Bạn giỏi lắm!' : 'Hãy thử lại nhé!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: isCorrect ? Colors.green : Colors.red,
                        colorText: Colors.white,
                      );

                      // Sau khi chọn đáp án, nếu đúng thì hiển thị nút Tiếp tục
                      if (isCorrect) {
                        // Bật nút Tiếp tục khi trả lời đúng
                        controller.enableContinueButton.value = true;
                      }
                    },
                    child: Image.network(imgUrl, fit: BoxFit.cover),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            // Nút Tiếp tục chỉ hiển thị khi đáp án đúng
            ElevatedButton(
              onPressed: controller.enableContinueButton.value
                  ? () {
                      // Chuyển sang Exercise 2
                      controller.goToNextExercise();  // Điều hướng đến Exercise 2
                    }
                  : null,  // Nếu chưa chọn đáp án đúng, nút sẽ bị vô hiệu
              child: const Text('Tiếp tục'),
            ),
            const SizedBox(height: 16),
          ],
        );
      }),
    );
  }
}
