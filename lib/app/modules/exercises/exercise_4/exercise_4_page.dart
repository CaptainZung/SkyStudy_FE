import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skystudy/app/modules/global_widgets/appbar.dart'; // Import CustomAppBar
import 'package:skystudy/app/utils/sound_manager.dart'; // Import SoundManager
import 'exercise_4_controller.dart';

class Exercise4Page extends GetView<Exercise4Controller> {
  const Exercise4Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Chọn hình đúng với từ',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              Get.snackbar(
                'Hướng dẫn',
                'Chọn hình ảnh đúng với từ hiển thị ở dưới.',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        final lesson = controller.lesson.value;

        if (lesson == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              lesson.word,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: lesson.options.map((url) {
                  return _buildOptionButton(url, lesson.correctAnswer);
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

  Widget _buildOptionButton(String url, String correctAnswer) {
  return StatefulBuilder(
    builder: (context, setState) {
      double scale = 1.0;

      return GestureDetector(
        onTapDown: (_) {
          setState(() {
            scale = 0.85; // Thu nhỏ khi nhấn
          });
        },
        onTapUp: (_) {
          setState(() {
            scale = 1.0; // Trở lại kích thước ban đầu khi thả
          });
        },
        onTapCancel: () {
          setState(() {
            scale = 1.0; // Trở lại kích thước ban đầu nếu hủy nhấn
          });
        },
        onTap: () async {
          final isCorrect = url == correctAnswer;

          // Hiển thị snackbar ngay lập tức
          Get.snackbar(
            isCorrect ? '🎉 Chính xác' : '❌ Sai rồi',
            isCorrect ? 'Bạn giỏi lắm!' : 'Hãy thử lại nhé!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: isCorrect ? Colors.green : Colors.red,
            colorText: Colors.white,
          );

          // Đổi màu nền dựa trên đúng/sai
          if (isCorrect) {
            controller.enableContinueButton.value = true;
            await SoundManager.playCorrectSound(); // Phát âm thanh đúng
          } else {
            await SoundManager.playWrongSound(); // Phát âm thanh sai
          }
        },
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150), // Thời gian hiệu ứng
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Image.network(
              url,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    },
  );
}
}