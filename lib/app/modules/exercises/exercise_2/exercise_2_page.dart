import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'exercise_2_controller.dart';
import 'package:skystudy/app/routes/app_pages.dart'; // import để dùng Get.toNamed

class Exercise2Page extends GetView<Exercise2Controller> {
  const Exercise2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nhìn ảnh và chọn từ')),
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
              'Bé có biết hình ảnh phía trên trong tiếng Anh có nghĩa là gì không?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Image.network(lesson.image),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: lesson.options.map((word) {
                  return GestureDetector(
                    onTap: () {
                      final isCorrect = word == lesson.correctAnswer;

                      Get.snackbar(
                        isCorrect ? '🎉 Chính xác' : '❌ Sai rồi',
                        isCorrect ? 'Bạn giỏi lắm!' : 'Hãy thử lại nhé!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: isCorrect ? Colors.green : Colors.red,
                        colorText: Colors.white,
                      );

                      if (isCorrect) {
                        // Bật nút Tiếp tục khi trả lời đúng
                        controller.enableContinueButton.value = true;
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        word,
                        style: const TextStyle(fontSize: 20, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            // Nút Tiếp tục chỉ hiển thị khi đáp án đúng
            Obx(() => ElevatedButton(
              onPressed: controller.enableContinueButton.value
                  ? () {
                      // Chuyển sang Exercise 3
                      controller.goToNextExercise(); 
                    }
                  : null, // Nếu chưa đúng thì disable
              child: const Text('Tiếp tục'),
            )),
            const SizedBox(height: 16),
          ],
        );
      }),
    );
  }
}
