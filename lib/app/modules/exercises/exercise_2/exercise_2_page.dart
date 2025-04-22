import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'exercise_2_controller.dart';
import 'package:skystudy/app/utils/sound_manager.dart';
import 'package:skystudy/app/modules/global_widgets/appbar.dart';

class Exercise2Page extends GetView<Exercise2Controller> {
  const Exercise2Page({super.key});

  @override
  Widget build(BuildContext context) {
    // Map để lưu trạng thái màu nền của từng đáp án
    final Map<String, Color> optionColors = {};

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Nhìn ảnh và chọn từ',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              Get.snackbar(
                'Hướng dẫn',
                'Chọn từ đúng với hình ảnh hiển thị',
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
            const SizedBox(height: 16),
            const SizedBox(height: 10),
            Image.network(lesson.image),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: lesson.options.map((word) {
                  return _buildOptionButton(
                    word,
                    lesson.correctAnswer,
                    optionColors,
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

  Widget _buildOptionButton(
    String word,
    String correctAnswer,
    Map<String, Color> optionColors,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        double scale = 1.0;

        // Lấy màu nền từ Map hoặc đặt mặc định
        final backgroundColor = optionColors[word] ?? Colors.blueAccent;

        return GestureDetector(
          onTapDown: (_) {
            setState(() {
              scale = 0.85; // Thu nhỏ nhiều hơn khi nhấn
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
            final isCorrect = word == correctAnswer;

            // Cập nhật màu nền dựa trên đúng/sai
            setState(() {
              optionColors[word] = isCorrect ? Colors.green : Colors.red;
            });

            // Bật nút Tiếp tục ngay lập tức nếu đúng
            if (isCorrect) {
              controller.enableContinueButton.value = true;
            }

            // Phát âm thanh đúng/sai
            if (isCorrect) {
              await SoundManager.playCorrectSound();
            } else {
              await SoundManager.playWrongSound();
            }
          },
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 150), // Thời gian hiệu ứng
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: backgroundColor, // Sử dụng màu nền từ Map
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                word,
                style: const TextStyle(fontSize: 20, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}