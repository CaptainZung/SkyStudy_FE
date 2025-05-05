import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skystudy/app/modules/achievements/achievements_controller.dart';
import 'package:skystudy/app/modules/achievements/achievement_item.dart';
import 'package:skystudy/app/modules/global_widgets/appbar.dart';
import 'package:skystudy/app/modules/global_widgets/bottom_navbar.dart';
import 'package:skystudy/app/modules/achievements/sticker/achiverment_sticker.dart';
// Placeholder for the AchievementStickerPage

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AchievementsController>(
      tag: 'AchievementsController',
      builder: (controller) {
        return DefaultTabController(
          length: 2, // Two tabs: Achievements and Stickers
          child: Scaffold(
            appBar: CustomAppBar(
              title: 'Achievements',
              backgroundColor: Colors.blue,
              showBackButton: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // Placeholder for adding a new achievement
                    // Replace with actual navigation or logic as needed
                    Get.snackbar('Info', 'Add achievement functionality not implemented yet');
                  },
                ),
              ],
              bottom: const TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: 'Achievements'),
                  Tab(text: 'Stickers'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                // Achievements Tab
                controller.achievements.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: controller.fetchAchievements,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: controller.achievements.length,
                          itemBuilder: (context, index) {
                            final achievement = controller.achievements[index];
                            return AchievementItem(achievement: achievement);
                          },
                        ),
                      ),
                // Stickers Tab
                AchievementStickerPage(),
              ],
            ),
            bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
          ),
        );
      },
    );
  }
}