import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skystudy/app/modules/achievements/achievements_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Trang hiển thị danh sách sticker
class AchievementStickerPage extends StatelessWidget {
  const AchievementStickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AchievementsController>(tag: 'AchievementsController');

    return Container(
      color: const Color(0xFFC8E5EB), // Màu nền #C8E5EB
      child: Obx(() {
        if (controller.isLoadingStickers.value) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A237E)),
                strokeWidth: 6,
              ),
            ),
          );
        }
        if (controller.stickers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(seconds: 2),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 1 + value * 0.1,
                      child: const Icon(
                        Icons.sticky_note_2,
                        size: 80,
                        color: Color(0xFF1A237E),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF6A82FB)],
                  ).createShader(bounds),
                  child: const Text(
                    'Không có sticker nào',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Hoàn thành nhiệm vụ để nhận sticker hoặc kéo xuống để thử lại!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1A237E),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => controller.fetchStickers(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A82FB),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                  ),
                  child: const Text(
                    'Thử lại',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchStickers,
          color: const Color(0xFF6A82FB),
          backgroundColor: Colors.white,
          child: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.8,
            ),
            itemCount: controller.stickers.length,
            itemBuilder: (context, index) {
              final sticker = controller.stickers[index];
              return AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: GestureDetector(
                  onTap: () {}, // Có thể thêm logic sau này
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 1, end: 1.05),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.white, Color(0xFFF5F7FA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFFCA28), width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFCA28).withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: sticker.stickerUrl,
                                height: 100,
                                width: 100,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A82FB)),
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 50,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              sticker.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A237E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}