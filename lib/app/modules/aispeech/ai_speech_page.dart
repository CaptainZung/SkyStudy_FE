import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:skystudy/app/modules/global_widgets/appbar.dart';
import 'ai_speech_controller.dart';

class AISpeechPage extends StatelessWidget {
  const AISpeechPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AISpeechController>(
      builder: (controller) {
        return Scaffold(
          appBar: const CustomAppBar(
            title: 'AI Speech',
            backgroundColor: Colors.blue,
            showBackButton: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Câu tiếng Anh với hiệu ứng đổi màu
                Obx(() {
                  return Wrap(
                    spacing: 4.0,
                    children: controller.words.asMap().entries.map((entry) {
                      int index = entry.key;
                      String word = entry.value;
                      // Highlight tất cả các từ từ đầu đến vị trí hiện tại
                      bool isHighlighted = controller.highlightedWordIndex.value >= index;
                      return Text(
                        '$word ', // Thêm khoảng trắng để tách từ
                        style: TextStyle(
                          fontSize: 18,
                          color: isHighlighted ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  );
                }),
                const SizedBox(height: 16),
                // Câu tiếng Việt
                Text(
                  controller.translatedSentence,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                // Nút phát âm thanh và nút chuyển đổi giọng nói
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nút phát/tạm dừng âm thanh
                    Obx(() {
                      return ElevatedButton.icon(
                        onPressed: controller.isPlaying.value
                            ? () => controller.pauseAudio()
                            : () => controller.playAudio(),
                        icon: Icon(
                          controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        label: Text(
                          controller.isPlaying.value ? 'Tạm dừng' : 'Phát âm thanh',
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      );
                    }),
                    const SizedBox(width: 16),
                    // Nút chuyển đổi giọng nói
                    Obx(() {
                      return ElevatedButton.icon(
                        onPressed: () => controller.toggleVoice(),
                        icon: Icon(
                          controller.selectedVoice.value == 'female' ? Icons.female : Icons.male,
                          color: Colors.white,
                        ),
                        label: Text(
                          controller.selectedVoice.value == 'female' ? 'Giọng nữ' : 'Giọng nam',
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                // Tên đối tượng và Lottie animation
                if (controller.detectedObjects.isNotEmpty)
                  Center(
                    child: Column(
                      children: [
                        Text(
                          controller.detectedObjects[0]['label']?.toString() ?? 'Không xác định',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Lottie.asset(
                          'assets/lottie/aispeech.json',
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}