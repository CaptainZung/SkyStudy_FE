import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skystudy/app/modules/achievements/achievements_controller.dart';
import 'package:skystudy/app/modules/achievements/achievement_item.dart';
import 'package:skystudy/app/modules/global_widgets/appbar.dart';
import 'package:skystudy/app/modules/global_widgets/bottom_navbar.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AchievementsController>(
      tag: 'AchievementsController',
      builder: (controller) {
        if (controller == null) {
          return const Scaffold(
            body: Center(child: Text('Không tìm thấy AchievementsController')),
          );
        }
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Achievements',
            backgroundColor: Colors.blue,
            showBackButton: true, // Bật nút back
          ),
          body: Obx(() {
            if (controller.achievements.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return RefreshIndicator(
              onRefresh: controller.fetchAchievements,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: controller.achievements.length,
                itemBuilder: (context, index) {
                  final achievement = controller.achievements[index];
                  return AchievementItem(achievement: achievement);
                },
              ),
            );
          }),
          bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3), // Giữ bottomNavigationBar
        );
      },
    );
  }
}