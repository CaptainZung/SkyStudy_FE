import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skystudy/app/utils/sound_manager.dart';
import 'topic_controller.dart';
import '../global_widgets/appbar.dart'; // Import CustomAppBar
import '../global_widgets/bottom_navbar.dart';

class TopicPage extends GetView<TopicController> {
  const TopicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3EAF5), // Màu nền xanh nhạt như trong hình
      appBar: CustomAppBar(
        title: 'GỢI Ý TỪ VỰNG THEO CHỦ ĐỀ ',
        backgroundColor: Colors.blue, // Nền trong suốt như trong hình
        showBackButton: false, // Hiển thị nút quay lại
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 cột
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 5.0,
            childAspectRatio: 1.0, // Tỷ lệ khung hình vuông
          ),
          itemCount: controller.topics.length,
          itemBuilder: (context, index) {
            final topic = controller.topics[index];
            return GestureDetector(
              onTap: () {
                SoundManager.playButtonSound();
                controller.onTopicTap(topic);
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent, // Không cần màu nền vì hình ảnh đã có khung
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      topic['icon']!,
                      width:190, // Tăng kích thước để khớp với hình ảnh
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 5),
                    // Chữ đã có trong hình nên không cần thêm Text
                  ],
                ),
              ),
            );
          },
        ),
      ),
            bottomNavigationBar: const CustomBottomNavBar(currentIndex: 5),
    );
  }
}