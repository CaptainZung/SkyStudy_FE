import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'achievements_controller.dart';
import 'package:skystudy/app/modules/global_widgets/bottom_navbar.dart'; // Import the updated CustomBottomNavBar
import 'package:skystudy/app/modules/global_widgets/appbar.dart'; // Import the updated CustomAppBar
import 'package:skystudy/app/utils/sound_manager.dart'; // Import SoundManager for background music

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AchievementsController>(
      builder: (controller) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: CustomAppBar(
              title: 'Achievements',
              backgroundColor: Colors.blue,
              showBackButton: false,
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Thành Tích'),
                  Tab(text: 'Nhiệm Vụ Hằng Ngày'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                // Thành Tích (Achievements) Tab
                ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: controller.achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = controller.achievements[index];
                    return AchievementItem(
                      title: achievement['title'],
                      progress: achievement['progress'],
                      total: achievement['total'],
                      reward: achievement['reward'],
                    );
                  },
                ),
                // Nhiệm Vụ Hằng Ngày (Daily Tasks) Tab
                ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: controller.dailyTasks.length,
                  itemBuilder: (context, index) {
                    final task = controller.dailyTasks[index];
                    return AchievementItem(
                      title: task['title'],
                      progress: task['progress'],
                      total: task['total'],
                      reward: task['reward'],
                    );
                  },
                ),
              ],
            ),
            bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
          ),
        );
      },
    );
  }
}

// Widget to display each achievement/task item
class AchievementItem extends StatelessWidget {
  final String title;
  final int progress;
  final int total;
  final int reward;

  const AchievementItem({
    super.key,
    required this.title,
    required this.progress,
    required this.total,
    required this.reward,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$progress/$total',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Image.asset(
                  'assets/icons/point.png',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 4),
                Text(
                  '+$reward',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}