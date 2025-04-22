import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../global_widgets/appbar.dart'; // Import CustomAppBar
import 'leaderboard_controller.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  Future<String> _getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'Guest';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LeaderboardController>(
      init: LeaderboardController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F9FC), // Màu nền sáng hơn
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
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
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
                int userPosition = controller.leaderboardData.indexWhere(
                  (player) => player['name'] == currentUser,
                );

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                                color: Colors.grey[100],
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
                                color: Colors.brown[100],
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
                                color: Colors.black.withOpacity(0.05),
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
                                final player = controller.leaderboardData[index];
                                return AnimatedOpacity(
                                  opacity: 1.0,
                                  duration: const Duration(milliseconds: 500),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8FEFFF).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                      leading: CircleAvatar(
                                        backgroundColor: const Color(0xFF8FEFFF)
                                            .withOpacity(0.3),
                                        radius: 22,
                                        child: Text(
                                          player['avatar'],
                                          style: const TextStyle(fontSize: 20),
                                        ),
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
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            _getProgressColor(index),
                                          ),
                                          minHeight: 5,
                                        ),
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${player['score']} điểm',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF0077B6),
                                              fontSize: 13,
                                            ),
                                          ),
                                          if (player['badge'].toString().isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Text(
                                                player['badge'],
                                                style: const TextStyle(fontSize: 12),
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
                              backgroundColor:
                                  const Color(0xFF8FEFFF).withOpacity(0.3),
                              radius: 22,
                              child: Text(
                                currentUser.length % 2 == 0 ? '👧' : '👦',
                                style: const TextStyle(fontSize: 20),
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
                                    userPosition != -1
                                        ? 'Hạng ${userPosition + 1}'
                                        : 'Chưa có xếp hạng',
                                    style: const TextStyle(
                                        color: Colors.black54, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            if (userPosition != -1)
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
                                  '#${userPosition + 1}',
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  player['avatar'],
                  style: TextStyle(fontSize: avatarRadius - 2),
                ),
                if (isCrowned)
                  const Positioned(
                    top: -18,
                    child: Text(
                      '👑',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
              ],
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