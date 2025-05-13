import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../global_widgets/appbar.dart';
import 'leaderboard_controller.dart';
import 'package:skystudy/app/modules/profile/profile_controller.dart'; // Import ProfileController

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  Future<String> _getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'Guest';
  }

  @override
  Widget build(BuildContext context) {
    // Khởi tạo ProfileController để lấy rank
    final ProfileController profileController = Get.find<ProfileController>();

    return GetBuilder<LeaderboardController>(
      init: LeaderboardController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F9FC),
          appBar: CustomAppBar(
            title: 'Bảng Xếp Hạng',
            backgroundColor: const Color(0xFF2277B4),
            titleStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            showBackButton: true,
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.leaderboardData.isEmpty) {
              return const Center(
                child: Text(
                  'Không có dữ liệu bảng xếp hạng',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              );
            }

            return FutureBuilder<String>(
              future: _getCurrentUsername(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final currentUser = snapshot.data!;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    children: [
                      // Top 3 Leaderboard UI
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.25,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (controller.leaderboardData.length > 1)
                              _buildTopPlayerCard(
                                rank: 2,
                                color: const Color.fromARGB(255, 227, 218, 218),
                                textColor: Colors.black54,
                                player: controller.leaderboardData[1],
                                avatarRadius: 28,
                              ),
                            if (controller.leaderboardData.isNotEmpty)
                              _buildTopPlayerCard(
                                rank: 1,
                                color: Colors.amber[100],
                                textColor: Colors.amber,
                                player: controller.leaderboardData[0],
                                avatarRadius: 36,
                                isCrowned: true,
                              ),
                            if (controller.leaderboardData.length > 2)
                              _buildTopPlayerCard(
                                rank: 3,
                                color: const Color.fromARGB(255, 243, 154, 122),
                                textColor: Colors.brown[400],
                                player: controller.leaderboardData[2],
                                avatarRadius: 28,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Leaderboard List
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(13),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: ListView.builder(
                              itemCount: controller.leaderboardData.length,
                              itemBuilder: (context, index) {
                                final player =
                                    controller.leaderboardData[index];
                                return AnimatedOpacity(
                                  opacity: 1.0,
                                  duration: const Duration(milliseconds: 500),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF8FEFFF,
                                      ).withAlpha(13),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
                                          ),
                                      leading: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          CircleAvatar(
                                            backgroundColor: const Color(
                                              0xFF8FEFFF,
                                            ).withAlpha(13),
                                            radius: 22,
                                            backgroundImage: AssetImage(
                                              'assets/avatar/${player['avatar']}.png', // Display avatar from assets
                                            ),
                                          ),
                                        ],
                                      ),
                                      title: Text(
                                        player['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: LinearProgressIndicator(
                                          value: player['progress'],
                                          backgroundColor: Colors.grey[200],
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                _getProgressColor(index),
                                              ),
                                          minHeight: 5,
                                        ),
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${player['score']} điểm',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF0077B6),
                                              fontSize: 13,
                                            ),
                                          ),
                                          if (player['badge']
                                              .toString()
                                              .isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 2,
                                              ),
                                              child: Text(
                                                player['badge'],
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Current User Position
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(
                                0xFF8FEFFF,
                              ).withOpacity(0.3),
                              radius: 22,
                              backgroundImage: AssetImage(
                                'assets/avatar/${profileController.avatarName.value}.png', // Lấy avatar từ ProfileController
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Vị trí của bạn',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    profileController.rank.value > 0
                                        ? 'Hạng ${profileController.rank.value}'
                                        : 'Chưa có xếp hạng',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (profileController.rank.value > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8FEFFF),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '#${profileController.rank.value}',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }

  Widget _buildTopPlayerCard({
    required int rank,
    required Color? color,
    required Color? textColor,
    required Map<String, dynamic> player,
    required double avatarRadius,
    bool isCrowned = false,
  }) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage(
              'assets/avatar/${player['avatar']}.png', // Display avatar from assets
            ),
          ),
          const SizedBox(height: 6),
          Text(
            player['name'],
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '${player['score']} điểm',
            style: const TextStyle(
              color: Color(0xFF0077B6),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                player['badge'],
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey;
      case 2:
        return Colors.brown;
      default:
        return const Color(0xFF0077B6);
    }
  }
}
