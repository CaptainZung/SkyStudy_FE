import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'exercise_1_controller.dart';
import 'package:skystudy/app/modules/global_widgets/appbar.dart'; // Import CustomAppBar
import 'package:skystudy/app/utils/sound_manager.dart'; // Import SoundManager

class Exercise1Page extends GetView<Exercise1Controller> {
  const Exercise1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Nghe & chọn hình',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              Get.snackbar(
                'Hướng dẫn',
                'Ấn vào Panda để nghe âm thanh',
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
                  return _buildOptionButton(imgUrl, lesson.correctAnswer);
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Obx(() => ElevatedButton(
                  onPressed: controller.enableContinueButton.value
                      ? () {
                          controller.goToNextExercise();
                        }
                      : null,
                  child: const Text('Tiếp tục'),
                )),
            const SizedBox(height: 16),
          ],
        );
      }),
    );
  }

  Widget _buildOptionButton(String imgUrl, String correctAnswer) {
  return StatefulBuilder(
    builder: (context, setState) {
      double scale = 1.0;

      return GestureDetector(
        onTapDown: (_) {
          setState(() {
            scale = 0.75; // Thu nhỏ khi nhấn
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
          final isCorrect = imgUrl == correctAnswer;

          // Hiển thị snackbar ngay lập tức
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
          child: Image.network(
            imgUrl,
            fit: BoxFit.cover,
          ),
        ),
      );
    },
  );
}
}